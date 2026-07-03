/**
 * Migration script: venues schema update
 *
 * Migrates existing venues from old schema (street + number) to new schema (address).
 * Also adds address_source and verified fields.
 *
 * Steps:
 * 1. Creates new fields (address, address_source, verified) if they don't exist
 * 2. For each venue: merges street + number into address
 * 3. Sets address_source = "facebook" for all existing venues (they were originally from FB)
 * 4. Sets verified = false for all existing venues
 * 5. Optionally removes old fields (street, number) — disabled by default
 *
 * Usage: ./run-script.sh scripts/migrate-venues.ts
 *        ./run-script.sh scripts/migrate-venues.ts --delete-old-fields
 */

import * as dotenv from "dotenv";

dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";
const DELETE_OLD_FIELDS = process.argv.includes("--delete-old-fields");

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const res = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    headers: authHeaders(),
    signal: AbortSignal.timeout(30000),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`GET ${path} failed ${res.status}: ${text}`);
  }
  return res.json();
}

async function directusPatch(path: string, body: unknown): Promise<unknown> {
  const res = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method: "PATCH",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30000),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`PATCH ${path} failed ${res.status}: ${text}`);
  }
  return res.json();
}

async function directusPost(path: string, body: unknown): Promise<unknown> {
  const res = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30000),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    // Field already exists is OK
    if (res.status === 400 && text.includes("already exists")) return null;
    throw new Error(`POST ${path} failed ${res.status}: ${text}`);
  }
  return res.json();
}

async function directusDelete(path: string): Promise<void> {
  const res = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method: "DELETE",
    headers: authHeaders(),
    signal: AbortSignal.timeout(30000),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`DELETE ${path} failed ${res.status}: ${text}`);
  }
}

async function fieldExists(collection: string, field: string): Promise<boolean> {
  try {
    await directusGet(`/fields/${collection}/${field}`);
    return true;
  } catch {
    return false;
  }
}

async function createFieldIfNotExists(
  collection: string,
  field: string,
  type: string,
  meta: Record<string, unknown>,
  schema: Record<string, unknown> = {},
): Promise<void> {
  if (await fieldExists(collection, field)) {
    console.log(`  Field ${collection}.${field} already exists, skipping.`);
    return;
  }
  await directusPost(`/fields/${collection}`, { field, type, meta, schema });
  console.log(`  Created field ${collection}.${field}`);
}

// ---- Main migration ----

async function main() {
  console.log("=== Venue Schema Migration ===\n");

  // Step 1: Create new fields
  console.log("Step 1: Creating new fields...");

  await createFieldIfNotExists("venues", "address", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 500 });

  await createFieldIfNotExists("venues", "address_source", "string", {
    interface: "select-dropdown",
    options: { choices: [{ text: "Facebook", value: "facebook" }, { text: "Nominatim", value: "nominatim" }] },
  }, { is_nullable: true, max_length: 20 });

  await createFieldIfNotExists("venues", "verified", "boolean", {
    interface: "boolean",
    special: ["cast-boolean"],
  }, { is_nullable: false, default_value: false });

  // Step 2: Fetch all venues
  console.log("\nStep 2: Fetching all venues...");
  const data = await directusGet("/items/venues?limit=-1&fields=id,name,street,number,address,address_source,verified") as {
    data: Array<{
      id: number;
      name: string;
      street?: string | null;
      number?: string | null;
      address?: string | null;
      address_source?: string | null;
      verified?: boolean | null;
    }>;
  };

  const venues = data.data;
  console.log(`  Found ${venues.length} venues.`);

  // Step 3: Migrate each venue
  console.log("\nStep 3: Migrating venues...");
  let migrated = 0;
  let skipped = 0;

  for (const venue of venues) {
    // Skip if already migrated (address field is already populated)
    if (venue.address && venue.address.trim() !== "") {
      skipped++;
      continue;
    }

    // Merge street + number into address
    const street = venue.street?.trim() ?? "";
    const number = venue.number?.trim() ?? "";
    let address = "";

    if (street && number) {
      address = `${street} ${number}`;
    } else if (street) {
      address = street;
    } else if (number) {
      address = number;
    }

    const patch: Record<string, unknown> = {
      address,
      address_source: "facebook", // Existing venues were all sourced from FB
      verified: false,
    };

    await directusPatch(`/items/venues/${venue.id}`, patch);
    migrated++;

    if (migrated % 50 === 0) {
      console.log(`  Migrated ${migrated} venues...`);
    }
  }

  console.log(`  Done. Migrated: ${migrated}, Skipped (already had address): ${skipped}`);

  // Step 4: Optionally delete old fields
  if (DELETE_OLD_FIELDS) {
    console.log("\nStep 4: Deleting old fields (street, number)...");
    try {
      await directusDelete("/fields/venues/street");
      console.log("  Deleted field: street");
    } catch (err) {
      console.log(`  Could not delete street: ${err instanceof Error ? err.message : err}`);
    }
    try {
      await directusDelete("/fields/venues/number");
      console.log("  Deleted field: number");
    } catch (err) {
      console.log(`  Could not delete number: ${err instanceof Error ? err.message : err}`);
    }
  } else {
    console.log("\nStep 4: Skipping old field deletion (use --delete-old-fields to remove street/number).");
  }

  console.log("\n=== Migration complete ===");
}

main().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
