import { z } from "zod";
import { log } from "./logger";

// ---- Facebook schemas ----

// Inner schema for a single Facebook event object.
const FacebookEventObjectSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string().optional(),
  startTimestamp: z.number(),
  // Transform: values <= 0 are treated as null (same rule as toIsoOrNull).
  // Facebook never schedules events at Unix epoch; a zero/negative timestamp
  // means unset/invalid data. This encodes the constraint at the schema level
  // so consumers receive null rather than a misleading zero.
  endTimestamp: z
    .number()
    .nullable()
    .optional()
    .transform((ts) => (ts !== null && ts !== undefined && ts <= 0 ? null : ts)),
  timezone: z.string().optional(),
  location: z
    .object({
      name: z.string().nullable().optional().transform((v) => v ?? undefined),
      address: z.string().nullable().optional().transform((v) => v ?? undefined),
      // Facebook sometimes returns city as an object (e.g. { name: "Prague", id: "123" }),
      // a plain string, or null. We normalise it to a string | undefined here.
      city: z
        .union([
          z.string(),
          z.object({ name: z.string() }).transform((obj) => obj.name),
          z.null().transform(() => undefined),
          z.object({}).transform(() => undefined),
        ])
        .optional(),
      country: z.string().nullable().optional().transform((v) => v ?? undefined),
      // NOTE: design specifies only `country`, but Facebook returns `countryCode`
      // (ISO alpha-2 code). Implementation uses countryCode which is more precise
      // and correct for the venue-resolver mapping. This is an intentional improvement.
      // Facebook can also return null explicitly, so we accept and coerce it.
      countryCode: z
        .string()
        .nullable()
        .optional()
        .transform((v) => v ?? undefined),
      // Facebook nests lat/lng inside a `coordinates` object. We accept both
      // flat (latitude/longitude directly on location) and nested formats.
      latitude: z.number().optional(),
      longitude: z.number().optional(),
      coordinates: z
        .object({
          latitude: z.number().optional(),
          longitude: z.number().optional(),
        })
        .nullable()
        .optional(),
    })
    .nullable()
    .optional()
    // Flatten coordinates into top-level latitude/longitude when present.
    .transform((loc) => {
      if (!loc) return loc;
      const { coordinates, ...rest } = loc;
      return {
        ...rest,
        latitude: rest.latitude ?? coordinates?.latitude,
        longitude: rest.longitude ?? coordinates?.longitude,
      };
    }),
  hosts: z
    .array(
      z.object({
        name: z.string(),
        id: z.string(),
        url: z.string().nullable().optional().transform((v) => v ?? ""),
        type: z.string(),
      })
    )
    .optional(),
  url: z.string(),
  // Facebook provides a direct ticket/registration URL when the organizer sets one.
  // This takes priority over any URL extracted from the description by the LLM.
  ticketUrl: z.string().nullable().optional(),
  // The scraper returns the cover image in `photo.imageUri`, not as a top-level `imageUrl`.
  // Accept both formats: direct `imageUrl` string or nested `photo.imageUri`.
  imageUrl: z.string().nullable().optional(),
  photo: z.object({
    imageUri: z.string().nullable().optional(),
  }).nullable().optional(),
}).transform((event) => ({
  ...event,
  imageUrl: event.imageUrl ?? event.photo?.imageUri ?? null,
}));

// The scraper API wraps the event in a `{ payload: ... }` envelope.
// Accept both the wrapped and unwrapped formats for resilience.
export const FacebookEventSchema = z
  .union([
    z.object({ payload: FacebookEventObjectSchema }).transform((d) => d.payload),
    FacebookEventObjectSchema,
  ]);

export type FacebookEvent = z.infer<typeof FacebookEventSchema>;
export type FacebookLocation = NonNullable<FacebookEvent["location"]>;

// ---- Facebook event list item schema ----
// scrapeFbEventList returns a simpler object than scrapeFbEvent.
// It only contains { id, name, url, date, isCanceled, isPast }.
// This schema is used by scrapeEventList (batch processing) where
// only id and url are needed to schedule individual EventWorkflows.

export const FacebookEventListItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  url: z.string(),
  date: z.string().optional(),
  isCanceled: z.boolean().optional(),
  isPast: z.boolean().optional(),
});

export type FacebookEventListItem = z.infer<typeof FacebookEventListItemSchema>;

// ---- Event type ----

export const SUPPORTED_EVENT_TYPES = ["party", "workshop", "festival", "holiday", "course", "lesson"] as const;
const ALL_EVENT_TYPES = ["party", "workshop", "lesson", "course", "festival", "holiday", "other"] as const;

export const EventTypeSchema = z.enum(ALL_EVENT_TYPES);
export type EventType = z.infer<typeof EventTypeSchema>;

export function parseEventType(value: string): EventType {
  const parsed = EventTypeSchema.safeParse(value.toLowerCase().trim());
  return parsed.success ? parsed.data : "other";
}

// ---- EventPart ----

export const EventPartSchema = z.object({
  name: z.string(),
  description: z.string(),
  type: z.enum(["party", "workshop", "openLesson"]),
  dances: z.array(z.string()),
  date_time_range: z.object({
    start: z.string().nullable().optional(),
    end: z.string().nullable().optional(),
  }),
  lectors: z.array(z.string()),
  djs: z.array(z.string()),
});

export type EventPart = z.infer<typeof EventPartSchema>;

// ---- EventInfo ----

export const EventInfoSchema = z.object({
  type: z.enum(["url", "price", "dresscode"]),
  key: z.string().min(1),
  value: z.string().min(1),
});

export type EventInfo = z.infer<typeof EventInfoSchema>;

export function filterEventInfo(items: unknown[]): EventInfo[] {
  return items
    .map((item) => {
      const result = EventInfoSchema.safeParse(item);
      if (!result.success) {
        log({ level: "warn", message: "filterEventInfo: dropping item that failed validation", item, error: result.error.message });
      }
      return result;
    })
    .filter((result): result is { success: true; data: EventInfo } => result.success)
    .map((result) => result.data)
    .filter((item) => item.value !== "" && item.value !== null);
}

export function computeDances(parts: EventPart[]): string[] {
  const seen = new Set<string>();
  const ordered: string[] = [];
  for (const part of parts) {
    for (const dance of part.dances) {
      if (!seen.has(dance)) {
        seen.add(dance);
        ordered.push(dance);
      }
    }
  }
  return ordered.slice(0, 6);
}

// ---- Directus schemas ----

export const DirectusEventTranslationSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  events_id: z.union([z.number(), z.string()]).optional(),
  languages_code: z.string(),
  title: z.string(),
  description: z.string(),
  parts_translations: z.array(z.object({ name: z.string(), description: z.string() })),
  info_translations: z.array(z.object({ key: z.string() })),
});

export type DirectusEventTranslation = z.infer<typeof DirectusEventTranslationSchema>;

export const DirectusVenueSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  name: z.string(),
  street: z.string(),
  number: z.string(),
  town: z.string(),
  country: z.string(),
  postal_code: z.string(),
  region: z.string(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
});

export type DirectusVenue = z.infer<typeof DirectusVenueSchema>;

export const DirectusEventSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  title: z.string().optional(),
  original_description: z.string(),
  organizer: z.string(),
  // Directus may return venue as an ID (number/string) or as an expanded object
  // when queried with fields=*,venue.*
  venue: z.union([z.number(), z.string(), DirectusVenueSchema]).nullable().optional(),
  start_time: z.string(),
  end_time: z.string().nullable().optional(),
  timezone: z.string(),
  original_url: z.string(),
  parts: z.array(EventPartSchema),
  info: z.array(EventInfoSchema),
  dances: z.array(z.string()),
  image: z.union([z.number(), z.string()]).nullable().optional(),
  image_source: z.string().nullable().optional(),
  event_type: z.string().nullable().optional(),
  registration_url: z.string().nullable().optional(),
  status: z.enum(["published", "draft", "archived", "incomplete"]).optional(),
  published: z.boolean().default(true),
  reviewed: z.boolean().default(false),
  price: z.string().nullable().optional(),
  additional_info: z.array(z.object({ key: z.string(), value: z.string() })).nullable().optional(),
  translation_status: z.enum(["complete", "partial", "missing"]).optional(),
  // Directus returns translations as full objects when expanded (?fields=*.*),
  // but as an array of IDs (numbers/strings) when not expanded. Accept both.
  translations: z
    .array(
      z.union([
        DirectusEventTranslationSchema,
        z.number(),
        z.string(),
      ])
    )
    .optional(),
});

export type DirectusEvent = z.infer<typeof DirectusEventSchema>;

export const DirectusLanguageSchema = z.object({
  code: z.string(),
  name: z.string(),
});

export type DirectusLanguage = z.infer<typeof DirectusLanguageSchema>;

export const DirectusGroupSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  url: z.string(),
  type: z.string().optional(),
  updated_at: z.string().nullable().optional(),
});

export type DirectusGroup = z.infer<typeof DirectusGroupSchema>;

export const ERROR_TYPES = [
  "scrape_failed",       // Scraper returned no data / page not found
  "parse_failed",        // Scraper returned data but it couldn't be parsed (Zod/JSON)
  "llm_parse_failed",    // LLM returned invalid output after retries
  "workflow_failed",     // General workflow step failure
  "schedule_failed",     // Failed to schedule a workflow in Restate
  "unknown",             // Uncategorized error
] as const;

export type ErrorType = (typeof ERROR_TYPES)[number];

export const DirectusErrorSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  url: z.string(),
  message: z.string(),
  type: z.string().optional(),
  datetime: z.string(),
});

export type DirectusError = z.infer<typeof DirectusErrorSchema>;

// ---- Skipped events ----

export const DirectusSkippedEventSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  original_url: z.string(),
  reason: z.string(),
  event_type: z.string(),
  datetime: z.string(),
});

export type DirectusSkippedEvent = z.infer<typeof DirectusSkippedEventSchema>;

// ---- Nominatim schema ----

export const NominatimResponseSchema = z.object({
  display_name: z.string().optional(),
  address: z
    .object({
      road: z.string().optional(),
      house_number: z.string().optional(),
      city: z.string().optional(),
      town: z.string().optional(),
      village: z.string().optional(),
      county: z.string().optional(),
      state: z.string().optional(),
      country: z.string().optional(),
      country_code: z.string().optional(),
      postcode: z.string().optional(),
    })
    .optional(),
});

export type NominatimResponse = z.infer<typeof NominatimResponseSchema>;

// ---- Date/time utilities ----

export function toIsoOrNull(timestamp: number | null | undefined): string | null {
  // Treating 0 and negative values as null is intentional: Requirement 1.4 says
  // null/missing/invalid timestamps map to null. While 0 (Unix epoch) is technically
  // valid, Facebook never schedules events at 1970-01-01T00:00:00Z — a zero timestamp
  // is always invalid/unset data in practice. This is a documented practical decision.
  if (timestamp === null || timestamp === undefined || timestamp <= 0) return null;
  try {
    const d = new Date(timestamp * 1000);
    if (isNaN(d.getTime())) return null;
    return d.toISOString();
  } catch {
    return null;
  }
}

// ---- Course schemas ----

export const CourseExtractionSchema = z.object({
  title: z.string(),
  description: z.string(),
  instructor_name: z.string().nullable(),
  level: z.enum(["beginner", "intermediate", "advanced", "all_levels"]).default("all_levels"),
  schedule_day: z.string().nullable(),
  schedule_time: z.string().nullable(),
  lesson_count: z.number().int().positive().nullable(),
  lesson_duration_minutes: z.number().int().positive().nullable(),
  max_participants: z.number().int().positive().nullable(),
  price: z.string().nullable(),
  price_note: z.string().nullable(),
  learning_items: z.array(z.string()),
  registration_url: z.string().nullable(),
  dances: z.array(z.string()),
});

export type CourseExtraction = z.infer<typeof CourseExtractionSchema>;

export const DirectusCourseTranslationSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  courses_id: z.union([z.number(), z.string()]).optional(),
  languages_code: z.string(),
  title: z.string().optional(),
  description: z.string().optional(),
  learning_items: z.array(z.string()).optional(),
});

export type DirectusCourseTranslation = z.infer<typeof DirectusCourseTranslationSchema>;

export const DirectusCourseSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  title: z.string().optional(),
  description: z.string().optional(),
  instructor_name: z.string().nullable().optional(),
  instructor_bio: z.string().nullable().optional(),
  instructor_avatar_url: z.string().nullable().optional(),
  venue: z.union([z.number(), z.string(), DirectusVenueSchema]).nullable().optional(),
  start_date: z.string().nullable().optional(),
  end_date: z.string().nullable().optional(),
  schedule_day: z.string().nullable().optional(),
  schedule_time: z.string().nullable().optional(),
  lesson_count: z.number().nullable().optional(),
  lesson_duration_minutes: z.number().nullable().optional(),
  max_participants: z.number().nullable().optional(),
  current_participants: z.number().optional(),
  price: z.string().nullable().optional(),
  price_note: z.string().nullable().optional(),
  level: z.string().nullable().optional(),
  dances: z.array(z.string()).optional(),
  image: z.union([z.number(), z.string()]).nullable().optional(),
  image_source: z.string().nullable().optional(),
  original_url: z.string().nullable().optional(),
  registration_url: z.string().nullable().optional(),
  original_description: z.string().nullable().optional(),
  status: z.enum(["published", "draft", "archived"]).optional(),
  published: z.boolean().default(true),
  reviewed: z.boolean().default(false),
  translation_status: z.enum(["complete", "partial", "missing"]).optional(),
  translations: z.array(z.union([z.any(), z.number(), z.string()])).optional(),
});

export type DirectusCourse = z.infer<typeof DirectusCourseSchema>;

// ---- Dance style schemas ----

export const DirectusDanceStyleSchema = z.object({
  code: z.string(),
  name: z.string(),
  parent_code: z.string().nullable().optional(),
  sort_order: z.number().optional(),
});

export type DirectusDanceStyle = z.infer<typeof DirectusDanceStyleSchema>;

// ---- Favorites schema ----

export const DirectusFavoriteSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  user_id: z.string(),
  item_type: z.enum(["event", "course"]),
  item_id: z.number(),
  created_at: z.string().optional(),
});

export type DirectusFavorite = z.infer<typeof DirectusFavoriteSchema>;

/**
 * Returns all dance style codes that match the given parent code:
 * the parent code itself plus any direct child codes.
 *
 * Used to implement Requirement 8.5: filtering events/courses by a parent
 * dance style should include items tagged with the parent OR any of its children.
 */
export function getChildStyleCodes(
  parentCode: string,
  styles: { code: string; parent_code?: string | null }[],
): string[] {
  const childCodes = styles
    .filter((s) => s.parent_code === parentCode)
    .map((s) => s.code);
  return [parentCode, ...childCodes];
}

// ---- JSON parsing ----

export function parseJsonResponse(raw: string): unknown {
  // Find the first code fence block anywhere in the response (LLMs may return
  // explanatory text before the fence, or use leading whitespace/newlines).
  const fenceMatch = raw.match(/```(?:json)?\s*\n?([\s\S]*?)\n?\s*```/i);
  if (fenceMatch) {
    return JSON.parse(fenceMatch[1].trim());
  }
  return JSON.parse(raw.trim());
}
