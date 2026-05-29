import * as restate from "@restatedev/restate-sdk";
import { z } from "zod";
import { listPublishedEvents, findEventByOriginalUrl, getEventById, updateEvent, deleteEventTranslations, createError, getDanceStyleCodes, listPublishedCourses, createFavorite, deleteFavorite, listFavorites, listDanceStyles, getCourseById, updateCourse } from "../clients/directus-client";
import { scrapeEvent } from "../clients/scraper-client";
import { config, captureError } from "../core/config";
import { log } from "../core/logger";
import { normalizeEventUrl } from "../core/utils";
import { extractEventParts, extractEventInfo, validateDanceCodes } from "./event-parser";
import { translateEventContent, translateCourseContent } from "./event-translator";
import { computeDances } from "../core/schemas";
import { computeTranslationStatus, processEventPipeline } from "./workflow";
import type { DirectusEventTranslation, DirectusCourseTranslation, DirectusFavorite } from "../core/schemas";
import type { EventWorkflow } from "./workflow";
import type { BatchService } from "./batch";

export const corsOrigins = config.corsOrigins;

// Only these top-level filter fields are allowed from client input.
// This prevents clients from crafting filters that bypass the published-only
// restriction or target internal/sensitive fields (e.g. status, translations).
const ALLOWED_FILTER_FIELDS = new Set([
  "dances",
  "start_time",
  "end_time",
  "venue",
  "organizer",
  "translation_status",
]);

const ALLOWED_COURSE_FILTER_FIELDS = new Set([
  "dances",
  "start_date",
  "end_date",
  "venue",
  "level",
  "translation_status",
]);

/**
 * Strips any filter keys that are not in the allowed set.
 * Returns undefined if no valid keys remain.
 */
export function sanitizeFilter(
  raw: Record<string, unknown>,
): Record<string, unknown> | undefined {
  const sanitized: Record<string, unknown> = {};
  for (const key of Object.keys(raw)) {
    if (ALLOWED_FILTER_FIELDS.has(key)) {
      sanitized[key] = raw[key];
    } else {
      log({ level: "warn", message: `sanitizeFilter: dropping disallowed filter field "${key}"` });
    }
  }
  return Object.keys(sanitized).length > 0 ? sanitized : undefined;
}

export const apiService = restate.service({
  name: "ApiService",
  handlers: {
    processEvent: async (
      ctx: restate.Context,
      request: { url?: string },
    ) => {
      if (!request?.url) {
        throw new restate.TerminalError(
          "Missing required field: 'url'",
          { errorCode: 400 },
        );
      }

      const normalizedUrl = normalizeEventUrl(request.url);
      const workflowKey = normalizedUrl
        .replace(/[^a-zA-Z0-9]/g, "_")
        .slice(0, 128);

      const wfClient = ctx.workflowClient<EventWorkflow>({ name: "EventWorkflow" }, workflowKey);

      try {
        const result = await wfClient.run(request.url);
        return result;
      } catch (err) {
        // 409 means the workflow was already invoked with this key.
        // Look up the event in Directus instead of failing.
        if (err instanceof restate.TerminalError && err.code === 409) {
          log({ level: "info", message: "Workflow already invoked, checking Directus for existing event", url: request.url });
          const existing = await ctx.run("lookupExisting", () =>
            findEventByOriginalUrl(normalizedUrl)
          );
          if (existing) {
            return existing;
          }
          // Workflow ran but event not in Directus (maybe it was skipped or failed)
          return { status: "already_processing" as const, url: request.url };
        }
        // Log the failure to Directus so it shows up in the errors table
        const error = err instanceof Error ? err : new Error(String(err));
        captureError(error, { url: normalizedUrl, step: "processEvent" });
        await ctx.run("createError", () =>
          createError({ url: normalizedUrl, message: error.message, type: "workflow_failed" })
        );
        throw err;
      }
    },

    processBatch: async (ctx: restate.Context) => {
      ctx
        .serviceSendClient<BatchService>({ name: "BatchService" })
        .processAll();

      return { acknowledged: true, message: "Batch processing started" };
    },

    processGroup: async (
      ctx: restate.Context,
      request: { url?: string },
    ) => {
      if (!request?.url) {
        throw new restate.TerminalError("Missing required field: 'url'", { errorCode: 400 });
      }

      ctx
        .serviceSendClient<BatchService>({ name: "BatchService" })
        .processSingle(request.url);

      return { acknowledged: true, message: `Processing group: ${request.url}` };
    },

    reprocessEvent: async (
      ctx: restate.Context,
      request: { id?: string | number; translationId?: string | number; steps?: string[]; lang?: string },
    ) => {
      // Support calling from events_translations detail: look up parent event
      let eventId = request.id;
      let targetLang = request.lang;

      if (!eventId && request.translationId) {
        const trData = await ctx.run("getTranslation", async () => {
          const res = await fetch(
            `${config.directusBaseUrl}/items/events_translations/${request.translationId}?fields=events_id,languages_code`,
            { headers: { Authorization: `Bearer ${config.directusAccessToken}`, "Content-Type": "application/json" } },
          );
          if (!res.ok) return null;
          const json = await res.json() as { data: { events_id: number | string; languages_code: string } };
          return json.data;
        });
        if (!trData) {
          throw new restate.TerminalError(`Translation ${request.translationId} not found`, { errorCode: 404 });
        }
        eventId = trData.events_id;
        targetLang = targetLang ?? trData.languages_code;
      }

      if (!eventId) {
        throw new restate.TerminalError("Missing required field: 'id' or 'translationId'", { errorCode: 400 });
      }

      const validSteps = ["parts", "info", "translations", "dances"];
      const steps = request.steps?.length
        ? request.steps.filter((s) => validSteps.includes(s))
        : validSteps; // default: reprocess everything

      if (steps.length === 0) {
        throw new restate.TerminalError(
          `Invalid steps. Valid values: ${validSteps.join(", ")}`,
          { errorCode: 400 },
        );
      }

      const event = await ctx.run("getEvent", () => getEventById(eventId!));
      if (!event) {
        throw new restate.TerminalError(`Event ${eventId} not found`, { errorCode: 404 });
      }

      const description = event.original_description;
      const eventUrl = event.original_url ?? `event:${eventId}`;
      const patch: Record<string, unknown> = {};

      // Fetch dance style codes for validation (used in parts and dances steps)
      const danceStyleCodes = await ctx.run("getDanceStyleCodes", () => getDanceStyleCodes());

      // Re-extract parts
      let parts = event.parts;
      let title = event.title;
      if (steps.includes("parts")) {
        try {
          const extracted = await ctx.run("extractParts", () => extractEventParts(description, event.start_time, event.end_time ?? null, danceStyleCodes));
          parts = extracted.parts;
          title = extracted.title;
          patch.parts = extracted.parts;
          patch.title = extracted.title;
        } catch (err) {
          const error = err instanceof Error ? err : new Error(String(err));
          captureError(error, { eventUrl, step: "reprocess:extractParts" });
          await ctx.run("extractPartsError", () =>
            createError({ url: eventUrl, message: `Reprocess extractParts failed: ${error.message}`, type: "llm_parse_failed" })
          );
          throw err;
        }
      }

      // Re-extract info
      let info = event.info;
      if (steps.includes("info")) {
        try {
          const newInfo = await ctx.run("extractInfo", () => extractEventInfo(description));
          info = newInfo;
          patch.info = newInfo;
        } catch (err) {
          const error = err instanceof Error ? err : new Error(String(err));
          captureError(error, { eventUrl, step: "reprocess:extractInfo" });
          await ctx.run("extractInfoError", () =>
            createError({ url: eventUrl, message: `Reprocess extractInfo failed: ${error.message}`, type: "llm_parse_failed" })
          );
          throw err;
        }
      }

      // Recompute dances from parts and validate against known dance style codes
      if (steps.includes("dances") || steps.includes("parts")) {
        const rawDances = computeDances(parts);
        patch.dances = validateDanceCodes(rawDances, danceStyleCodes);
      }

      // Re-translate
      if (steps.includes("translations")) {
        // Find existing Czech translation for the description base
        const existingCs = Array.isArray(event.translations)
          ? event.translations.find(
              (t) => typeof t === "object" && t !== null && "languages_code" in t &&
                (t as { languages_code: string }).languages_code === "cs",
            )
          : undefined;
        const csDescription = existingCs && typeof existingCs === "object" && "description" in existingCs
          ? (existingCs as { description: string }).description
          : description;

        const contentInput = {
          title: title ?? "",
          description: csDescription,
          parts,
          info,
        };

        const translations: DirectusEventTranslation[] = [];

        const allLangs = [
          { code: "cs", name: "Czech" },
          { code: "en", name: "English" },
          { code: "es", name: "Spanish" },
        ];

        const langs = targetLang
          ? allLangs.filter((l) => l.code === targetLang)
          : allLangs;

        if (langs.length === 0) {
          throw new restate.TerminalError(
            `Invalid lang: ${targetLang}. Valid values: cs, en, es`,
            { errorCode: 400 },
          );
        }

        for (const lang of langs) {
          try {
            const translated = await ctx.run(`translate_${lang.code}`, () =>
              translateEventContent(contentInput, lang.name),
            );
            translations.push({
              languages_code: lang.code,
              title: translated.title,
              description: translated.description,
              parts_translations: translated.parts_translations,
              info_translations: translated.info_translations,
            });
          } catch (err) {
            log({ level: "error", message: `Reprocess: translation to ${lang.code} failed`, error: String(err) });
          }
        }

        // Map new translations onto existing translation IDs so Directus
        // updates in place instead of creating duplicates.
        const idByLang = new Map<string, number | string>();
        if (Array.isArray(event.translations)) {
          for (const t of event.translations) {
            if (typeof t === "object" && t !== null && "languages_code" in t && "id" in t) {
              const obj = t as { id: number | string; languages_code: string };
              idByLang.set(obj.languages_code, obj.id);
            }
          }
        }

        patch.translations = translations.map((t) => ({
          ...t,
          ...(idByLang.has(t.languages_code) ? { id: idByLang.get(t.languages_code) } : {}),
        }));
        patch.translation_status = computeTranslationStatus(translations);
      }

      const updated = await ctx.run("updateEvent", () => updateEvent(eventId!, patch));
      return updated;
    },

    forceReprocessEvent: async (
      ctx: restate.Context,
      request: { id?: string | number },
    ) => {
      if (!request?.id) {
        throw new restate.TerminalError("Missing required field: 'id'", { errorCode: 400 });
      }

      // Step 1: Load existing event from Directus
      const event = await ctx.run("getEvent", () => getEventById(request.id!));
      if (!event) {
        throw new restate.TerminalError(`Event ${request.id} not found`, { errorCode: 404 });
      }

      const eventUrl = event.original_url;
      if (!eventUrl) {
        throw new restate.TerminalError(`Event ${request.id} has no original_url`, { errorCode: 400 });
      }

      // Step 2: Re-scrape from Facebook
      const facebookEvent = await ctx.run("scrape", () => scrapeEvent(eventUrl));

      if (facebookEvent.startTimestamp <= 0) {
        throw new restate.TerminalError(
          `Invalid startTimestamp from Facebook for event ${request.id}`,
          { errorCode: 422 },
        );
      }

      // Step 3: Run the shared processing pipeline
      const processed = await processEventPipeline(ctx, facebookEvent, eventUrl);

      // Step 4: Map translations onto existing IDs to avoid duplicates
      const idByLang = new Map<string, number | string>();
      if (Array.isArray(event.translations)) {
        for (const t of event.translations) {
          if (typeof t === "object" && t !== null && "languages_code" in t && "id" in t) {
            const obj = t as { id: number | string; languages_code: string };
            idByLang.set(obj.languages_code, obj.id);
          }
        }
      }

      const translationsPatch = processed.translations.map((t) => ({
        ...t,
        ...(idByLang.has(t.languages_code) ? { id: idByLang.get(t.languages_code) } : {}),
      }));

      // Step 5: Build patch and update
      const patch: Record<string, unknown> = {
        title: processed.title,
        original_description: processed.original_description,
        organizer: processed.organizer,
        venue: processed.venue,
        start_time: processed.start_time,
        end_time: processed.end_time,
        timezone: processed.timezone,
        parts: processed.parts,
        info: processed.info,
        dances: processed.dances,
        image: processed.image,
        image_source: processed.image_source,
        event_type: processed.event_type,
        registration_url: processed.registration_url,
        status: "published",
        reviewed: false,
        translation_status: processed.translation_status,
        translations: translationsPatch,
      };

      const updated = await ctx.run("updateEvent", () => updateEvent(request.id!, patch));
      log({ level: "info", message: "forceReprocessEvent completed", eventId: String(request.id), url: eventUrl });
      return updated;
    },

    listCourses: async (ctx: restate.Context) => {
      const filterHeader = ctx.request().headers.get("x-dancee-filter");
      let extraFilter: Record<string, unknown> | undefined;
      if (filterHeader) {
        try {
          const parsed = JSON.parse(filterHeader) as Record<string, unknown>;
          // Sanitize using course-specific allowed fields
          const sanitized: Record<string, unknown> = {};
          for (const key of Object.keys(parsed)) {
            if (ALLOWED_COURSE_FILTER_FIELDS.has(key)) {
              sanitized[key] = parsed[key];
            } else {
              log({ level: "warn", message: `listCourses: dropping disallowed filter field "${key}"` });
            }
          }
          extraFilter = Object.keys(sanitized).length > 0 ? sanitized : undefined;
        } catch {
          log({ level: "warn", message: "listCourses: x-dancee-filter header contains invalid JSON, ignoring filter", header: filterHeader });
        }
      }

      const lang = ctx.request().headers.get("x-dancee-lang");

      const courses = await listPublishedCourses(extraFilter);

      return courses.map((course) => {
        const { translations, ...rest } = course;

        let translatedFields: Record<string, unknown> = {};
        if (lang && Array.isArray(translations)) {
          const match = translations.find(
            (t) => typeof t === "object" && t !== null && "languages_code" in t && t.languages_code === lang,
          );
          if (match && typeof match === "object" && "title" in match) {
            const { languages_code, courses_id, id: _tid, ...fields } = match as Record<string, unknown>;
            translatedFields = fields;
          }
        }

        return {
          ...rest,
          ...translatedFields,
          ...(lang ? {} : { translations }),
        };
      });
    },

    createFavorite: async (
      ctx: restate.Context,
      request: { user_id?: string; item_type?: string; item_id?: number },
    ) => {
      if (!request?.user_id || !request?.item_type || request?.item_id === undefined) {
        throw new restate.TerminalError(
          "Missing required fields: 'user_id', 'item_type', 'item_id'",
          { errorCode: 400 },
        );
      }
      if (request.item_type !== "event" && request.item_type !== "course") {
        throw new restate.TerminalError(
          "Invalid item_type: must be 'event' or 'course'",
          { errorCode: 400 },
        );
      }

      const favorite: DirectusFavorite = {
        user_id: request.user_id,
        item_type: request.item_type as "event" | "course",
        item_id: request.item_id,
      };

      return ctx.run("createFavorite", () => createFavorite(favorite));
    },

    deleteFavorite: async (
      ctx: restate.Context,
      request: { user_id?: string; item_type?: string; item_id?: number },
    ) => {
      if (!request?.user_id || !request?.item_type || request?.item_id === undefined) {
        throw new restate.TerminalError(
          "Missing required fields: 'user_id', 'item_type', 'item_id'",
          { errorCode: 400 },
        );
      }
      if (request.item_type !== "event" && request.item_type !== "course") {
        throw new restate.TerminalError(
          "Invalid item_type: must be 'event' or 'course'",
          { errorCode: 400 },
        );
      }

      await ctx.run("deleteFavorite", () =>
        deleteFavorite(request.user_id!, request.item_type as "event" | "course", request.item_id!)
      );
      return { success: true };
    },

    listFavorites: async (
      ctx: restate.Context,
      request: { user_id?: string },
    ) => {
      if (!request?.user_id) {
        throw new restate.TerminalError(
          "Missing required field: 'user_id'",
          { errorCode: 400 },
        );
      }

      return ctx.run("listFavorites", () => listFavorites(request.user_id!));
    },

    listDanceStyles: async (ctx: restate.Context) => {
      return ctx.run("listDanceStyles", () => listDanceStyles());
    },

    retranslateItem: async (
      ctx: restate.Context,
      request: { itemId?: unknown; itemType?: unknown; sourceLang?: unknown; modifiedTextFields?: unknown },
    ) => {
      const RetranslateRequestSchema = z.object({
        itemId: z.number(),
        itemType: z.enum(["event", "course"]),
        sourceLang: z.enum(["cs", "en", "es"]),
        modifiedTextFields: z.record(z.string()),
      });

      let parsed: z.infer<typeof RetranslateRequestSchema>;
      try {
        parsed = RetranslateRequestSchema.parse(request);
      } catch (err) {
        throw new restate.TerminalError(
          `Invalid request: ${err instanceof Error ? err.message : String(err)}`,
          { errorCode: 400 },
        );
      }

      const { itemId, itemType, sourceLang } = parsed;

      const allLangs = [
        { code: "cs", name: "Czech" },
        { code: "en", name: "English" },
        { code: "es", name: "Spanish" },
      ];
      const targetLangs = allLangs.filter((l) => l.code !== sourceLang);

      if (itemType === "event") {
        const event = await ctx.run("getEvent", () => getEventById(itemId));
        if (!event) {
          throw new restate.TerminalError(`Event ${itemId} not found`, { errorCode: 404 });
        }

        const sourceTrans = Array.isArray(event.translations)
          ? event.translations.find(
              (t) => typeof t === "object" && t !== null && "languages_code" in t &&
                (t as { languages_code: string }).languages_code === sourceLang,
            )
          : undefined;

        const contentInput = {
          title: (sourceTrans && typeof sourceTrans === "object" && "title" in sourceTrans)
            ? String((sourceTrans as { title: unknown }).title ?? "")
            : "",
          description: (sourceTrans && typeof sourceTrans === "object" && "description" in sourceTrans)
            ? String((sourceTrans as { description: unknown }).description ?? "")
            : "",
          parts: event.parts ?? [],
          info: event.info ?? [],
        };

        const idByLang = new Map<string, number | string>();
        if (Array.isArray(event.translations)) {
          for (const t of event.translations) {
            if (typeof t === "object" && t !== null && "languages_code" in t && "id" in t) {
              const obj = t as { id: number | string; languages_code: string };
              idByLang.set(obj.languages_code, obj.id);
            }
          }
        }

        const newTranslations: DirectusEventTranslation[] = [];
        for (const lang of targetLangs) {
          try {
            const translated = await ctx.run(`translate_${lang.code}`, () =>
              translateEventContent(contentInput, lang.name),
            );
            newTranslations.push({
              languages_code: lang.code,
              title: translated.title,
              description: translated.description,
              parts_translations: translated.parts_translations,
              info_translations: translated.info_translations,
            });
          } catch (err) {
            log({ level: "error", message: `retranslateItem: event translation to ${lang.code} failed`, error: String(err) });
          }
        }

        const translationsPatch = newTranslations.map((t) => ({
          ...t,
          ...(idByLang.has(t.languages_code) ? { id: idByLang.get(t.languages_code) } : {}),
        }));

        const sourceTransObj = sourceTrans && typeof sourceTrans === "object" && "languages_code" in sourceTrans
          ? (sourceTrans as DirectusEventTranslation)
          : null;
        const allForStatus: DirectusEventTranslation[] = [
          ...(sourceTransObj ? [sourceTransObj] : []),
          ...newTranslations,
        ];
        const translationStatus = computeTranslationStatus(allForStatus);

        await ctx.run("updateEvent", () => updateEvent(itemId, {
          translations: translationsPatch,
          translation_status: translationStatus,
        }));

      } else {
        const course = await ctx.run("getCourse", () => getCourseById(itemId));
        if (!course) {
          throw new restate.TerminalError(`Course ${itemId} not found`, { errorCode: 404 });
        }

        const sourceTrans = Array.isArray(course.translations)
          ? course.translations.find(
              (t) => typeof t === "object" && t !== null && "languages_code" in t &&
                (t as { languages_code: string }).languages_code === sourceLang,
            )
          : undefined;

        const contentInput = {
          title: (sourceTrans && typeof sourceTrans === "object" && "title" in sourceTrans)
            ? String((sourceTrans as { title: unknown }).title ?? "")
            : "",
          description: (sourceTrans && typeof sourceTrans === "object" && "description" in sourceTrans)
            ? String((sourceTrans as { description: unknown }).description ?? "")
            : "",
          learning_items: (sourceTrans && typeof sourceTrans === "object" && "learning_items" in sourceTrans)
            ? ((sourceTrans as { learning_items?: string[] }).learning_items ?? [])
            : [],
        };

        const idByLang = new Map<string, number | string>();
        if (Array.isArray(course.translations)) {
          for (const t of course.translations) {
            if (typeof t === "object" && t !== null && "languages_code" in t && "id" in t) {
              const obj = t as { id: number | string; languages_code: string };
              idByLang.set(obj.languages_code, obj.id);
            }
          }
        }

        const newTranslations: DirectusCourseTranslation[] = [];
        for (const lang of targetLangs) {
          try {
            const translated = await ctx.run(`translateCourse_${lang.code}`, () =>
              translateCourseContent(contentInput, lang.name),
            );
            newTranslations.push({
              languages_code: lang.code,
              title: translated.title,
              description: translated.description,
              learning_items: translated.learning_items,
            });
          } catch (err) {
            log({ level: "error", message: `retranslateItem: course translation to ${lang.code} failed`, error: String(err) });
          }
        }

        const translationsPatch = newTranslations.map((t) => ({
          ...t,
          ...(idByLang.has(t.languages_code) ? { id: idByLang.get(t.languages_code) } : {}),
        }));

        const sourceTransObj = sourceTrans && typeof sourceTrans === "object" && "languages_code" in sourceTrans
          ? (sourceTrans as DirectusCourseTranslation)
          : null;
        const allForStatus: DirectusEventTranslation[] = [
          ...(sourceTransObj ? [sourceTransObj as unknown as DirectusEventTranslation] : []),
          ...(newTranslations as unknown as DirectusEventTranslation[]),
        ];
        const translationStatus = computeTranslationStatus(allForStatus);

        await ctx.run("updateCourse", () => updateCourse(itemId, {
          translations: translationsPatch,
          translation_status: translationStatus,
        }));
      }

      return { success: true };
    },

    listEvents: async (ctx: restate.Context) => {
      const filterHeader = ctx.request().headers.get("x-dancee-filter");
      let extraFilter: Record<string, unknown> | undefined;
      if (filterHeader) {
        try {
          const parsed = JSON.parse(filterHeader) as Record<string, unknown>;
          extraFilter = sanitizeFilter(parsed);
        } catch {
          log({ level: "warn", message: "listEvents: x-dancee-filter header contains invalid JSON, ignoring filter", header: filterHeader });
        }
      }

      const includeOriginal = ctx.request().headers.get("x-dancee-include") === "original_description";
      const lang = ctx.request().headers.get("x-dancee-lang"); // e.g. "cs", "en", "es"

      const events = await listPublishedEvents(extraFilter);

      return events.map((event) => {
        const { original_description, translations, ...rest } = event;

        // If a language is requested, find the matching translation and flatten
        // its fields (title, description) onto the event object.
        let translatedFields: Record<string, unknown> = {};
        if (lang && Array.isArray(translations)) {
          const match = translations.find(
            (t) => typeof t === "object" && t !== null && "languages_code" in t && t.languages_code === lang,
          );
          if (match && typeof match === "object" && "title" in match) {
            const { languages_code, events_id, id: _tid, ...fields } = match as Record<string, unknown>;
            translatedFields = fields;
          }
        }

        return {
          ...rest,
          ...translatedFields,
          ...(includeOriginal ? { original_description } : {}),
          // Keep translations array only when no specific language is requested
          ...(lang ? {} : { translations }),
        };
      });
    },
  },
});

export type ApiService = typeof apiService;
