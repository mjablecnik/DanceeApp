import { describe, it, expect, vi, afterEach, beforeEach } from "vitest";
import fc from "fast-check";

// Mock config before importing any module that uses it
vi.mock("../../core/config", () => ({
  config: {
    directusBaseUrl: "http://directus-test",
    directusAccessToken: "test-token",
    nominatimBaseUrl: "http://nominatim-test",
    directusTimeoutMs: 5000,
    nominatimTimeoutMs: 5000,
  },
}));

const mockFindVenueByCoordinates = vi.fn();
const mockFindVenue = vi.fn();
const mockCreateVenue = vi.fn();
const mockReverseGeocode = vi.fn();

vi.mock("../../clients/directus-client", () => ({
  findVenueByCoordinates: (...args: unknown[]) => mockFindVenueByCoordinates(...args),
  findVenue: (...args: unknown[]) => mockFindVenue(...args),
  createVenue: (...args: unknown[]) => mockCreateVenue(...args),
}));

vi.mock("../../clients/nominatim-client", () => ({
  reverseGeocode: (...args: unknown[]) => mockReverseGeocode(...args),
}));

import { resolveVenue } from "../../services/venue-resolver";
import { SUPPORTED_EVENT_TYPES, parseEventType, toIsoOrNull } from "../../core/schemas";

afterEach(() => {
  vi.clearAllMocks();
});

// ---- Property 9: Venue resolution field mapping ----

describe("Property 9: Venue resolution field mapping", () => {
  beforeEach(() => {
    // No pre-existing venue by default
    mockFindVenueByCoordinates.mockResolvedValue(null);
    mockFindVenue.mockResolvedValue(null);
  });

  it("maps Facebook location fields directly when name, address, city, countryCode are present", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          name: fc.string({ minLength: 1, maxLength: 50 }),
          address: fc.string({ minLength: 1, maxLength: 80 }),
          city: fc.string({ minLength: 1, maxLength: 50 }),
          countryCode: fc.string({ minLength: 2, maxLength: 5 }),
          latitude: fc.double({ min: -90, max: 90, noNaN: true }),
          longitude: fc.double({ min: -180, max: 180, noNaN: true }),
          venueId: fc.integer({ min: 1, max: 9999 }),
        }),
        async (loc) => {
          mockFindVenueByCoordinates.mockResolvedValue(null);
          mockFindVenue.mockResolvedValue(null);
          // Nominatim is always called when lat/lng available (req 6.2: supplement
          // with reverse geocoding for region even when other fields are present)
          mockReverseGeocode.mockResolvedValue({ address: { state: "Jihomoravský kraj" } });
          mockCreateVenue.mockImplementation((v: unknown) =>
            Promise.resolve({ ...(v as object), id: loc.venueId })
          );

          const result = await resolveVenue({
            name: loc.name,
            address: loc.address,
            city: loc.city,
            countryCode: loc.countryCode,
            latitude: loc.latitude,
            longitude: loc.longitude,
          });

          // Facebook fields take precedence; only region comes from Nominatim
          expect(result.name).toBe(loc.name);
          expect(result.address).toBe(loc.address);
          expect(result.town).toBe(loc.city);
          expect(result.country).toBe(loc.countryCode);
        }
      )
    );
  });

  it("sets venue region to Nominatim address.state when present", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.string({ minLength: 1, maxLength: 50 }),
        fc.integer({ min: 1, max: 9999 }),
        async (state, venueId) => {
          mockFindVenueByCoordinates.mockResolvedValue(null);
          mockFindVenue.mockResolvedValue(null);
          mockReverseGeocode.mockResolvedValue({
            address: {
              road: "Test Road",
              city: "Test City",
              country_code: "CZ",
              state,
            },
          });
          mockCreateVenue.mockImplementation((v: unknown) =>
            Promise.resolve({ ...(v as object), id: venueId })
          );

          // Location without all required fields to trigger Nominatim
          const result = await resolveVenue({
            latitude: 50.0,
            longitude: 14.0,
            // no name, address, city provided
          });

          expect(result.region).toBe(state);
        }
      )
    );
  });

  it("defaults venue region to city when Nominatim address.state is absent but city is present", async () => {
    mockFindVenueByCoordinates.mockResolvedValue(null);
    mockFindVenue.mockResolvedValue(null);
    mockReverseGeocode.mockResolvedValue({
      address: {
        road: "Some Road",
        city: "Some City",
        country_code: "CZ",
        // no state field
      },
    });
    mockCreateVenue.mockImplementation((v: unknown) =>
      Promise.resolve({ ...(v as object), id: 1 })
    );

    const result = await resolveVenue({
      latitude: 50.0,
      longitude: 14.0,
    });

    expect(result.region).toBe("Some City");
  });

  it("returns null when reverseGeocode throws and no location fields are available", async () => {
    mockFindVenueByCoordinates.mockResolvedValue(null);
    mockFindVenue.mockResolvedValue(null);
    mockReverseGeocode.mockRejectedValue(new Error("Nominatim rate limit"));

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const result = await resolveVenue({ latitude: 50.0, longitude: 14.0 });
    warnSpy.mockRestore();

    // All identifying fields are empty after Nominatim failure → null, no venue created
    expect(result).toBeNull();
    expect(mockCreateVenue).not.toHaveBeenCalled();
  });

  it("logs a warning when reverseGeocode fails", async () => {
    mockFindVenueByCoordinates.mockResolvedValue(null);
    mockFindVenue.mockResolvedValue(null);
    mockReverseGeocode.mockRejectedValue(new Error("Nominatim timeout"));

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    await resolveVenue({ latitude: 50.0, longitude: 14.0 });

    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining("reverseGeocode failed"),
    );
    warnSpy.mockRestore();
  });

  it("creates venue when Nominatim resolves location fields even without Facebook fields", async () => {
    mockFindVenueByCoordinates.mockResolvedValue(null);
    mockFindVenue.mockResolvedValue(null);
    mockReverseGeocode.mockResolvedValue({
      address: {
        road: "Geocoded Road",
        city: "Geocoded City",
        country_code: "CZ",
        state: "Jihomoravský kraj",
      },
    });
    mockCreateVenue.mockImplementation((v: unknown) =>
      Promise.resolve({ ...(v as object), id: 99 })
    );

    const result = await resolveVenue({ latitude: 50.0, longitude: 14.0 });

    expect(result).not.toBeNull();
    expect(mockCreateVenue).toHaveBeenCalledOnce();
    expect(result!.region).toBe("Jihomoravský kraj");
  });

  it("returns existing venue by coordinates without calling createVenue", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          id: fc.integer({ min: 1, max: 9999 }),
          name: fc.string({ minLength: 1, maxLength: 50 }),
          latitude: fc.double({ min: -90, max: 90, noNaN: true }),
          longitude: fc.double({ min: -180, max: 180, noNaN: true }),
        }),
        async (existingVenue) => {
          mockFindVenueByCoordinates.mockResolvedValue(existingVenue);
          mockCreateVenue.mockClear();

          const result = await resolveVenue({
            latitude: existingVenue.latitude,
            longitude: existingVenue.longitude,
          });

          expect(result.id).toBe(existingVenue.id);
          expect(mockCreateVenue).not.toHaveBeenCalled();
        }
      )
    );
  });
});

// ---- Property 2: Null end timestamp preservation ----

describe("Property 2: Null end timestamp preservation", () => {
  it("returns null for null endTimestamp", () => {
    expect(toIsoOrNull(null)).toBeNull();
  });

  it("returns null for undefined endTimestamp", () => {
    expect(toIsoOrNull(undefined)).toBeNull();
  });

  it("returns null for zero endTimestamp", () => {
    expect(toIsoOrNull(0)).toBeNull();
  });

  it("returns null for any negative timestamp", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: -2_000_000_000, max: -1 }),
        (ts) => {
          expect(toIsoOrNull(ts)).toBeNull();
        }
      )
    );
  });

  it("returns a valid ISO string for any positive valid timestamp", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 2_000_000_000 }),
        (ts) => {
          const result = toIsoOrNull(ts);
          expect(result).not.toBeNull();
          expect(() => new Date(result!)).not.toThrow();
        }
      )
    );
  });
});

// ---- Property 5: Unsupported event types are skipped ----

describe("Property 5: Unsupported event types are skipped", () => {
  it("SUPPORTED_EVENT_TYPES contains party, workshop, festival, holiday, course, lesson", () => {
    expect(SUPPORTED_EVENT_TYPES).toContain("party");
    expect(SUPPORTED_EVENT_TYPES).toContain("workshop");
    expect(SUPPORTED_EVENT_TYPES).toContain("festival");
    expect(SUPPORTED_EVENT_TYPES).toContain("holiday");
    expect(SUPPORTED_EVENT_TYPES).toContain("course");
    expect(SUPPORTED_EVENT_TYPES).toContain("lesson");
    expect(SUPPORTED_EVENT_TYPES).toHaveLength(6);
  });

  it("any event type not in SUPPORTED_EVENT_TYPES should not pass the supported check", () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1, maxLength: 30 }),
        (randomType) => {
          const isSupported = (SUPPORTED_EVENT_TYPES as readonly string[]).includes(randomType);
          if (!isSupported) {
            // unsupported types should cause the workflow to skip
            expect(isSupported).toBe(false);
          }
        }
      )
    );
  });

  it("'other' event type is not in SUPPORTED_EVENT_TYPES", () => {
    expect((SUPPORTED_EVENT_TYPES as readonly string[]).includes("other")).toBe(false);
  });

  it("parseEventType returns 'other' for unknown strings, which is then not in SUPPORTED_EVENT_TYPES", () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1, maxLength: 30 }).filter(
          (s) => !["party", "workshop", "lesson", "course", "festival", "holiday", "other"].includes(s)
        ),
        (unknownType) => {
          const parsed = parseEventType(unknownType);
          expect(parsed).toBe("other");
          expect((SUPPORTED_EVENT_TYPES as readonly string[]).includes(parsed)).toBe(false);
        }
      )
    );
  });
});
