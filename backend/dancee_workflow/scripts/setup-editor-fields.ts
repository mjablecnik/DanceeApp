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

async function fieldExists(collection: string, field: string): Promise<boolean> {
  try {
    const data = await directusGet(`/fields/${collection}/${field}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function createFieldIfNotExists(
  collection: string,
  field: string,
  type: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await fieldExists(collection, field)) {
    console.log(`Field "${collection}.${field}" already exists, skipping.`);
    return;
  }
  await directusPost(`/fields/${collection}`, { field, type, meta, schema });
  console.log(`Created field "${collection}.${field}".`);
}

async function setupEditorFields(): Promise<void> {
  console.log("Setting up editor workflow fields...");

  // ---- events collection ----

  await createFieldIfNotExists("events", "published", "boolean", {
    interface: "boolean",
    display: "boolean",
    note: "Whether the event is visible to regular users",
    default_value: true,
  }, {
    is_nullable: false,
    default_value: true,
  });

  await createFieldIfNotExists("events", "reviewed", "boolean", {
    interface: "boolean",
    display: "boolean",
    note: "Whether an editor has reviewed the event",
    default_value: false,
  }, {
    is_nullable: false,
    default_value: false,
  });

  await createFieldIfNotExists("events", "price", "string", {
    interface: "input",
    display: "raw",
    note: "Price with currency, e.g. '500 CZK' or '25 EUR'",
  }, {
    is_nullable: true,
    max_length: 255,
  });

  await createFieldIfNotExists("events", "additional_info", "json", {
    interface: "input-code",
    display: "raw",
    note: "Array of {key, value} objects with extra event information",
  }, {
    is_nullable: true,
  });

  // ---- courses collection ----

  await createFieldIfNotExists("courses", "published", "boolean", {
    interface: "boolean",
    display: "boolean",
    note: "Whether the course is visible to regular users",
    default_value: true,
  }, {
    is_nullable: false,
    default_value: true,
  });

  await createFieldIfNotExists("courses", "reviewed", "boolean", {
    interface: "boolean",
    display: "boolean",
    note: "Whether an editor has reviewed the course",
    default_value: false,
  }, {
    is_nullable: false,
    default_value: false,
  });

  console.log("Editor workflow fields setup complete.");
}

setupEditorFields().catch((err) => {
  console.error("Setup failed:", err);
  process.exit(1);
});
