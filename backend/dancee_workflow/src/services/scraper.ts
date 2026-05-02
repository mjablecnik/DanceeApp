import {
  scrapeFbEvent,
  scrapeFbEventList,
  EventType,
} from "facebook-event-scraper";
import type { ScrapeOptions } from "facebook-event-scraper";
import { config } from "../core/config";

/** Timestamp of the last scrape request — used for rate limiting. */
let lastScrapeTime = 0;

/**
 * Returns a random delay between the configured min and max scrape delay.
 * Randomizing the interval makes the request pattern less predictable,
 * reducing the chance of Facebook flagging the account.
 */
function randomDelay(): number {
  const { scrapeDelayMinMs, scrapeDelayMaxMs } = config;
  return Math.floor(Math.random() * (scrapeDelayMaxMs - scrapeDelayMinMs + 1)) + scrapeDelayMinMs;
}

/**
 * Wait if needed so that consecutive scrape requests are spaced at least
 * a random interval (between min and max delay) apart. This prevents
 * aggressive and predictable request patterns that could trigger
 * Facebook account blocks.
 */
async function throttle(): Promise<void> {
  const now = Date.now();
  const elapsed = now - lastScrapeTime;
  const delay = randomDelay();
  if (elapsed < delay) {
    await new Promise((resolve) => setTimeout(resolve, delay - elapsed));
  }
  lastScrapeTime = Date.now();
}

/** Build ScrapeOptions with cookies when configured. */
function buildScrapeOptions(): ScrapeOptions {
  const options: ScrapeOptions = {};
  if (config.fbCookies) {
    options.cookies = config.fbCookies;
  }
  return options;
}

/**
 * Scrape a single Facebook event by URL.
 * Wraps the facebook-event-scraper library for direct in-process usage.
 */
export async function scrapeFacebookEvent(eventUrl: string): Promise<unknown> {
  try {
    console.log(`Scraping event: ${eventUrl}`);
    await throttle();
    const eventData = await scrapeFbEvent(eventUrl, buildScrapeOptions());
    console.log(`Successfully scraped event: ${eventUrl}`);
    return eventData;
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Failed to scrape event ${eventUrl}:`, message);
    throw new Error(
      `Failed to scrape event [${eventUrl}]: ${message}`,
    );
  }
}

/**
 * Scrape a list of events from a Facebook page, group, or profile.
 * Wraps the facebook-event-scraper library for direct in-process usage.
 */
export async function scrapeFacebookEventList(
  pageUrl: string,
  eventType?: "upcoming" | "past",
): Promise<unknown[]> {
  try {
    console.log(`Scraping event list from: ${pageUrl} (type: ${eventType ?? "all"})`);

    let fbEventType: EventType | undefined;
    if (eventType === "upcoming") {
      fbEventType = EventType.Upcoming;
    } else if (eventType === "past") {
      fbEventType = EventType.Past;
    }

    await throttle();
    const events = await scrapeFbEventList(pageUrl, fbEventType, buildScrapeOptions());
    console.log(`Successfully scraped ${events.length} events from: ${pageUrl}`);
    return events;
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Failed to scrape event list from ${pageUrl}:`, message);
    throw new Error(
      `Failed to scrape event list [${pageUrl}]: ${message}`,
    );
  }
}
