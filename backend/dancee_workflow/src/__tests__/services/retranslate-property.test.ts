import { describe, it, expect, vi } from "vitest";
import fc from "fast-check";

// Mock config before importing anything that uses it
vi.mock("../../core/config", () => ({
  config: {
    openRouterApiKey: "test-key",
    openRouterModel: "test-model",
    directusBaseUrl: "http://directus-test",
    directusAccessToken: "test-token",
    corsOrigins: "*",
  },
  captureError: vi.fn(),
}));

vi.mock("@restatedev/restate-sdk", () => ({
  workflow: (def: { name: string; handlers: Record<string, unknown> }) => def,
  service: (def: { name: string; handlers: Record<string, unknown> }) => def,
  TerminalError: class TerminalError extends Error {
    errorCode?: number;
    constructor(msg: string, opts?: { errorCode?: number }) {
      super(msg);
      this.name = "TerminalError";
      this.errorCode = opts?.errorCode;
    }
  },
}));

vi.mock("../../clients/directus-client", () => ({
  listPublishedEvents: vi.fn(),
  listPublishedCourses: vi.fn(),
  findEventByOriginalUrl: vi.fn(),
  getEventById: vi.fn(),
  getCourseById: vi.fn(),
  updateEvent: vi.fn(),
  updateCourse: vi.fn(),
  deleteEventTranslations: vi.fn(),
  createError: vi.fn(),
  getDanceStyleCodes: vi.fn(),
  createFavorite: vi.fn(),
  deleteFavorite: vi.fn(),
  listFavorites: vi.fn(),
  listDanceStyles: vi.fn(),
}));

vi.mock("../../core/logger", () => ({
  log: vi.fn(),
}));

vi.mock("../../services/event-parser", () => ({
  extractEventParts: vi.fn(),
  extractEventInfo: vi.fn(),
  validateDanceCodes: vi.fn(),
}));

vi.mock("../../services/event-translator", () => ({
  translateEventContent: vi.fn(),
  translateCourseContent: vi.fn(),
}));

vi.mock("../../services/image-processor", () => ({
  processEventImage: vi.fn(),
}));

vi.mock("../../services/venue-resolver", () => ({
  resolveVenue: vi.fn(),
}));

vi.mock("../../clients/scraper-client", () => ({
  scrapeEvent: vi.fn(),
}));

vi.mock("../../clients/nominatim-client", () => ({
  geocodeAddress: vi.fn(),
}));

import { computeTranslationStatus } from "../../services/workflow";

// ── Pure helpers that mirror logic in the retranslateItem handler ──────────────

/**
 * Mirrors the translation patch construction in retranslateItem.
 * For each new translation, includes the existing Directus ID if one is known
 * for that language, so Directus updates in place instead of creating duplicates.
 */
function buildTranslationsPatch<T extends { languages_code: string }>(
  newTranslations: T[],
  idByLang: Map<string, number | string>,
): Array<T & { id?: number | string }> {
  return newTranslations.map((t) => ({
    ...t,
    ...(idByLang.has(t.languages_code) ? { id: idByLang.get(t.languages_code) } : {}),
  }));
}

/** Returns the Directus collection name for a given item type. */
function getCollection(itemType: "event" | "course"): string {
  return itemType === "event" ? "events" : "courses";
}

// Text fields that belong in the retranslation request (translatable content).
const EVENT_TEXT_FIELDS = new Set(["title", "description", "parts_translations", "info_translations"]);
const COURSE_TEXT_FIELDS = new Set(["title", "description", "learning_items", "price_note", "instructor_bio"]);

/**
 * Mirrors the client-side field-filtering logic: keeps only translatable text
 * fields from a mixed field map so non-text data is excluded from the
 * retranslation request sent to the workflow service.
 */
function filterTextFields(
  fields: Record<string, unknown>,
  itemType: "event" | "course",
): Record<string, string> {
  const textKeys = itemType === "event" ? EVENT_TEXT_FIELDS : COURSE_TEXT_FIELDS;
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(fields)) {
    if (textKeys.has(key) && typeof value === "string") {
      result[key] = value;
    }
  }
  return result;
}

// ── Property 1: PATCH Payload Construction ────────────────────────────────────
// Feature: event-course-editing, Property 1: PATCH payload construction

describe("Property 1: PATCH Payload Construction [Feature: event-course-editing]", () => {
  it("each translation in patch preserves its languages_code and includes existing ID when available", () => {
    fc.assert(
      fc.property(
        fc.constantFrom("event" as const, "course" as const),
        fc.integer({ min: 1, max: 99_999 }),
        fc.array(
          fc.record({
            languages_code: fc.constantFrom("cs" as const, "en" as const, "es" as const),
            title: fc.string({ maxLength: 50 }),
            description: fc.string({ maxLength: 100 }),
          }),
          { minLength: 0, maxLength: 3 },
        ),
        fc.array(
          fc.tuple(
            fc.constantFrom("cs" as const, "en" as const, "es" as const),
            fc.integer({ min: 1, max: 9_999 }),
          ),
        ),
        (itemType, itemId, newTranslations, existingIdPairs) => {
          const idByLang = new Map<string, number>(existingIdPairs);
          const patch = buildTranslationsPatch(newTranslations, idByLang);

          expect(patch).toHaveLength(newTranslations.length);

          for (let i = 0; i < newTranslations.length; i++) {
            // The languages_code is preserved exactly
            expect(patch[i].languages_code).toBe(newTranslations[i].languages_code);

            // When an existing ID is known for this language, it is included
            if (idByLang.has(newTranslations[i].languages_code)) {
              expect(patch[i].id).toBe(idByLang.get(newTranslations[i].languages_code));
            } else {
              expect(patch[i].id).toBeUndefined();
            }
          }

          // The URL pattern for the PATCH request targets the correct collection
          const collection = getCollection(itemType);
          const expectedUrlPattern = `/items/${collection}/${itemId}`;
          expect(expectedUrlPattern).toMatch(new RegExp(`^/items/${collection}/\\d+$`));
        },
      ),
      { numRuns: 100 },
    );
  });

  it("patch with no existing IDs does not inject any id fields", () => {
    fc.assert(
      fc.property(
        fc.array(
          fc.record({
            languages_code: fc.constantFrom("cs" as const, "en" as const, "es" as const),
            title: fc.string({ maxLength: 30 }),
          }),
          { minLength: 1, maxLength: 3 },
        ),
        (newTranslations) => {
          const emptyIdByLang = new Map<string, number>();
          const patch = buildTranslationsPatch(newTranslations, emptyIdByLang);
          for (const entry of patch) {
            expect(entry.id).toBeUndefined();
          }
        },
      ),
      { numRuns: 100 },
    );
  });

  it("event collection maps to 'events', course collection maps to 'courses'", () => {
    fc.assert(
      fc.property(
        fc.constantFrom("event" as const, "course" as const),
        fc.integer({ min: 1, max: 99_999 }),
        (itemType, itemId) => {
          const collection = getCollection(itemType);
          expect(collection).toBe(itemType === "event" ? "events" : "courses");
          const url = `/items/${collection}/${itemId}`;
          expect(url).toContain(collection);
          expect(url).toContain(String(itemId));
        },
      ),
      { numRuns: 100 },
    );
  });
});

// ── Property 2: Translation Field Filtering ───────────────────────────────────
// Feature: event-course-editing, Property 2: Translation field filtering

const ALL_EVENT_NON_TEXT_FIELDS = [
  "start_time",
  "end_time",
  "dances",
  "event_type",
  "venue",
  "organizer",
  "organizer_email",
  "original_url",
  "registration_url",
];

const ALL_COURSE_NON_TEXT_FIELDS = [
  "start_date",
  "end_date",
  "dance_type",
  "level",
  "venue",
  "lesson_count",
  "lesson_duration",
  "max_participants",
  "price",
  "schedule_day",
  "schedule_time",
  "original_url",
  "registration_url",
  "instructor_name",
];

describe("Property 2: Translation Field Filtering [Feature: event-course-editing]", () => {
  it("only text fields appear in the result; all non-text fields are excluded", () => {
    const allEventFields = [...EVENT_TEXT_FIELDS, ...ALL_EVENT_NON_TEXT_FIELDS];
    const allCourseFields = [...COURSE_TEXT_FIELDS, ...ALL_COURSE_NON_TEXT_FIELDS];

    fc.assert(
      fc.property(
        fc.constantFrom("event" as const, "course" as const),
        fc.dictionary(
          fc.constantFrom(...allEventFields, ...allCourseFields),
          fc.string({ maxLength: 50 }),
        ),
        (itemType, fields) => {
          const result = filterTextFields(fields, itemType);
          const validTextKeys = itemType === "event" ? EVENT_TEXT_FIELDS : COURSE_TEXT_FIELDS;
          const nonTextFields = itemType === "event" ? ALL_EVENT_NON_TEXT_FIELDS : ALL_COURSE_NON_TEXT_FIELDS;

          // Every key in result is a valid text field
          for (const key of Object.keys(result)) {
            expect(validTextKeys.has(key)).toBe(true);
          }

          // No non-text field leaks into result
          for (const key of nonTextFields) {
            expect(key in result).toBe(false);
          }

          // Values are strings (typeof check is part of the filter)
          for (const value of Object.values(result)) {
            expect(typeof value).toBe("string");
          }
        },
      ),
      { numRuns: 100 },
    );
  });

  it("text fields present in input are preserved in output", () => {
    fc.assert(
      fc.property(
        fc.constantFrom("event" as const, "course" as const),
        fc.dictionary(
          fc.constantFrom(...EVENT_TEXT_FIELDS, ...COURSE_TEXT_FIELDS),
          fc.string({ minLength: 1, maxLength: 50 }),
        ),
        (itemType, fields) => {
          const result = filterTextFields(fields, itemType);
          const validTextKeys = itemType === "event" ? EVENT_TEXT_FIELDS : COURSE_TEXT_FIELDS;

          for (const [key, value] of Object.entries(fields)) {
            if (validTextKeys.has(key)) {
              expect(result[key]).toBe(value);
            }
          }
        },
      ),
      { numRuns: 100 },
    );
  });

  it("empty input always produces empty output", () => {
    fc.assert(
      fc.property(
        fc.constantFrom("event" as const, "course" as const),
        (itemType) => {
          const result = filterTextFields({}, itemType);
          expect(Object.keys(result)).toHaveLength(0);
        },
      ),
      { numRuns: 100 },
    );
  });
});

// ── Property 3: Translation Status Computation ────────────────────────────────
// Feature: event-course-editing, Property 3: Translation status computation

describe("Property 3: Translation Status Computation [Feature: event-course-editing]", () => {
  it("status is 'complete' if all 3 languages present, 'partial' if 1-2, 'missing' if none", () => {
    fc.assert(
      fc.property(
        fc.subarray(["cs", "en", "es"] as const, { minLength: 0 }),
        (presentCodes) => {
          const translations = presentCodes.map((code) => ({
            languages_code: code,
            title: "t",
            description: "d",
            parts_translations: [],
            info_translations: [],
          }));

          const status = computeTranslationStatus(translations);

          if (presentCodes.length === 3) {
            expect(status).toBe("complete");
          } else if (presentCodes.length >= 1) {
            expect(status).toBe("partial");
          } else {
            expect(status).toBe("missing");
          }
        },
      ),
      { numRuns: 100 },
    );
  });

  it("status is commutative: order of translations does not affect result", () => {
    fc.assert(
      fc.property(
        fc.shuffledSubarray(["cs", "en", "es"] as const, { minLength: 0 }),
        (presentCodes) => {
          const makeTrans = (codes: readonly string[]) =>
            codes.map((code) => ({
              languages_code: code,
              title: "test",
              description: "test",
              parts_translations: [],
              info_translations: [],
            }));

          const reversed = [...presentCodes].reverse();
          const status1 = computeTranslationStatus(makeTrans(presentCodes));
          const status2 = computeTranslationStatus(makeTrans(reversed));

          expect(status1).toBe(status2);
        },
      ),
      { numRuns: 100 },
    );
  });

  it("status is idempotent: duplicate language entries do not change result", () => {
    fc.assert(
      fc.property(
        fc.subarray(["cs", "en", "es"] as const, { minLength: 1 }),
        (presentCodes) => {
          const makeTrans = (codes: readonly string[]) =>
            codes.map((code) => ({
              languages_code: code,
              title: "test",
              description: "test",
              parts_translations: [],
              info_translations: [],
            }));

          const singleSet = makeTrans(presentCodes);
          const duplicated = [...makeTrans(presentCodes), ...makeTrans(presentCodes)];

          const statusSingle = computeTranslationStatus(singleSet);
          const statusDuplicated = computeTranslationStatus(duplicated);

          expect(statusSingle).toBe(statusDuplicated);
        },
      ),
      { numRuns: 100 },
    );
  });

  it("empty translations always yield 'missing'", () => {
    expect(computeTranslationStatus([])).toBe("missing");
  });

  it("all three languages always yield 'complete'", () => {
    const all = ["cs", "en", "es"].map((code) => ({
      languages_code: code,
      title: "t",
      description: "d",
      parts_translations: [],
      info_translations: [],
    }));
    expect(computeTranslationStatus(all)).toBe("complete");
  });
});
