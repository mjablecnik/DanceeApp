/**
 * Creates Directus Flows for reprocessing events from the admin UI.
 * Each flow adds a manual trigger button in the Events detail view.
 *
 * Usage:
 *   bun run scripts/setup-directus-flows.ts
 *   bun run scripts/setup-directus-flows.ts --clean
 */

import * as dotenv from "dotenv";
dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";
const WORKFLOW_BASE_URL = process.env.WORKFLOW_BASE_URL ?? "https://dancee-workflow.fly.dev";

if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
  console.error("Error: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set.");
  process.exit(1);
}

const headers = {
  "Content-Type": "application/json",
  Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
};

async function api(method: string, path: string, body?: unknown) {
  const res = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method,
    headers,
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const json = await res.json().catch(() => null);
  if (!res.ok) {
    throw new Error(`${method} ${path} failed (${res.status}): ${JSON.stringify(json)}`);
  }
  return json as { data: Record<string, unknown> };
}

const FLOW_NAMES = [
  "Reprocess All", "Retranslate", "Re-extract Parts", "Re-extract Info",
  "Retranslate This Language",
  "Notify Author on Contact Message",
];

async function clean() {
  console.log("Cleaning existing reprocess flows...");
  const res = await api("GET", "/flows?fields=id,name&limit=-1");
  const flows = (res.data as unknown) as { id: string; name: string }[];
  for (const flow of flows) {
    if (FLOW_NAMES.includes(flow.name)) {
      console.log(`  Deleting: ${flow.name} (${flow.id})`);
      await api("DELETE", `/flows/${flow.id}`);
    }
  }
  console.log("Clean done.\n");
}

interface FlowDef {
  name: string;
  icon: string;
  color: string;
  description: string;
  collection: string;
  body: Record<string, unknown>;
}

async function createFlow(def: FlowDef) {
  console.log(`Creating flow: ${def.name} (${def.collection})...`);

  const flowRes = await api("POST", "/flows", {
    name: def.name,
    description: def.description,
    icon: def.icon,
    color: def.color,
    status: "active",
    trigger: "manual",
    options: {
      collections: [def.collection],
      location: "item",
      requireConfirmation: true,
      confirmationDescription: `Are you sure you want to run: ${def.name}?`,
    },
  });

  const flowId = flowRes.data.id as string;
  console.log(`  Flow created: ${flowId}`);

  const webhookBody = JSON.stringify(def.body);

  const opRes = await api("POST", "/operations", {
    name: "Call Reprocess API",
    key: "reprocess_webhook",
    type: "request",
    flow: flowId,
    position_x: 19,
    position_y: 1,
    options: {
      method: "POST",
      url: `${WORKFLOW_BASE_URL}/api/event/reprocess`,
      headers: [{ header: "Content-Type", value: "application/json" }],
      body: webhookBody,
    },
  });

  const opId = opRes.data.id as string;
  await api("PATCH", `/flows/${flowId}`, { operation: opId });
  console.log(`  Operation linked: ${opId}`);
}

// ---- Contact message email notification flow ----

const AUTHOR_EMAIL = process.env.AUTHOR_EMAIL ?? "admin@dancee.app";

async function createContactMessageEmailFlow(): Promise<void> {
  // Check if it already exists
  const res = await api("GET", "/flows?fields=id,name&limit=-1");
  const flows = (res.data as unknown) as { id: string; name: string }[];
  if (flows.some((f) => f.name === "Notify Author on Contact Message")) {
    console.log("Flow 'Notify Author on Contact Message' already exists, skipping.");
    return;
  }

  console.log("Creating flow: Notify Author on Contact Message...");

  const flowRes = await api("POST", "/flows", {
    name: "Notify Author on Contact Message",
    description: "Send email to author when a new contact message is submitted",
    icon: "mail",
    color: "#FF6B6B",
    status: "active",
    trigger: "event",
    options: {
      type: "filter",
      scope: ["items.create"],
      collections: ["contact_messages"],
    },
  });

  const flowId = flowRes.data.id as string;
  console.log(`  Flow created: ${flowId}`);

  const opRes = await api("POST", "/operations", {
    name: "Send Email Notification",
    key: "send_contact_email",
    type: "mail",
    flow: flowId,
    position_x: 19,
    position_y: 1,
    options: {
      to: [AUTHOR_EMAIL],
      subject: "[Dancee Contact] {{$trigger.payload.type}}: {{$trigger.payload.title}}",
      body: `<p>A new contact message has been submitted on Dancee.</p>

<p><strong>Type:</strong> {{$trigger.payload.type}}</p>
<p><strong>Title:</strong> {{$trigger.payload.title}}</p>
<p><strong>Message:</strong></p>
<blockquote>{{$trigger.payload.message}}</blockquote>

<p><strong>Reply to:</strong> {{$trigger.payload.reply_email}}</p>
<p><strong>Phone:</strong> {{$trigger.payload.phone}}</p>
<p><strong>Submitted at:</strong> {{$trigger.payload.date_created}}</p>

<hr>
<p><em>Device Info:</em> {{$trigger.payload.device_info}}</p>`,
    },
  });

  const opId = opRes.data.id as string;
  await api("PATCH", `/flows/${flowId}`, { operation: opId });
  console.log(`  Operation linked: ${opId}`);
}

async function main() {
  if (process.argv.includes("--clean")) {
    await clean();
  }

  const flows: FlowDef[] = [
    // Event-level flows
    {
      name: "Reprocess All",
      icon: "autorenew",
      color: "#6644FF",
      description: "Re-extract parts, info, translations, and dances",
      collection: "events",
      body: { id: "{{$trigger.body.keys[0]}}", steps: ["parts", "info", "translations", "dances"] },
    },
    {
      name: "Retranslate",
      icon: "translate",
      color: "#2ECDA7",
      description: "Re-translate event to CS, EN, and ES",
      collection: "events",
      body: { id: "{{$trigger.body.keys[0]}}", steps: ["translations"] },
    },
    {
      name: "Re-extract Parts",
      icon: "category",
      color: "#FFA439",
      description: "Re-extract event parts and recompute dances",
      collection: "events",
      body: { id: "{{$trigger.body.keys[0]}}", steps: ["parts", "dances"] },
    },
    {
      name: "Re-extract Info",
      icon: "info",
      color: "#3399FF",
      description: "Re-extract event info (prices, URLs)",
      collection: "events",
      body: { id: "{{$trigger.body.keys[0]}}", steps: ["info"] },
    },
    // Translation-level flow
    {
      name: "Retranslate This Language",
      icon: "translate",
      color: "#E040FB",
      description: "Re-translate this specific language only",
      collection: "events_translations",
      body: { translationId: "{{$trigger.body.keys[0]}}", steps: ["translations"] },
    },
  ];

  for (const flow of flows) {
    await createFlow(flow);
  }

  await createContactMessageEmailFlow();

  console.log("\nDone. Flows are available in the Events detail view toolbar.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
