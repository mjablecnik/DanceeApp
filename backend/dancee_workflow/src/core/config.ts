import * as dotenv from "dotenv";
import * as Sentry from "@sentry/node";

dotenv.config();

export const config = {
  openRouterApiKey: process.env.OPENROUTER_API_KEY ?? "",
  openRouterModel: process.env.OPENROUTER_MODEL ?? "google/gemini-2.0-flash-001",
  imageGenerationModel: process.env.IMAGE_GENERATION_MODEL ?? "black-forest-labs/flux.2-pro",
  directusBaseUrl: process.env.DIRECTUS_BASE_URL ?? "",
  directusAccessToken: process.env.DIRECTUS_ACCESS_TOKEN ?? "",
  nominatimBaseUrl: process.env.NOMINATIM_BASE_URL ?? "https://nominatim.openstreetmap.org",
  sentryDsn: process.env.SENTRY_DSN ?? "",
  corsOrigins: process.env.CORS_ORIGINS ?? "*",
  appPort: parseInt(process.env.APP_PORT ?? "9080", 10),
  // Request timeout in milliseconds for each external service.
  // These prevent hanging workflows when a downstream service is unresponsive.
  directusTimeoutMs: parseInt(process.env.DIRECTUS_TIMEOUT_MS ?? "30000", 10),
  nominatimTimeoutMs: parseInt(process.env.NOMINATIM_TIMEOUT_MS ?? "10000", 10),
  // LLM temperature for structured output (classification, extraction, translation).
  // Lower values reduce non-determinism and improve JSON reliability.
  llmTemperature: parseFloat(process.env.LLM_TEMPERATURE ?? "0.1"),
  // Facebook cookies for authenticated scraping (raw cookie string, e.g. "c_user=123; xs=abc").
  // When set, the scraper sends requests as a logged-in user, which unlocks
  // private events and reduces the chance of being rate-limited.
  fbCookies: process.env.FB_COOKIES ?? "",
  // Minimum delay in milliseconds between consecutive Facebook scrape requests.
  // Actual delay is randomized between min and max to avoid predictable patterns.
  scrapeDelayMinMs: parseInt(process.env.SCRAPE_DELAY_MIN_MS ?? "4000", 10),
  // Maximum delay in milliseconds between consecutive Facebook scrape requests.
  scrapeDelayMaxMs: parseInt(process.env.SCRAPE_DELAY_MAX_MS ?? "10000", 10),
};

export function validateConfig(): void {
  const required: Array<{ key: keyof typeof config; envVar: string }> = [
    { key: "openRouterApiKey", envVar: "OPENROUTER_API_KEY" },
    { key: "directusBaseUrl", envVar: "DIRECTUS_BASE_URL" },
    { key: "directusAccessToken", envVar: "DIRECTUS_ACCESS_TOKEN" },
  ];

  const missing = required
    .filter(({ key }) => !config[key])
    .map(({ envVar }) => envVar);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(", ")}. ` +
      "Set these variables before starting the service.",
    );
  }
}

export function initSentry(): void {
  if (!config.sentryDsn) {
    console.warn("Sentry DSN is not set. Sentry integration will be disabled.");
    return;
  }
  Sentry.init({ dsn: config.sentryDsn });
}

export function captureError(error: Error, context: Record<string, string>): void {
  Sentry.withScope((scope) => {
    for (const [key, value] of Object.entries(context)) {
      scope.setTag(key, value);
    }
    Sentry.captureException(error);
  });
}
