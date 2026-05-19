// Ambient type declarations for the facebook-event-scraper GitHub fork,
// which ships without a pre-built dist/ folder. The Docker build compiles
// the package from source; this stub keeps local tsc builds working.
declare module "facebook-event-scraper" {
  export enum EventType {
    Upcoming = "upcoming",
    Past = "past",
  }

  export interface ScrapeOptions {
    cookies?: string;
  }

  export function scrapeFbEvent(url: string, options?: ScrapeOptions): Promise<unknown>;
  export function scrapeFbEventList(
    url: string,
    eventType?: EventType,
    options?: ScrapeOptions,
  ): Promise<unknown[]>;
}
