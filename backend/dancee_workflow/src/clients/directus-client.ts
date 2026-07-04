import { config } from "../core/config";
import {
  DirectusEventSchema,
  DirectusVenueSchema,
  DirectusGroupSchema,
  DirectusErrorSchema,
  DirectusSkippedEventSchema,
  DirectusLanguageSchema,
  DirectusCourseSchema,
  DirectusDanceStyleSchema,
  DirectusFavoriteSchema,
  type DirectusEvent,
  type DirectusVenue,
  type DirectusGroup,
  type DirectusError,
  type DirectusSkippedEvent,
  type DirectusLanguage,
  type DirectusCourse,
  type DirectusDanceStyle,
  type DirectusFavorite,
} from "../core/schemas";
import { z } from "zod";

/**
 * Validates that a Directus API response contains the expected `data` envelope field
 * and returns its value. Throws a descriptive error if the shape is unexpected
 * (e.g. auth error, wrong endpoint, or API version mismatch) so that callers receive
 * a meaningful message instead of a confusing Zod parse failure downstream.
 */
function extractDirectusData(response: unknown, context: string): unknown {
  if (typeof response !== "object" || response === null || !("data" in response)) {
    throw new Error(
      `Unexpected Directus response shape in ${context}: ` +
      `expected object with 'data' field, got: ${JSON.stringify(response)?.slice(0, 100)}`,
    );
  }
  return (response as { data: unknown }).data;
}

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${config.directusAccessToken}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    headers: authHeaders(),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Directus GET ${path} error ${response.status}: ${text}`);
  }
  return response.json();
}

async function directusPost(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    const bodyPreview = JSON.stringify(body).slice(0, 200);
    throw new Error(`Directus POST ${path} error ${response.status}: ${text} (body: ${bodyPreview})`);
  }
  return response.json();
}

async function directusPatch(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    method: "PATCH",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    const bodyPreview = JSON.stringify(body).slice(0, 200);
    throw new Error(`Directus PATCH ${path} error ${response.status}: ${text} (body: ${bodyPreview})`);
  }
  return response.json();
}

// ---- Events ----

export async function createEvent(event: DirectusEvent): Promise<DirectusEvent> {
  const data = await directusPost("/items/events", event);
  return DirectusEventSchema.parse(extractDirectusData(data, "createEvent"));
}

export async function findEventByOriginalUrl(originalUrl: string): Promise<DirectusEvent | null> {
  const encoded = encodeURIComponent(originalUrl);
  const data = await directusGet(`/items/events?filter[original_url][_eq]=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findEventByOriginalUrl") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusEventSchema.parse(items[0]);
}

function requirePositiveInt(id: string | number, context: string): number {
  const n = typeof id === "number" ? id : Number(id);
  if (!Number.isInteger(n) || n <= 0) {
    throw new Error(`${context}: id must be a positive integer, got: ${JSON.stringify(id)}`);
  }
  return n;
}

export async function getEventById(id: string | number): Promise<DirectusEvent | null> {
  try {
    const safeId = requirePositiveInt(id, "getEventById");
    const data = await directusGet(`/items/events/${safeId}?fields=*,translations.*`);
    return DirectusEventSchema.parse(extractDirectusData(data, "getEventById"));
  } catch {
    return null;
  }
}

export async function updateEvent(id: string | number, patch: Partial<DirectusEvent>): Promise<DirectusEvent> {
  const safeId = requirePositiveInt(id, "updateEvent");
  const data = await directusPatch(`/items/events/${safeId}`, patch);
  return DirectusEventSchema.parse(extractDirectusData(data, "updateEvent"));
}

export async function deleteEventTranslations(eventId: string | number): Promise<void> {
  // Fetch existing translation IDs for this event
  const data = await directusGet(
    `/items/events_translations?filter[events_id][_eq]=${eventId}&fields=id`,
  );
  const items = extractDirectusData(data, "deleteEventTranslations") as { id: number }[];
  if (!items || items.length === 0) return;

  // Delete each translation
  for (const item of items) {
    await fetch(`${config.directusBaseUrl}/items/events_translations/${item.id}`, {
      method: "DELETE",
      headers: authHeaders(),
      signal: AbortSignal.timeout(config.directusTimeoutMs),
    });
  }
}

export async function listPublishedEvents(extraFilter?: Record<string, unknown>): Promise<DirectusEvent[]> {
  const publishedFilter = { status: { _eq: "published" } };
  const effectiveFilter = extraFilter
    ? { _and: [publishedFilter, extraFilter] }
    : publishedFilter;
  const encoded = encodeURIComponent(JSON.stringify(effectiveFilter));
  const data = await directusGet(`/items/events?filter=${encoded}&fields=*,translations.*,venue.*`);
  const items = extractDirectusData(data, "listPublishedEvents") as unknown[];
  return z.array(DirectusEventSchema).parse(items);
}

export async function listEvents(filter: Record<string, unknown>): Promise<DirectusEvent[]> {
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/events?filter=${encoded}`);
  const items = extractDirectusData(data, "listEvents") as unknown[];
  return z.array(DirectusEventSchema).parse(items);
}

// ---- Venues ----

export async function createVenue(venue: DirectusVenue): Promise<DirectusVenue> {
  const data = await directusPost("/items/venues", venue);
  return DirectusVenueSchema.parse(extractDirectusData(data, "createVenue"));
}

export async function findVenue(
  name: string,
  address: string,
  town: string,
): Promise<DirectusVenue | null> {
  const filter = {
    _and: [
      { name: { _eq: name } },
      { address: { _eq: address } },
      { town: { _eq: town } },
    ],
  };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/venues?filter=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findVenue") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusVenueSchema.parse(items[0]);
}

export async function findVenueByCoordinates(
  latitude: number,
  longitude: number,
): Promise<DirectusVenue | null> {
  const filter = {
    _and: [{ latitude: { _eq: latitude } }, { longitude: { _eq: longitude } }],
  };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/venues?filter=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findVenueByCoordinates") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusVenueSchema.parse(items[0]);
}

// ---- Groups ----

/**
 * Creates a new group record in Directus.
 *
 * NOTE: Groups (Facebook page/group URLs used as event sources) are not created
 * programmatically by the workflow — they are added manually via the Directus
 * admin UI. This function exists for completeness and potential future use.
 * The batch processing service only reads and updates existing groups.
 */
export async function createGroup(group: DirectusGroup): Promise<DirectusGroup> {
  const data = await directusPost("/items/groups", group);
  return DirectusGroupSchema.parse(extractDirectusData(data, "createGroup"));
}

export async function getGroupsOrderedByUpdatedAt(): Promise<DirectusGroup[]> {
  const data = await directusGet("/items/groups?sort=updated_at");
  const items = extractDirectusData(data, "getGroupsOrderedByUpdatedAt") as unknown[];
  return z.array(DirectusGroupSchema).parse(items);
}

export async function updateGroupTimestamp(
  id: string | number,
  updatedAt: string,
): Promise<DirectusGroup> {
  const data = await directusPatch(`/items/groups/${id}`, { updated_at: updatedAt });
  return DirectusGroupSchema.parse(extractDirectusData(data, "updateGroupTimestamp"));
}

// ---- Errors ----

export async function createError(
  entry: Omit<DirectusError, "id" | "datetime"> & { datetime?: string },
): Promise<DirectusError> {
  const now = entry.datetime ?? new Date().toISOString();
  const existing = await findErrorByUrl(entry.url);
  if (existing) {
    // Update the existing row with the latest message, type, and timestamp
    const data = await directusPatch(`/items/errors/${existing.id}`, {
      message: entry.message,
      type: entry.type ?? "unknown",
      datetime: now,
    });
    return DirectusErrorSchema.parse(extractDirectusData(data, "createError:update"));
  }
  const fullEntry = { ...entry, type: entry.type ?? "unknown", datetime: now };
  const data = await directusPost("/items/errors", fullEntry);
  return DirectusErrorSchema.parse(extractDirectusData(data, "createError"));
}

export async function findErrorByUrl(url: string): Promise<DirectusError | null> {
  const encoded = encodeURIComponent(url);
  const data = await directusGet(`/items/errors?filter[url][_eq]=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findErrorByUrl") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusErrorSchema.parse(items[0]);
}

// ---- Skipped Events ----

export async function findSkippedEventByUrl(originalUrl: string): Promise<DirectusSkippedEvent | null> {
  const encoded = encodeURIComponent(originalUrl);
  const data = await directusGet(`/items/skipped_events?filter[original_url][_eq]=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findSkippedEventByUrl") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusSkippedEventSchema.parse(items[0]);
}

export async function createSkippedEvent(
  entry: Omit<DirectusSkippedEvent, "id" | "datetime"> & { datetime?: string },
): Promise<DirectusSkippedEvent> {
  const now = entry.datetime ?? new Date().toISOString();
  const existing = await findSkippedEventByUrl(entry.original_url);
  if (existing) {
    return existing;
  }
  const fullEntry = { ...entry, datetime: now };
  const data = await directusPost("/items/skipped_events", fullEntry);
  return DirectusSkippedEventSchema.parse(extractDirectusData(data, "createSkippedEvent"));
}

// ---- Languages ----

export async function getLanguages(): Promise<DirectusLanguage[]> {
  const data = await directusGet("/items/languages");
  const items = extractDirectusData(data, "getLanguages") as unknown[];
  return z.array(DirectusLanguageSchema).parse(items);
}

export async function createLanguage(
  code: string,
  name: string,
): Promise<DirectusLanguage> {
  const data = await directusPost("/items/languages", { code, name });
  return DirectusLanguageSchema.parse(extractDirectusData(data, "createLanguage"));
}

// ---- Files ----

export async function uploadFile(
  buffer: Buffer,
  filename: string,
  mimeType: string,
): Promise<string> {
  const formData = new FormData();
  const blob = new Blob([buffer], { type: mimeType });
  formData.append("file", blob, filename);

  const response = await fetch(`${config.directusBaseUrl}/files`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${config.directusAccessToken}`,
    },
    body: formData,
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Directus POST /files error ${response.status}: ${text}`);
  }
  const responseData = await response.json();
  const fileData = extractDirectusData(responseData, "uploadFile") as { id: string };
  if (!fileData || typeof fileData.id !== "string") {
    throw new Error(`Unexpected response from Directus file upload: ${JSON.stringify(responseData)?.slice(0, 100)}`);
  }
  return fileData.id;
}

// ---- Courses ----

export async function createCourse(course: DirectusCourse): Promise<DirectusCourse> {
  const data = await directusPost("/items/courses", course);
  return DirectusCourseSchema.parse(extractDirectusData(data, "createCourse"));
}

export async function getCourseById(id: string | number): Promise<DirectusCourse | null> {
  try {
    const safeId = requirePositiveInt(id, "getCourseById");
    const data = await directusGet(`/items/courses/${safeId}?fields=*,translations.*`);
    return DirectusCourseSchema.parse(extractDirectusData(data, "getCourseById"));
  } catch {
    return null;
  }
}

export async function updateCourse(id: string | number, patch: Partial<DirectusCourse>): Promise<DirectusCourse> {
  const safeId = requirePositiveInt(id, "updateCourse");
  const data = await directusPatch(`/items/courses/${safeId}`, patch);
  return DirectusCourseSchema.parse(extractDirectusData(data, "updateCourse"));
}

export async function findCourseByOriginalUrl(originalUrl: string): Promise<DirectusCourse | null> {
  const encoded = encodeURIComponent(originalUrl);
  const data = await directusGet(`/items/courses?filter[original_url][_eq]=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findCourseByOriginalUrl") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusCourseSchema.parse(items[0]);
}

export async function listPublishedCourses(extraFilter?: Record<string, unknown>): Promise<DirectusCourse[]> {
  const publishedFilter = { status: { _eq: "published" } };
  const effectiveFilter = extraFilter
    ? { _and: [publishedFilter, extraFilter] }
    : publishedFilter;
  const encoded = encodeURIComponent(JSON.stringify(effectiveFilter));
  const data = await directusGet(`/items/courses?filter=${encoded}&fields=*,translations.*,venue.*`);
  const items = extractDirectusData(data, "listPublishedCourses") as unknown[];
  return z.array(DirectusCourseSchema).parse(items);
}

export async function listFavorites(userId: string): Promise<DirectusFavorite[]> {
  const filter = { user_id: { _eq: userId } };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/favorites?filter=${encoded}&sort[]=-created_at`);
  const items = extractDirectusData(data, "listFavorites") as unknown[];
  return z.array(DirectusFavoriteSchema).parse(items);
}

// ---- Dance Styles ----

export async function listDanceStyles(): Promise<DirectusDanceStyle[]> {
  const data = await directusGet("/items/dance_styles?fields=code,name,parent_code,sort_order&limit=-1&sort[]=sort_order");
  const items = extractDirectusData(data, "listDanceStyles") as unknown[];
  return z.array(DirectusDanceStyleSchema).parse(items);
}

let danceStyleCodesCache: string[] | null = null;

export function clearDanceStyleCodesCache(): void {
  danceStyleCodesCache = null;
}

export async function getDanceStyleCodes(): Promise<string[]> {
  if (danceStyleCodesCache !== null) {
    return danceStyleCodesCache;
  }
  const data = await directusGet("/items/dance_styles?fields=code&limit=-1");
  const items = extractDirectusData(data, "getDanceStyleCodes") as unknown[];
  const parsed = z.array(DirectusDanceStyleSchema.pick({ code: true })).parse(items);
  danceStyleCodesCache = parsed.map((item) => item.code);
  return danceStyleCodesCache;
}

// ---- Image reuse ----

/**
 * Finds the most recently expired event with an AI-generated image that matches
 * the given primary dance style and event type, for reuse in the image fallback chain.
 *
 * The Directus query uses `_contains` on the JSON `dances` field as a broad pre-filter,
 * since Directus performs substring matching on the serialized JSON string rather than
 * exact array element membership. To avoid false positives (e.g. "salsa" matching
 * "salsa-on1"), results are post-filtered in application code to verify that
 * `primaryDance` is an exact element of the `dances` array.
 */
/**
 * Finds the most recently expired event with an AI-generated image that matches
 * the given event type. Since Directus JSON fields don't support _contains filter,
 * we fetch candidates filtered by event_type and image_source, then post-filter
 * for dance style match in application code.
 */
export async function findExpiredEventWithImage(
  primaryDance: string,
  eventType: string,
): Promise<string | null> {
  const now = new Date().toISOString();
  const filter = {
    _and: [
      { end_time: { _lt: now } },
      { image: { _nnull: true } },
      { image_source: { _eq: "ai_generated" } },
      { event_type: { _eq: eventType } },
    ],
  };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(
    `/items/events?filter=${encoded}&fields=image,dances&sort[]=-end_time&limit=50`,
  );
  const items = extractDirectusData(data, "findExpiredEventWithImage") as { image?: string | number | null; dances?: unknown }[];
  if (!items || items.length === 0) return null;

  // Post-filter: find first event where primaryDance is in the dances array
  for (const item of items) {
    const dances = Array.isArray(item.dances) ? item.dances as unknown[] : [];
    if (dances.includes(primaryDance)) {
      const fileId = item.image;
      if (fileId === null || fileId === undefined) continue;
      return String(fileId);
    }
  }
  return null;
}

// ---- Favorites ----

export async function createFavorite(favorite: DirectusFavorite): Promise<DirectusFavorite> {
  // Validate that the referenced item exists
  const collection = favorite.item_type === "event" ? "events" : "courses";
  const itemData = await directusGet(`/items/${collection}/${favorite.item_id}?fields=id`).catch(() => null);
  if (!itemData) {
    throw new Error(
      `Cannot create favorite: ${favorite.item_type} with id ${favorite.item_id} does not exist`,
    );
  }

  // Check for duplicate (user_id, item_type, item_id)
  const dupFilter = encodeURIComponent(
    JSON.stringify({
      _and: [
        { user_id: { _eq: favorite.user_id } },
        { item_type: { _eq: favorite.item_type } },
        { item_id: { _eq: favorite.item_id } },
      ],
    }),
  );
  const existing = await directusGet(`/items/favorites?filter=${dupFilter}&fields=id&limit=1`);
  const existingItems = extractDirectusData(existing, "createFavorite:dupCheck") as { id: number | string }[];
  if (existingItems && existingItems.length > 0) {
    // Return the existing record to preserve idempotency
    const existingData = await directusGet(`/items/favorites/${existingItems[0].id}`);
    return DirectusFavoriteSchema.parse(extractDirectusData(existingData, "createFavorite:existing"));
  }

  const data = await directusPost("/items/favorites", favorite);
  return DirectusFavoriteSchema.parse(extractDirectusData(data, "createFavorite"));
}

export async function deleteFavorite(
  userId: string,
  itemType: "event" | "course",
  itemId: number,
): Promise<void> {
  const filter = {
    _and: [
      { user_id: { _eq: userId } },
      { item_type: { _eq: itemType } },
      { item_id: { _eq: itemId } },
    ],
  };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/favorites?filter=${encoded}&fields=id&limit=1`);
  const items = extractDirectusData(data, "deleteFavorite") as { id: number | string }[];
  if (!items || items.length === 0) return;

  const id = items[0].id;
  const response = await fetch(`${config.directusBaseUrl}/items/favorites/${id}`, {
    method: "DELETE",
    headers: authHeaders(),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Directus DELETE /items/favorites/${id} error ${response.status}: ${text}`);
  }
}
