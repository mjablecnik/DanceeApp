import * as dotenv from "dotenv";

dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const response = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    headers: authHeaders(),
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`GET ${path} failed ${response.status}: ${text}`);
  }
  return response.json();
}

async function directusPost(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`POST ${path} failed ${response.status}: ${text}`);
  }
  return response.json();
}

async function collectionExists(name: string): Promise<boolean> {
  try {
    const data = await directusGet(`/collections/${name}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function fieldExists(collection: string, field: string): Promise<boolean> {
  try {
    const data = await directusGet(`/fields/${collection}/${field}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function createCollectionIfNotExists(
  name: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await collectionExists(name)) {
    // already exists, skip silently
    return;
  }
  await directusPost("/collections", { collection: name, meta, schema });
  console.log(`Created collection "${name}".`);
}

async function createFieldIfNotExists(
  collection: string,
  field: string,
  type: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await fieldExists(collection, field)) {
    return;
  }
  await directusPost(`/fields/${collection}`, { field, type, meta, schema });
  console.log(`Created field "${collection}.${field}".`);
}

// ---- Create collections ----

async function setupEventsCollection(): Promise<void> {
  await createCollectionIfNotExists("events", {
    singleton: false,
    sort_field: null,
  });

  await createFieldIfNotExists("events", "title", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("events", "original_description", "text", {
    interface: "input-multiline",
    display: "raw",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "organizer", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("events", "venue", "integer", {
    interface: "select-dropdown-m2o",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "start_time", "dateTime", {
    interface: "datetime",
  }, { is_nullable: false });

  await createFieldIfNotExists("events", "end_time", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "timezone", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });

  await createFieldIfNotExists("events", "original_url", "string", {
    interface: "input",
    unique: true,
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("events", "parts", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "info", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "dances", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "published", text: "Published" },
        { value: "draft", text: "Draft" },
        { value: "archived", text: "Archived" },
      ],
    },
    default_value: "published",
  }, { is_nullable: false, max_length: 50, default_value: "published" });

  await createFieldIfNotExists("events", "translation_status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "complete", text: "Complete" },
        { value: "partial", text: "Partial" },
        { value: "missing", text: "Missing" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("events", "image", "uuid", {
    interface: "file-image",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "image_source", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "facebook", text: "Facebook" },
        { value: "ai_generated", text: "AI Generated" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("events", "event_type", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "party", text: "Party" },
        { value: "workshop", text: "Workshop" },
        { value: "festival", text: "Festival" },
        { value: "holiday", text: "Holiday" },
        { value: "course", text: "Course" },
        { value: "lesson", text: "Lesson" },
        { value: "other", text: "Other" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("events", "registration_url", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 2048 });
}

async function setupVenuesCollection(): Promise<void> {
  await createCollectionIfNotExists("venues", { singleton: false });

  await createFieldIfNotExists("venues", "name", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "address", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 500 });

  await createFieldIfNotExists("venues", "town", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "country", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });

  await createFieldIfNotExists("venues", "postal_code", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 20 });

  await createFieldIfNotExists("venues", "region", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "latitude", "float", {
    interface: "input",
  }, { is_nullable: true });

  await createFieldIfNotExists("venues", "longitude", "float", {
    interface: "input",
  }, { is_nullable: true });

  await createFieldIfNotExists("venues", "address_source", "string", {
    interface: "select-dropdown",
    options: { choices: [{ text: "Facebook", value: "facebook" }, { text: "Nominatim", value: "nominatim" }] },
  }, { is_nullable: true, max_length: 20 });

  await createFieldIfNotExists("venues", "verified", "boolean", {
    interface: "boolean",
    special: ["cast-boolean"],
  }, { is_nullable: false, default_value: false });
}

async function setupGroupsCollection(): Promise<void> {
  await createCollectionIfNotExists("groups", { singleton: false });

  await createFieldIfNotExists("groups", "url", "string", {
    interface: "input",
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("groups", "type", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });

  await createFieldIfNotExists("groups", "updated_at", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });
}

async function setupErrorsCollection(): Promise<void> {
  await createCollectionIfNotExists("errors", { singleton: false });

  await createFieldIfNotExists("errors", "url", "string", {
    interface: "input",
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("errors", "message", "text", {
    interface: "input-multiline",
  }, { is_nullable: true });

  await createFieldIfNotExists("errors", "type", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { text: "Scrape Failed", value: "scrape_failed" },
        { text: "Parse Failed", value: "parse_failed" },
        { text: "LLM Parse Failed", value: "llm_parse_failed" },
        { text: "Workflow Failed", value: "workflow_failed" },
        { text: "Schedule Failed", value: "schedule_failed" },
        { text: "Unknown", value: "unknown" },
      ],
    },
  }, { is_nullable: true, default_value: "unknown" });

  await createFieldIfNotExists("errors", "datetime", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });
}

async function setupSkippedEventsCollection(): Promise<void> {
  await createCollectionIfNotExists("skipped_events", { singleton: false });

  await createFieldIfNotExists("skipped_events", "original_url", "string", {
    interface: "input",
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("skipped_events", "reason", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("skipped_events", "event_type", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 64 });

  await createFieldIfNotExists("skipped_events", "datetime", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });
}

async function setupLanguagesCollection(): Promise<void> {
  if (await collectionExists("languages")) {
    // already exists, skip silently
    return;
  }
  // Create languages with a custom primary key (code)
  await directusPost("/collections", {
    collection: "languages",
    meta: { singleton: false },
    schema: {},
    fields: [
      {
        field: "code",
        type: "string",
        schema: { is_primary_key: true, max_length: 10, is_nullable: false },
        meta: { interface: "input", required: true },
      },
      {
        field: "name",
        type: "string",
        schema: { max_length: 255, is_nullable: false },
        meta: { interface: "input" },
      },
    ],
  });
  console.log(`Created collection "languages" with code (PK) and name fields.`);
}

async function setupEventsTranslationsCollection(): Promise<void> {
  await createCollectionIfNotExists("events_translations", { singleton: false });

  await createFieldIfNotExists("events_translations", "events_id", "integer", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true });

  await createFieldIfNotExists("events_translations", "languages_code", "string", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true, max_length: 10 });

  await createFieldIfNotExists("events_translations", "title", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("events_translations", "description", "text", {
    interface: "input-multiline",
  }, { is_nullable: true });

  await createFieldIfNotExists("events_translations", "parts_translations", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events_translations", "info_translations", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });
}

async function setupTranslationsRelation(): Promise<void> {
  // Check if relation already exists
  try {
    const data = await directusGet("/relations/events/translations") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  // Create the translations field on events (O2M list interface for browsable translations)
  await createFieldIfNotExists("events", "translations", "alias", {
    interface: "list-o2m",
    options: {
      template: "{{languages_code}} — {{title}}",
      enableCreate: false,
      enableSelect: false,
    },
    display: "related-values",
    display_options: {
      template: "{{languages_code}} — {{title}}",
    },
    special: ["translations"],
  }, null);

  // Create the O2M relation from events to events_translations
  try {
    await directusPost("/relations", {
      collection: "events_translations",
      field: "events_id",
      related_collection: "events",
      meta: {
        one_collection: "events",
        many_collection: "events_translations",
        many_field: "events_id",
        one_field: "translations",
        one_collection_field: null,
        one_allowed_collections: null,
        junction_field: "languages_code",
        sort_field: null,
      },
      schema: {
        on_delete: "CASCADE",
      },
    });
    console.log(`Created relation events <-> events_translations.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }

  // Create the M2O relation from events_translations to languages
  try {
    await directusPost("/relations", {
      collection: "events_translations",
      field: "languages_code",
      related_collection: "languages",
      meta: {
        one_collection: "languages",
        many_collection: "events_translations",
        many_field: "languages_code",
        one_field: null,
      },
      schema: {},
    });
    console.log(`Created relation events_translations <-> languages.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

async function setupVenueRelation(): Promise<void> {
  // Check if relation already exists
  try {
    const data = await directusGet("/relations/events/venue") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  try {
    await directusPost("/relations", {
      collection: "events",
      field: "venue",
      related_collection: "venues",
      meta: {
        one_collection: "venues",
        many_collection: "events",
        many_field: "venue",
        one_field: null,
      },
      schema: {
        on_delete: "SET NULL",
      },
    });
    console.log(`Created relation events.venue -> venues.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}


async function setupEventImageRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/events/image") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  try {
    await directusPost("/relations", {
      collection: "events",
      field: "image",
      related_collection: "directus_files",
      meta: {
        one_collection: "directus_files",
        many_collection: "events",
        many_field: "image",
        one_field: null,
      },
      schema: {
        on_delete: "SET NULL",
      },
    });
    console.log(`Created relation events.image -> directus_files.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

async function setupDanceStylesCollection(): Promise<void> {
  if (await collectionExists("dance_styles")) {
    // already exists, skip silently
    return;
  }
  await directusPost("/collections", {
    collection: "dance_styles",
    meta: { singleton: false },
    schema: {},
    fields: [
      {
        field: "code",
        type: "string",
        schema: { is_primary_key: true, max_length: 50, is_nullable: false },
        meta: { interface: "input", required: true },
      },
      {
        field: "name",
        type: "string",
        schema: { max_length: 100, is_nullable: false },
        meta: { interface: "input" },
      },
    ],
  });
  console.log(`Created collection "dance_styles" with code (PK) and name fields.`);

  await createFieldIfNotExists("dance_styles", "parent_code", "string", {
    interface: "select-dropdown-m2o",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("dance_styles", "sort_order", "integer", {
    interface: "input",
  }, { is_nullable: false, default_value: 0 });
}

async function setupDanceStylesTranslationsCollection(): Promise<void> {
  await createCollectionIfNotExists("dance_styles_translations", { singleton: false });

  await createFieldIfNotExists("dance_styles_translations", "dance_styles_code", "string", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("dance_styles_translations", "languages_code", "string", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true, max_length: 10 });

  await createFieldIfNotExists("dance_styles_translations", "name", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });
}

async function setupDanceStylesTranslationsRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/dance_styles/translations") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  await createFieldIfNotExists("dance_styles", "translations", "alias", {
    interface: "list-o2m",
    options: {
      template: "{{languages_code}} — {{name}}",
      enableCreate: false,
      enableSelect: false,
    },
    display: "related-values",
    display_options: {
      template: "{{languages_code}} — {{name}}",
    },
    special: ["translations"],
  }, null);

  try {
    await directusPost("/relations", {
      collection: "dance_styles_translations",
      field: "dance_styles_code",
      related_collection: "dance_styles",
      meta: {
        one_collection: "dance_styles",
        many_collection: "dance_styles_translations",
        many_field: "dance_styles_code",
        one_field: "translations",
        one_collection_field: null,
        one_allowed_collections: null,
        junction_field: "languages_code",
        sort_field: null,
      },
      schema: {
        on_delete: "CASCADE",
      },
    });
    console.log(`Created relation dance_styles <-> dance_styles_translations.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }

  try {
    await directusPost("/relations", {
      collection: "dance_styles_translations",
      field: "languages_code",
      related_collection: "languages",
      meta: {
        one_collection: "languages",
        many_collection: "dance_styles_translations",
        many_field: "languages_code",
        one_field: null,
      },
      schema: {},
    });
    console.log(`Created relation dance_styles_translations <-> languages.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

async function setupDanceStylesParentRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/dance_styles/parent_code") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  try {
    await directusPost("/relations", {
      collection: "dance_styles",
      field: "parent_code",
      related_collection: "dance_styles",
      meta: {
        one_collection: "dance_styles",
        many_collection: "dance_styles",
        many_field: "parent_code",
        one_field: null,
      },
      schema: {
        on_delete: "SET NULL",
      },
    });
    console.log(`Created self-referencing relation dance_styles.parent_code.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

const DANCE_STYLES_SEED = [
  { code: "salsa", name: "Salsa", parent_code: null, sort_order: 1 },
  { code: "salsa-on1", name: "Salsa On1", parent_code: "salsa", sort_order: 2 },
  { code: "salsa-on2", name: "Salsa On2", parent_code: "salsa", sort_order: 3 },
  { code: "salsa-cubana", name: "Salsa Cubana", parent_code: "salsa", sort_order: 4 },
  { code: "bachata", name: "Bachata", parent_code: null, sort_order: 10 },
  { code: "bachata-sensual", name: "Bachata Sensual", parent_code: "bachata", sort_order: 11 },
  { code: "bachata-dominicana", name: "Bachata Dominicana", parent_code: "bachata", sort_order: 12 },
  { code: "kizomba", name: "Kizomba", parent_code: null, sort_order: 20 },
  { code: "urban-kiz", name: "Urban Kiz", parent_code: "kizomba", sort_order: 21 },
  { code: "semba", name: "Semba", parent_code: "kizomba", sort_order: 22 },
  { code: "zouk", name: "Zouk", parent_code: null, sort_order: 30 },
  { code: "lambada", name: "Lambada", parent_code: "zouk", sort_order: 31 },
  { code: "tango", name: "Tango", parent_code: null, sort_order: 40 },
  { code: "swing", name: "Swing", parent_code: null, sort_order: 50 },
  { code: "lindy-hop", name: "Lindy Hop", parent_code: "swing", sort_order: 51 },
  { code: "west-coast-swing", name: "West Coast Swing", parent_code: "swing", sort_order: 52 },
  { code: "boogie-woogie", name: "Boogie Woogie", parent_code: "swing", sort_order: 53 },
  { code: "charleston", name: "Charleston", parent_code: "swing", sort_order: 54 },
  { code: "reggaeton", name: "Reggaeton", parent_code: null, sort_order: 60 },
  { code: "afro", name: "Afro", parent_code: null, sort_order: 70 },
  { code: "forro", name: "Forró", parent_code: null, sort_order: 80 },
  { code: "ballroom", name: "Standard", parent_code: null, sort_order: 90 },
  { code: "waltz", name: "Waltz", parent_code: "ballroom", sort_order: 91 },
  { code: "viennese-waltz", name: "Viennese Waltz", parent_code: "ballroom", sort_order: 92 },
  { code: "quickstep", name: "Quickstep", parent_code: "ballroom", sort_order: 93 },
  { code: "slowfox", name: "Slowfox", parent_code: "ballroom", sort_order: 94 },
  { code: "latin", name: "Latin", parent_code: null, sort_order: 100 },
  { code: "cha-cha", name: "Cha-Cha", parent_code: "latin", sort_order: 101 },
  { code: "rumba", name: "Rumba", parent_code: "latin", sort_order: 102 },
  { code: "samba", name: "Samba", parent_code: "latin", sort_order: 103 },
  { code: "paso-doble", name: "Paso Doble", parent_code: "latin", sort_order: 104 },
  { code: "jive", name: "Jive", parent_code: "latin", sort_order: 105 },
  { code: "dancehall", name: "Dancehall", parent_code: null, sort_order: 110 },
  { code: "hip-hop", name: "Hip-Hop", parent_code: null, sort_order: 120 },
  { code: "contemporary", name: "Contemporary", parent_code: null, sort_order: 130 },
  { code: "ecstatic-dance", name: "Ecstatic Dance", parent_code: null, sort_order: 140 },
];

async function seedDanceStyles(): Promise<void> {
  // Seed parent styles first, then children
  const parents = DANCE_STYLES_SEED.filter((s) => s.parent_code === null);
  const children = DANCE_STYLES_SEED.filter((s) => s.parent_code !== null);

  for (const style of [...parents, ...children]) {
    try {
      const existing = await directusGet(`/items/dance_styles/${style.code}`) as { data?: unknown };
      if (existing?.data) {
        // already exists, skip silently
        continue;
      }
    } catch {
      // Not found, create it
    }
    try {
      await directusPost("/items/dance_styles", style);
      console.log(`Seeded dance style "${style.code}" (${style.name}).`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      if (msg.includes("already exists") || msg.includes("409") || msg.includes("unique")) {
        // already exists, skip silently
      } else {
        throw err;
      }
    }
  }
}

// Translation data for dance styles.
// Most names are the same across cs, en, and es; only divergent names are listed.
const DANCE_STYLE_TRANSLATIONS: Array<{ dance_styles_code: string; languages_code: string; name: string }> = [
  // English translations
  ...([
    { code: "salsa", name: "Salsa" },
    { code: "salsa-on1", name: "Salsa On1" },
    { code: "salsa-on2", name: "Salsa On2" },
    { code: "salsa-cubana", name: "Salsa Cubana" },
    { code: "bachata", name: "Bachata" },
    { code: "bachata-sensual", name: "Bachata Sensual" },
    { code: "bachata-dominicana", name: "Bachata Dominicana" },
    { code: "kizomba", name: "Kizomba" },
    { code: "urban-kiz", name: "Urban Kiz" },
    { code: "semba", name: "Semba" },
    { code: "zouk", name: "Zouk" },
    { code: "lambada", name: "Lambada" },
    { code: "tango", name: "Tango" },
    { code: "swing", name: "Swing" },
    { code: "lindy-hop", name: "Lindy Hop" },
    { code: "west-coast-swing", name: "West Coast Swing" },
    { code: "boogie-woogie", name: "Boogie Woogie" },
    { code: "charleston", name: "Charleston" },
    { code: "reggaeton", name: "Reggaeton" },
    { code: "afro", name: "Afro" },
    { code: "forro", name: "Forró" },
    { code: "ballroom", name: "Standard" },
    { code: "waltz", name: "Waltz" },
    { code: "viennese-waltz", name: "Viennese Waltz" },
    { code: "quickstep", name: "Quickstep" },
    { code: "slowfox", name: "Slowfox" },
    { code: "latin", name: "Latin" },
    { code: "cha-cha", name: "Cha-Cha" },
    { code: "rumba", name: "Rumba" },
    { code: "samba", name: "Samba" },
    { code: "paso-doble", name: "Paso Doble" },
    { code: "jive", name: "Jive" },
    { code: "dancehall", name: "Dancehall" },
    { code: "hip-hop", name: "Hip-Hop" },
    { code: "contemporary", name: "Contemporary" },
    { code: "ecstatic-dance", name: "Ecstatic Dance" },
  ] as Array<{ code: string; name: string }>).map((s) => ({ dance_styles_code: s.code, languages_code: "en", name: s.name })),
  // Czech translations
  ...([
    { code: "salsa", name: "Salsa" },
    { code: "salsa-on1", name: "Salsa On1" },
    { code: "salsa-on2", name: "Salsa On2" },
    { code: "salsa-cubana", name: "Salsa Cubana" },
    { code: "bachata", name: "Bachata" },
    { code: "bachata-sensual", name: "Bachata Sensual" },
    { code: "bachata-dominicana", name: "Bachata Dominicana" },
    { code: "kizomba", name: "Kizomba" },
    { code: "urban-kiz", name: "Urban Kiz" },
    { code: "semba", name: "Semba" },
    { code: "zouk", name: "Zouk" },
    { code: "lambada", name: "Lambada" },
    { code: "tango", name: "Tango" },
    { code: "swing", name: "Swing" },
    { code: "lindy-hop", name: "Lindy Hop" },
    { code: "west-coast-swing", name: "West Coast Swing" },
    { code: "boogie-woogie", name: "Boogie Woogie" },
    { code: "charleston", name: "Charleston" },
    { code: "reggaeton", name: "Reggaeton" },
    { code: "afro", name: "Afro" },
    { code: "forro", name: "Forró" },
    { code: "ballroom", name: "Standardní" },
    { code: "waltz", name: "Valčík" },
    { code: "viennese-waltz", name: "Vídeňský valčík" },
    { code: "quickstep", name: "Quickstep" },
    { code: "slowfox", name: "Slowfox" },
    { code: "latin", name: "Latinsko-americké" },
    { code: "cha-cha", name: "Cha-Cha" },
    { code: "rumba", name: "Rumba" },
    { code: "samba", name: "Samba" },
    { code: "paso-doble", name: "Paso Doble" },
    { code: "jive", name: "Jive" },
    { code: "dancehall", name: "Dancehall" },
    { code: "hip-hop", name: "Hip-Hop" },
    { code: "contemporary", name: "Současný tanec" },
    { code: "ecstatic-dance", name: "Ekstatický tanec" },
  ] as Array<{ code: string; name: string }>).map((s) => ({ dance_styles_code: s.code, languages_code: "cs", name: s.name })),
  // Spanish translations
  ...([
    { code: "salsa", name: "Salsa" },
    { code: "salsa-on1", name: "Salsa On1" },
    { code: "salsa-on2", name: "Salsa On2" },
    { code: "salsa-cubana", name: "Salsa Cubana" },
    { code: "bachata", name: "Bachata" },
    { code: "bachata-sensual", name: "Bachata Sensual" },
    { code: "bachata-dominicana", name: "Bachata Dominicana" },
    { code: "kizomba", name: "Kizomba" },
    { code: "urban-kiz", name: "Urban Kiz" },
    { code: "semba", name: "Semba" },
    { code: "zouk", name: "Zouk" },
    { code: "lambada", name: "Lambada" },
    { code: "tango", name: "Tango" },
    { code: "swing", name: "Swing" },
    { code: "lindy-hop", name: "Lindy Hop" },
    { code: "west-coast-swing", name: "West Coast Swing" },
    { code: "boogie-woogie", name: "Boogie Woogie" },
    { code: "charleston", name: "Charleston" },
    { code: "reggaeton", name: "Reggaeton" },
    { code: "afro", name: "Afro" },
    { code: "forro", name: "Forró" },
    { code: "ballroom", name: "Estándar" },
    { code: "waltz", name: "Vals" },
    { code: "viennese-waltz", name: "Vals vienés" },
    { code: "quickstep", name: "Quickstep" },
    { code: "slowfox", name: "Slowfox" },
    { code: "latin", name: "Latinoamericano" },
    { code: "cha-cha", name: "Cha-Cha" },
    { code: "rumba", name: "Rumba" },
    { code: "samba", name: "Samba" },
    { code: "paso-doble", name: "Paso Doble" },
    { code: "jive", name: "Jive" },
    { code: "dancehall", name: "Dancehall" },
    { code: "hip-hop", name: "Hip-Hop" },
    { code: "contemporary", name: "Danza contemporánea" },
    { code: "ecstatic-dance", name: "Danza extática" },
  ] as Array<{ code: string; name: string }>).map((s) => ({ dance_styles_code: s.code, languages_code: "es", name: s.name })),
];

async function seedDanceStyleTranslations(): Promise<void> {
  for (const translation of DANCE_STYLE_TRANSLATIONS) {
    const filter = encodeURIComponent(
      JSON.stringify({
        _and: [
          { dance_styles_code: { _eq: translation.dance_styles_code } },
          { languages_code: { _eq: translation.languages_code } },
        ],
      }),
    );
    try {
      const existing = await directusGet(
        `/items/dance_styles_translations?filter=${filter}&fields=id&limit=1`,
      ) as { data?: unknown[] };
      if (existing?.data && existing.data.length > 0) {
        // already exists, skip silently
        continue;
      }
    } catch {
      // Not found, create it
    }
    try {
      await directusPost("/items/dance_styles_translations", translation);
      console.log(`Seeded translation "${translation.dance_styles_code}" (${translation.languages_code}: ${translation.name}).`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      if (msg.includes("already exists") || msg.includes("409") || msg.includes("unique")) {
        // already exists, skip silently
      } else {
        throw err;
      }
    }
  }
}

async function setupCoursesCollection(): Promise<void> {
  await createCollectionIfNotExists("courses", { singleton: false });

  await createFieldIfNotExists("courses", "title", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("courses", "description", "text", {
    interface: "input-multiline",
    display: "raw",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "instructor_name", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("courses", "instructor_bio", "text", {
    interface: "input-multiline",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "instructor_avatar_url", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 2048 });

  await createFieldIfNotExists("courses", "venue", "integer", {
    interface: "select-dropdown-m2o",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "start_date", "date", {
    interface: "datetime",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "end_date", "date", {
    interface: "datetime",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "schedule_day", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("courses", "schedule_time", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("courses", "lesson_count", "integer", {
    interface: "input",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "lesson_duration_minutes", "integer", {
    interface: "input",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "max_participants", "integer", {
    interface: "input",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "current_participants", "integer", {
    interface: "input",
    default_value: 0,
  }, { is_nullable: false, default_value: 0 });

  await createFieldIfNotExists("courses", "price", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("courses", "price_note", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("courses", "level", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "beginner", text: "Beginner" },
        { value: "intermediate", text: "Intermediate" },
        { value: "advanced", text: "Advanced" },
        { value: "all_levels", text: "All Levels" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("courses", "dances", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "image", "uuid", {
    interface: "file-image",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "image_source", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "facebook", text: "Facebook" },
        { value: "ai_generated", text: "AI Generated" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("courses", "original_url", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 2048 });

  await createFieldIfNotExists("courses", "registration_url", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 2048 });

  await createFieldIfNotExists("courses", "original_description", "text", {
    interface: "input-multiline",
    display: "raw",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses", "status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "published", text: "Published" },
        { value: "draft", text: "Draft" },
        { value: "archived", text: "Archived" },
      ],
    },
    default_value: "published",
  }, { is_nullable: false, max_length: 50, default_value: "published" });

  await createFieldIfNotExists("courses", "translation_status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "complete", text: "Complete" },
        { value: "partial", text: "Partial" },
        { value: "missing", text: "Missing" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });
}

async function setupCoursesTranslationsCollection(): Promise<void> {
  await createCollectionIfNotExists("courses_translations", { singleton: false });

  await createFieldIfNotExists("courses_translations", "courses_id", "integer", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true });

  await createFieldIfNotExists("courses_translations", "languages_code", "string", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true, max_length: 10 });

  await createFieldIfNotExists("courses_translations", "title", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("courses_translations", "description", "text", {
    interface: "input-multiline",
  }, { is_nullable: true });

  await createFieldIfNotExists("courses_translations", "learning_items", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });
}

async function setupCoursesTranslationsRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/courses/translations") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  await createFieldIfNotExists("courses", "translations", "alias", {
    interface: "list-o2m",
    options: {
      template: "{{languages_code}} — {{title}}",
      enableCreate: false,
      enableSelect: false,
    },
    display: "related-values",
    display_options: {
      template: "{{languages_code}} — {{title}}",
    },
    special: ["translations"],
  }, null);

  try {
    await directusPost("/relations", {
      collection: "courses_translations",
      field: "courses_id",
      related_collection: "courses",
      meta: {
        one_collection: "courses",
        many_collection: "courses_translations",
        many_field: "courses_id",
        one_field: "translations",
        one_collection_field: null,
        one_allowed_collections: null,
        junction_field: "languages_code",
        sort_field: null,
      },
      schema: {
        on_delete: "CASCADE",
      },
    });
    console.log(`Created relation courses <-> courses_translations.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }

  try {
    await directusPost("/relations", {
      collection: "courses_translations",
      field: "languages_code",
      related_collection: "languages",
      meta: {
        one_collection: "languages",
        many_collection: "courses_translations",
        many_field: "languages_code",
        one_field: null,
      },
      schema: {},
    });
    console.log(`Created relation courses_translations <-> languages.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

async function setupCoursesVenueRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/courses/venue") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  try {
    await directusPost("/relations", {
      collection: "courses",
      field: "venue",
      related_collection: "venues",
      meta: {
        one_collection: "venues",
        many_collection: "courses",
        many_field: "venue",
        one_field: null,
      },
      schema: {
        on_delete: "SET NULL",
      },
    });
    console.log(`Created relation courses.venue -> venues.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

async function setupCoursesImageRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/courses/image") as { data?: unknown };
    if (data?.data) {
      // already exists, skip silently
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  try {
    await directusPost("/relations", {
      collection: "courses",
      field: "image",
      related_collection: "directus_files",
      meta: {
        one_collection: "directus_files",
        many_collection: "courses",
        many_field: "image",
        one_field: null,
      },
      schema: {
        on_delete: "SET NULL",
      },
    });
    console.log(`Created relation courses.image -> directus_files.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

async function setupFavoritesCollection(): Promise<void> {
  await createCollectionIfNotExists("favorites", { singleton: false });

  await createFieldIfNotExists("favorites", "user_id", "string", {
    interface: "input",
    required: true,
  }, { is_nullable: false, max_length: 255 });

  await createFieldIfNotExists("favorites", "item_type", "string", {
    interface: "select-dropdown",
    required: true,
    options: {
      choices: [
        { value: "event", text: "Event" },
        { value: "course", text: "Course" },
      ],
    },
  }, { is_nullable: false, max_length: 50 });

  await createFieldIfNotExists("favorites", "item_id", "integer", {
    interface: "input",
    required: true,
  }, { is_nullable: false });

  await createFieldIfNotExists("favorites", "created_at", "dateTime", {
    interface: "datetime",
    default_value: "$NOW",
  }, { is_nullable: false });
}

async function seedLanguages(): Promise<void> {
  const languages = [
    { code: "cs", name: "Čeština" },
    { code: "en", name: "English" },
    { code: "es", name: "Español" },
  ];

  for (const lang of languages) {
    try {
      const existing = await directusGet(`/items/languages/${lang.code}`) as { data?: unknown };
      if (existing?.data) {
        // already exists, skip silently
        continue;
      }
    } catch {
      // Not found, create it
    }
    try {
      await directusPost("/items/languages", lang);
      console.log(`Seeded language "${lang.code}" (${lang.name}).`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      if (msg.includes("already exists") || msg.includes("409") || msg.includes("unique")) {
        // already exists, skip silently
      } else {
        throw err;
      }
    }
  }
}

async function main(): Promise<void> {
  if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
    throw new Error("DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in .env");
  }

  console.log("Setting up Directus collections...\n");

  await setupEventsCollection();
  await setupVenuesCollection();
  await setupGroupsCollection();
  await setupErrorsCollection();
  await setupSkippedEventsCollection();
  await setupLanguagesCollection();
  await setupEventsTranslationsCollection();
  await setupTranslationsRelation();
  await setupVenueRelation();
  await setupEventImageRelation();
  await seedLanguages();
  await setupDanceStylesCollection();
  await setupDanceStylesTranslationsCollection();
  await setupDanceStylesTranslationsRelation();
  await setupDanceStylesParentRelation();
  await seedDanceStyles();
  await seedDanceStyleTranslations();
  await setupCoursesCollection();
  await setupCoursesTranslationsCollection();
  await setupCoursesTranslationsRelation();
  await setupCoursesVenueRelation();
  await setupCoursesImageRelation();
  await setupFavoritesCollection();

  console.log("\nDirectus setup complete.");
}

// Export the promise so tests can await full completion before inspecting side effects.
export const ready = main().catch((err) => {
  console.error("Setup failed:", err);
  process.exit(1);
});
