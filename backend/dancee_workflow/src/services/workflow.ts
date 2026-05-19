import * as restate from "@restatedev/restate-sdk";
import { scrapeEvent } from "../clients/scraper-client";
import {
  findEventByOriginalUrl,
  createEvent,
  createError,
  createSkippedEvent,
  getDanceStyleCodes,
  findCourseByOriginalUrl,
  createCourse,
} from "../clients/directus-client";
import {
  classifyEventType,
  extractEventParts,
  extractEventInfo,
  extractCourseData,
  validateDanceCodes,
} from "./event-parser";
import { translateEventContent, translateCourseContent } from "./event-translator";
import { processEventImage } from "./image-processor";
import { resolveVenue } from "./venue-resolver";
import { computeDances, SUPPORTED_EVENT_TYPES, toIsoOrNull } from "../core/schemas";
import { convertToLocalTime } from "../core/timezone";
import { captureError } from "../core/config";
import { log } from "../core/logger";
import { normalizeEventUrl } from "../core/utils";
import type {
  DirectusEvent,
  DirectusEventTranslation,
  DirectusCourse,
  FacebookEvent,
  ErrorType,
} from "../core/schemas";

/**
 * Determines the error type based on the workflow step name and error message.
 */
function classifyErrorType(stepName: string, message: string): ErrorType {
  if (stepName === "scrape") {
    // Distinguish between "no data" (scrape_failed) and "bad data shape" (parse_failed)
    const lower = message.toLowerCase();
    if (lower.includes("parse") || lower.includes("invalid_union") || lower.includes("expected")) {
      return "parse_failed";
    }
    return "scrape_failed";
  }
  if (stepName === "classify" || stepName === "extractParts" || stepName === "extractInfo") {
    return "llm_parse_failed";
  }
  return "workflow_failed";
}

/**
 * Wraps ctx.run with consistent captureError + rethrow handling.
 * All workflow steps that should abort on failure use this helper
 * instead of repeating the same try/catch boilerplate.
 */
async function runStep<T>(
  ctx: restate.WorkflowContext,
  stepName: string,
  eventUrl: string,
  fn: () => Promise<T>,
): Promise<T> {
  try {
    return await ctx.run(stepName, fn);
  } catch (err) {
    const original = err instanceof Error ? err : new Error(String(err));
    captureError(original, {
      workflowRunId: ctx.key,
      eventUrl,
      step: stepName,
    });
    // Enrich the error message with URL context so downstream handlers
    // (Directus error records, logs) always show which URL failed.
    const enriched = new Error(`[${eventUrl}] ${stepName}: ${original.message}`);
    enriched.cause = original;
    (enriched as any).stepName = stepName;
    throw enriched;
  }
}

export function computeTranslationStatus(
  translations: DirectusEventTranslation[],
): "complete" | "partial" | "missing" {
  const codes = translations.map((t) => t.languages_code);
  const hasCs = codes.includes("cs");
  const hasEn = codes.includes("en");
  const hasEs = codes.includes("es");
  if (hasCs && hasEn && hasEs) return "complete";
  if (hasCs || hasEn || hasEs) return "partial";
  return "missing";
}

export const eventWorkflow = restate.workflow({
  name: "EventWorkflow",
  handlers: {
    run: async (ctx: restate.WorkflowContext, eventUrl: string) => {
      ctx.set("url", eventUrl);
      ctx.set("status", "started");

      try {
      return await runWorkflow(ctx, eventUrl);
      } catch (err) {
        // Track the failure in Directus so the batch service can observe it
        // without needing to await the fire-and-forget workflowSendClient call.
        // createError handles upsert — inserts new or updates existing row for this URL.
        const message = err instanceof Error ? err.message : String(err);
        const stepName = (err as any)?.stepName ?? "unknown";
        const errorType = classifyErrorType(stepName, message);
        await ctx.run("createError", () =>
          createError({
            url: eventUrl,
            message,
            type: errorType,
          })
        );
        throw err;
      }
    },
  },
});

async function runWorkflow(ctx: restate.WorkflowContext, eventUrl: string) {
      // Step 1: Scrape event
      const facebookEvent = await runStep(ctx, "scrape", eventUrl, () => scrapeEvent(eventUrl));
      ctx.set("status", "scraped");

      // Step 1b: Early validation — reject events with invalid startTimestamp before
      // any LLM or external API calls to avoid wasting resources.
      if (facebookEvent.startTimestamp <= 0) {
        throw new restate.TerminalError(
          `[${eventUrl}] Invalid startTimestamp: value must be positive`,
        );
      }

      // Step 1c: Early duplicate check — run right after scraping to avoid
      // wasting LLM calls and external API requests on events we already have.
      const originalUrl = normalizeEventUrl(facebookEvent.url);
      const existing = await runStep(ctx, "checkDuplicate", originalUrl, () =>
        findEventByOriginalUrl(originalUrl)
      );
      if (existing) {
        ctx.set("status", "duplicate");
        log({ level: "info", message: "Event already exists, skipping", url: originalUrl });
        return existing;
      }

      // Step 2: Classify event type
      const description = facebookEvent.description ?? facebookEvent.name;
      const eventType = await runStep(ctx, "classify", eventUrl, () => classifyEventType(description));

      // Step 3: Skip if unsupported type — save to skipped_events so we never
      // scrape/classify this URL again in future batch runs.
      if (!(SUPPORTED_EVENT_TYPES as readonly string[]).includes(eventType)) {
        const skipReason = `Unsupported event type: ${eventType}`;
        await runStep(ctx, "createSkipped", eventUrl, () =>
          createSkippedEvent({
            original_url: normalizeEventUrl(facebookEvent.url),
            reason: skipReason,
            event_type: eventType,
          })
        );
        ctx.set("status", "skipped");
        ctx.set("skipReason", skipReason);
        log({ level: "info", message: `Skipping event: unsupported type "${eventType}"`, url: eventUrl, reason: skipReason });
        return { status: "skipped" as const, reason: skipReason };
      }

      // Step 4: Route course/lesson types to course workflow
      if (eventType === "course" || eventType === "lesson") {
        return runCourseWorkflow(ctx, eventUrl, facebookEvent, originalUrl, eventType);
      }

      // Compute event times early — needed by parts extraction for date context
      const startTimeUtc = toIsoOrNull(facebookEvent.startTimestamp) as string;
      const endTimeUtc = toIsoOrNull(facebookEvent.endTimestamp ?? undefined);
      const eventTimezone = facebookEvent.timezone ?? "UTC";
      const startTime = convertToLocalTime(startTimeUtc, eventTimezone);
      const endTime = endTimeUtc ? convertToLocalTime(endTimeUtc, eventTimezone) : null;

      // Fetch dance style codes (cached per batch run) for prompt injection and validation
      const danceStyleCodes = await ctx.run("getDanceStyleCodes", () => getDanceStyleCodes());

      // Step 4: Extract event parts (Czech output)
      // If extraction fails after retries, continue with empty parts and mark as incomplete.
      let extracted: { title: string; description: string; parts: import("../core/schemas").EventPart[] };
      let partsIncomplete = false;
      try {
        extracted = await runStep(ctx, "extractParts", eventUrl, () =>
          extractEventParts(description, startTime, endTime, danceStyleCodes)
        );
      } catch (err) {
        log({ level: "warn", message: "extractParts failed, continuing with empty parts", url: eventUrl, error: String(err) });
        extracted = { title: facebookEvent.name, description: description, parts: [] };
        partsIncomplete = true;
      }

      // Step 5: Extract event info
      // If extraction fails after retries, continue with empty info and mark as incomplete.
      let info: import("../core/schemas").EventInfo[];
      let infoIncomplete = false;
      try {
        info = await runStep(ctx, "extractInfo", eventUrl, () => extractEventInfo(description));
      } catch (err) {
        log({ level: "warn", message: "extractInfo failed, continuing with empty info", url: eventUrl, error: String(err) });
        info = [];
        infoIncomplete = true;
      }

      const isIncomplete = partsIncomplete || infoIncomplete;

      // Step 6: Resolve venue
      let venue = null;
      if (facebookEvent.location) {
        venue = await runStep(ctx, "resolveVenue", eventUrl, () => resolveVenue(facebookEvent.location!));
        if (venue !== null && venue.id === undefined) {
          log({
            level: "warn",
            message: "resolveVenue returned a venue without an id for event — venue association will be stored as null. This may indicate a Directus API issue.",
            url: eventUrl,
          });
        }
      }

      // Step 7: Derive organizer
      const organizer = facebookEvent.hosts?.[0]?.name ?? facebookEvent.name;

      // Step 8: Translate to EN and ES
      const contentInput = {
        title: extracted.title,
        description: extracted.description,
        parts: extracted.parts,
        info,
      };

      const translations: DirectusEventTranslation[] = [
        {
          languages_code: "cs",
          title: extracted.title,
          description: extracted.description,
          parts_translations: extracted.parts.map((p) => ({
            name: p.name,
            description: p.description,
          })),
          info_translations: info.map((i) => ({ key: i.key })),
        },
      ];

      const translationLanguages = [
        { code: "en", name: "English" },
        { code: "es", name: "Spanish" },
      ];

      for (const lang of translationLanguages) {
        try {
          const translated = await ctx.run(`translate_${lang.code}`, () =>
            translateEventContent(contentInput, lang.name)
          );
          translations.push({
            languages_code: lang.code,
            title: translated.title,
            description: translated.description,
            parts_translations: translated.parts_translations,
            info_translations: translated.info_translations,
          });
        } catch (err) {
          log({ level: "error", message: `Translation to ${lang.code} failed`, url: originalUrl, error: String(err) });
          captureError(err instanceof Error ? err : new Error(String(err)), {
            workflowRunId: ctx.key,
            eventUrl: originalUrl,
            step: `translate_${lang.code}`,
          });
          // Continue with remaining languages
        }
      }

      // Step 9: Compute dances, validate against dance style codes, compute translation_status
      const rawDances = computeDances(extracted.parts);
      const dances = validateDanceCodes(rawDances, danceStyleCodes);
      const translationStatus = computeTranslationStatus(translations);

      // Step 10: Process image with fallback chain
      const primaryDance = dances[0] ?? "";
      const imageResult = await ctx.run("processImage", () =>
        processEventImage(facebookEvent.imageUrl, primaryDance, eventType, extracted.title)
      );

      // Step 11: Build and store event
      const newEvent: DirectusEvent = {
        title: extracted.title,
        original_description: facebookEvent.description ?? "",
        organizer,
        venue: venue?.id ?? null,
        start_time: startTime,
        end_time: endTime,
        timezone: eventTimezone,
        original_url: originalUrl,
        parts: extracted.parts,
        info,
        dances,
        image: imageResult.fileId,
        image_source: imageResult.source,
        event_type: eventType,
        registration_url: info.find((i) => i.type === "url")?.value ?? null,
        status: isIncomplete ? "incomplete" : "published",
        published: true,
        reviewed: false,
        translation_status: translationStatus,
        translations,
      };

      const createdEvent = await runStep(ctx, "createEvent", originalUrl, () => createEvent(newEvent));
      ctx.set("status", "completed");
      ctx.set("eventId", String(createdEvent.id ?? ""));

      return createdEvent;
}

async function runCourseWorkflow(
  ctx: restate.WorkflowContext,
  eventUrl: string,
  facebookEvent: FacebookEvent,
  originalUrl: string,
  eventType: string,
) {
  // Duplicate check for courses
  const existingCourse = await runStep(ctx, "checkCourseDuplicate", originalUrl, () =>
    findCourseByOriginalUrl(originalUrl)
  );
  if (existingCourse) {
    ctx.set("status", "duplicate");
    log({ level: "info", message: "Course already exists, skipping", url: originalUrl });
    return existingCourse;
  }

  const startTimeUtc = toIsoOrNull(facebookEvent.startTimestamp) as string;
  const endTimeUtc = toIsoOrNull(facebookEvent.endTimestamp ?? undefined);
  const eventTimezone = facebookEvent.timezone ?? "UTC";
  const startTime = convertToLocalTime(startTimeUtc, eventTimezone);
  const endTime = endTimeUtc ? convertToLocalTime(endTimeUtc, eventTimezone) : null;

  const description = facebookEvent.description ?? facebookEvent.name;

  // Fetch dance style codes (cached per batch run)
  const danceStyleCodes = await ctx.run("getCourseStyleCodes", () => getDanceStyleCodes());

  // Extract course data
  const courseData = await runStep(ctx, "extractCourse", eventUrl, () =>
    extractCourseData(description, startTime, endTime, danceStyleCodes)
  );

  // Validate and limit dances (already ordered by LLM relevance)
  const rawDances = courseData.dances.slice(0, 6);
  const dances = validateDanceCodes(rawDances, danceStyleCodes);

  // Resolve venue
  let venue = null;
  if (facebookEvent.location) {
    venue = await runStep(ctx, "resolveCourseVenue", eventUrl, () =>
      resolveVenue(facebookEvent.location!)
    );
    if (venue !== null && venue.id === undefined) {
      log({
        level: "warn",
        message: "resolveVenue returned a venue without an id for course — venue association will be stored as null.",
        url: eventUrl,
      });
    }
  }

  // Derive organizer (fallback for instructor name)
  const organizer = facebookEvent.hosts?.[0]?.name ?? facebookEvent.name;

  // Build course translations (source language: Czech)
  const courseTranslations: Array<{
    languages_code: string;
    title: string;
    description: string;
    learning_items: string[];
  }> = [
    {
      languages_code: "cs",
      title: courseData.title,
      description: courseData.description,
      learning_items: courseData.learning_items,
    },
  ];

  const translationLanguages = [
    { code: "en", name: "English" },
    { code: "es", name: "Spanish" },
  ];

  for (const lang of translationLanguages) {
    try {
      const translated = await ctx.run(`translateCourse_${lang.code}`, () =>
        translateCourseContent(
          {
            title: courseData.title,
            description: courseData.description,
            learning_items: courseData.learning_items,
          },
          lang.name,
        )
      );
      courseTranslations.push({
        languages_code: lang.code,
        title: translated.title,
        description: translated.description,
        learning_items: translated.learning_items,
      });
    } catch (err) {
      log({
        level: "error",
        message: `Course translation to ${lang.code} failed`,
        url: originalUrl,
        error: String(err),
      });
      captureError(err instanceof Error ? err : new Error(String(err)), {
        workflowRunId: ctx.key,
        eventUrl: originalUrl,
        step: `translateCourse_${lang.code}`,
      });
    }
  }

  // Process image with fallback chain
  const primaryDance = dances[0] ?? "";
  const imageResult = await ctx.run("processCourseImage", () =>
    processEventImage(facebookEvent.imageUrl, primaryDance, eventType, courseData.title)
  );

  // Compute translation status
  const courseCodes = courseTranslations.map((t) => t.languages_code);
  const hasCs = courseCodes.includes("cs");
  const hasEn = courseCodes.includes("en");
  const hasEs = courseCodes.includes("es");
  const translationStatus: "complete" | "partial" | "missing" =
    hasCs && hasEn && hasEs ? "complete" : hasCs || hasEn || hasEs ? "partial" : "missing";

  // Build course object
  const newCourse: DirectusCourse = {
    title: courseData.title,
    description: courseData.description,
    instructor_name: courseData.instructor_name ?? organizer,
    venue: venue?.id ?? null,
    start_date: startTime ? startTime.split("T")[0] : null,
    end_date: endTime ? endTime.split("T")[0] : null,
    schedule_day: courseData.schedule_day,
    schedule_time: courseData.schedule_time,
    lesson_count: courseData.lesson_count,
    lesson_duration_minutes: courseData.lesson_duration_minutes,
    max_participants: courseData.max_participants,
    current_participants: 0,
    price: courseData.price,
    price_note: courseData.price_note,
    level: courseData.level,
    dances,
    image: imageResult.fileId,
    image_source: imageResult.source,
    original_url: originalUrl,
    registration_url: courseData.registration_url,
    original_description: facebookEvent.description ?? "",
    status: "published",
    published: true,
    reviewed: false,
    translation_status: translationStatus,
    translations: courseTranslations,
  };

  const createdCourse = await runStep(ctx, "createCourse", originalUrl, () => createCourse(newCourse));
  ctx.set("status", "completed");
  ctx.set("courseId", String(createdCourse.id ?? ""));

  return createdCourse;
}

export type EventWorkflow = typeof eventWorkflow;
