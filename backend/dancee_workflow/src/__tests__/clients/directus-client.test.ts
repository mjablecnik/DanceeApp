import { describe, it, expect, vi, afterEach } from "vitest";
import fc from "fast-check";

// Mock config before importing the client
vi.mock("../../core/config", () => ({
  config: { directusBaseUrl: "http://directus-test", directusAccessToken: "test-token", directusTimeoutMs: 5000 },
}));

import {
  findVenue,
  findVenueByCoordinates,
  findEventByOriginalUrl,
  findErrorByUrl,
  createError,
  createVenue,
  updateGroupTimestamp,
  getGroupsOrderedByUpdatedAt,
  listPublishedEvents,
} from "../../clients/directus-client";

afterEach(() => {
  vi.restoreAllMocks();
});

// Helper: build a complete venue object (all required fields) with overrides
function makeVenue(overrides: Record<string, unknown> = {}) {
  return {
    id: 1,
    name: "Test Venue",
    address: "Main Street 1",
    town: "Prague",
    country: "CZ",
    postal_code: "11000",
    region: "Prague",
    latitude: 50.0,
    longitude: 14.0,
    address_source: "facebook",
    verified: false,
    ...overrides,
  };
}

// Helper: build a complete event object (all required fields) with overrides
function makeEvent(overrides: Record<string, unknown> = {}) {
  return {
    id: 1,
    original_description: "A great dance event",
    organizer: "Test Organizer",
    venue: null,
    start_time: "2025-01-01T18:00:00Z",
    end_time: null,
    timezone: "Europe/Prague",
    original_url: "https://facebook.com/events/123",
    parts: [],
    info: [],
    dances: [],
    status: "published",
    translation_status: "complete",
    ...overrides,
  };
}

// ---- Property 24: listPublishedEvents always enforces published filter ----

describe("Property 24: listPublishedEvents always enforces published filter", () => {
  it("uses status=published filter when called without extra filter", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => ({ data: [] }),
        });
      })
    );
    await listPublishedEvents();
    const params = new URL(capturedUrl).searchParams;
    const filter = JSON.parse(params.get("filter") ?? "{}") as Record<string, unknown>;
    expect((filter as { status?: { _eq?: string } }).status?._eq).toBe("published");
  });

  it("merges extra filter with published filter using _and", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => ({ data: [] }),
        });
      })
    );
    const extraFilter = { category: { _eq: "dance" } };
    await listPublishedEvents(extraFilter);
    const params = new URL(capturedUrl).searchParams;
    const filter = JSON.parse(params.get("filter") ?? "{}") as { _and?: Array<Record<string, unknown>> };
    expect(filter._and).toBeDefined();
    expect(filter._and?.[0]).toEqual({ status: { _eq: "published" } });
    expect(filter._and?.[1]).toEqual(extraFilter);
  });

});

describe("Property 10: Venue deduplication", () => {
  it("returns existing venue by coordinates when found", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          id: fc.integer({ min: 1, max: 9999 }),
          name: fc.string({ minLength: 1, maxLength: 50 }),
          latitude: fc.double({ min: -90, max: 90, noNaN: true }),
          longitude: fc.double({ min: -180, max: 180, noNaN: true }),
        }),
        async (partial) => {
          const venue = makeVenue(partial);
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: true,
              status: 200,
              json: async () => ({ data: [venue] }),
            })
          );
          const result = await findVenueByCoordinates(venue.latitude as number, venue.longitude as number);
          expect(result).not.toBeNull();
          expect(result?.id).toBe(venue.id);
        }
      )
    );
  });

  it("returns null when no venue found by coordinates", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ data: [] }),
      })
    );
    const result = await findVenueByCoordinates(50.0, 14.0);
    expect(result).toBeNull();
  });

  it("returns existing venue by name, address, town when found", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          id: fc.integer({ min: 1, max: 9999 }),
          name: fc.string({ minLength: 1, maxLength: 50 }),
          address: fc.string({ minLength: 1, maxLength: 50 }),
          town: fc.string({ minLength: 1, maxLength: 50 }),
        }),
        async (partial) => {
          const venue = makeVenue(partial);
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: true,
              status: 200,
              json: async () => ({ data: [venue] }),
            })
          );
          const result = await findVenue(venue.name as string, venue.address as string, venue.town as string);
          expect(result).not.toBeNull();
          expect(result?.id).toBe(venue.id);
        }
      )
    );
  });

  it("returns null when no venue found by name, address, town", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ data: [] }),
      })
    );
    const result = await findVenue("Club XYZ", "Main Street", "Prague");
    expect(result).toBeNull();
  });
});

describe("Property 11: Event deduplication by original URL", () => {
  it("returns existing event when URL matches", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          id: fc.integer({ min: 1, max: 9999 }),
          original_url: fc.constantFrom(
            "https://facebook.com/events/123456",
            "https://facebook.com/events/789012",
            "https://facebook.com/events/345678"
          ),
        }),
        async (partial) => {
          const event = makeEvent(partial);
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: true,
              status: 200,
              json: async () => ({ data: [event] }),
            })
          );
          const result = await findEventByOriginalUrl(event.original_url as string);
          expect(result).not.toBeNull();
          expect(result?.id).toBe(event.id);
        }
      )
    );
  });

  it("returns null when no event found for URL", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ data: [] }),
      })
    );
    const result = await findEventByOriginalUrl("https://facebook.com/events/nonexistent");
    expect(result).toBeNull();
  });

  it("encodes the URL in the query parameter", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => ({ data: [] }),
        });
      })
    );
    const eventUrl = "https://facebook.com/events/123?ref=test";
    await findEventByOriginalUrl(eventUrl);
    expect(capturedUrl).toContain(encodeURIComponent(eventUrl));
  });
});

describe("Property 12: Error deduplication by URL", () => {
  it("returns existing error when URL matches", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          id: fc.integer({ min: 1, max: 9999 }),
          url: fc.constantFrom(
            "https://facebook.com/events/111",
            "https://facebook.com/events/222",
            "https://facebook.com/events/333"
          ),
          message: fc.string({ minLength: 1, maxLength: 100 }),
          datetime: fc.constant("2025-01-01T00:00:00.000Z"),
        }),
        async (error) => {
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: true,
              status: 200,
              json: async () => ({ data: [error] }),
            })
          );
          const result = await findErrorByUrl(error.url);
          expect(result).not.toBeNull();
          expect(result?.id).toBe(error.id);
          expect(result?.url).toBe(error.url);
        }
      )
    );
  });

  it("returns null when no error found for URL", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ data: [] }),
      })
    );
    const result = await findErrorByUrl("https://facebook.com/events/nonexistent");
    expect(result).toBeNull();
  });
});

describe("createError: internal deduplication", () => {
  it("updates existing error record via PATCH without creating a new one", async () => {
    const existingError = {
      id: 99,
      url: "https://facebook.com/events/dup",
      message: "already logged",
      datetime: "2025-01-01T00:00:00Z",
    };
    const updatedError = { ...existingError, message: "new message" };
    const fetchMock = vi.fn()
      // First call: GET (findErrorByUrl) → returns existing
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ data: [existingError] }),
      })
      // Second call: PATCH (update existing record)
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ data: updatedError }),
      });
    vi.stubGlobal("fetch", fetchMock);

    const result = await createError({ url: existingError.url, message: "new message" });

    expect(result.id).toBe(existingError.id);
    // Expect a GET then a PATCH — no POST should be called
    const calls = fetchMock.mock.calls as [string, RequestInit?][];
    const methods = calls.map(([, init]) => init?.method ?? "GET");
    expect(methods).toContain("GET");
    expect(methods).not.toContain("POST");
    expect(methods).toContain("PATCH");
  });

  it("creates a new error when URL does not exist yet", async () => {
    const newError = {
      id: 100,
      url: "https://facebook.com/events/new",
      message: "fresh error",
      datetime: "2025-01-01T00:00:00Z",
    };
    const fetchMock = vi
      .fn()
      // First call: findErrorByUrl → empty
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ data: [] }),
      })
      // Second call: directusPost → created record
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ data: newError }),
      });
    vi.stubGlobal("fetch", fetchMock);

    const result = await createError({ url: newError.url, message: newError.message });

    expect(result.id).toBe(newError.id);
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });
});

describe("Property 13: Groups ordered by updated_at ascending", () => {
  it("includes sort=updated_at in request URL", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => ({ data: [] }),
        });
      })
    );
    await getGroupsOrderedByUpdatedAt();
    expect(capturedUrl).toContain("sort=updated_at");
  });

  it("returns groups in the order returned by Directus", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(
          fc.record({
            id: fc.integer({ min: 1, max: 9999 }),
            url: fc.constantFrom(
              "https://facebook.com/groups/dance1",
              "https://facebook.com/groups/dance2",
              "https://facebook.com/groups/dance3",
              "https://facebook.com/groups/dance4"
            ),
            updated_at: fc.option(
              fc.date({ min: new Date("2020-01-01"), max: new Date("2025-01-01") })
                .map((d) => d.toISOString()),
              { nil: null }
            ),
          }),
          { minLength: 0, maxLength: 4 }
        ),
        async (groups) => {
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: true,
              status: 200,
              json: async () => ({ data: groups }),
            })
          );
          const result = await getGroupsOrderedByUpdatedAt();
          expect(result).toHaveLength(groups.length);
          result.forEach((group, i) => {
            expect(group.url).toBe(groups[i].url);
          });
        }
      )
    );
  });
});

describe("Directus response envelope validator: throws on missing data field", () => {
  it("throws a descriptive error when response has no data field (e.g. auth error shape)", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ errors: [{ message: "Forbidden" }] }),
      })
    );
    await expect(findEventByOriginalUrl("https://facebook.com/events/123")).rejects.toThrow(
      /Unexpected Directus response shape/
    );
  });

  it("throws with context name in error message", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ errors: [{ message: "Forbidden" }] }),
      })
    );
    let errorMessage = "";
    try {
      await findEventByOriginalUrl("https://facebook.com/events/123");
    } catch (e) {
      errorMessage = (e as Error).message;
    }
    expect(errorMessage).toContain("findEventByOriginalUrl");
  });
});

describe("POST/PATCH error messages are generic (no internal details leaked)", () => {
  it("createVenue (POST) error is generic and does not include the request body", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 400,
        text: async () => "Validation error",
      })
    );
    const venue = {
      name: "Club Test",
      address: "Main St 1",
      town: "Prague",
      country: "CZ",
      postal_code: "11000",
      region: "Prague",
      latitude: 50.0,
      longitude: 14.0,
    };
    await expect(createVenue(venue)).rejects.toThrow(/failed \(status 400\)/);
    await expect(createVenue(venue)).rejects.not.toThrow(/body:/);
  });

  it("updateGroupTimestamp (PATCH) error is generic and does not include the request body", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 500,
        text: async () => "Server error",
      })
    );
    await expect(updateGroupTimestamp(1, "2025-01-01T00:00:00Z")).rejects.toThrow(/failed \(status 500\)/);
    await expect(updateGroupTimestamp(1, "2025-01-01T00:00:00Z")).rejects.not.toThrow(/body:/);
  });
});
