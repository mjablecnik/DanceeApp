import { reverseGeocode, forwardGeocode } from "../clients/nominatim-client";
import {
  createVenue,
  findVenue,
  findVenueByCoordinates,
} from "../clients/directus-client";
import type { FacebookLocation, DirectusVenue } from "../core/schemas";
import { log } from "../core/logger";

export async function resolveVenue(location: FacebookLocation): Promise<DirectusVenue | null> {
  const lat = location.latitude;
  const lng = location.longitude;

  // Check existing venue by coordinates first
  if (lat !== undefined && lng !== undefined) {
    const byCoords = await findVenueByCoordinates(lat, lng);
    if (byCoords) return byCoords;
  }

  // Build venue fields from Facebook location data
  const name = location.name ?? "";
  const fbAddress = location.address ?? "";
  const fbTown = location.city ?? "";
  const fbCountry = location.countryCode ?? location.country ?? "";

  // Determine address source: if FB provides address, it's authoritative
  const hasFbAddress = !!fbAddress;
  let address = fbAddress;
  let town = fbTown;
  let country = fbCountry;
  let postalCode = "";
  let region = "Other";
  let addressSource: "facebook" | "nominatim" = hasFbAddress ? "facebook" : "nominatim";

  // Check existing venue by (name, address, town) BEFORE calling Nominatim
  if (name && address && town) {
    const byFields = await findVenue(name, address, town);
    if (byFields) return byFields;
  }

  // Use Nominatim to supplement missing fields (city, country, region, postal_code)
  // or to build the address when FB didn't provide one
  if (lat !== undefined && lng !== undefined) {
    try {
      const geo = await reverseGeocode(lat, lng);
      const addr = geo.address ?? {};

      // Only use Nominatim address if FB didn't provide one
      if (!hasFbAddress) {
        const road = addr.road ?? "";
        const houseNumber = addr.house_number ?? "";
        address = houseNumber ? `${road} ${houseNumber}`.trim() : road;
      }

      // Fill in missing city/country from Nominatim
      town = town || addr.city || addr.town || addr.village || addr.county || "";
      country = country || addr.country_code?.toUpperCase() || "";
      postalCode = addr.postcode ?? "";
      region = addr.state ?? addr.city ?? addr.town ?? "Other";
    } catch (err) {
      log({ level: "warn", message: `reverseGeocode failed for coordinates (${lat}, ${lng}), falling back to region "Other"`, error: String(err) });
    }
  } else if (name || town) {
    // No coordinates — try forward geocoding by venue name or town
    try {
      const query = town || name;
      const geo = await forwardGeocode(query);
      if (geo) {
        const addr = geo.address ?? {};
        town = town || addr.city || addr.town || addr.village || addr.county || "";
        country = country || addr.country_code?.toUpperCase() || "";
        postalCode = postalCode || addr.postcode || "";
        region = addr.state ?? addr.city ?? addr.town ?? "Other";
      }
    } catch (err) {
      log({ level: "warn", message: `forwardGeocode failed for "${town || name}", falling back to region "Other"`, error: String(err) });
    }
  }

  // When all identifying fields are empty, there is nothing meaningful to store.
  if (!name && !address && !town) {
    log({ level: "warn", message: `resolveVenue: all identifying venue fields are empty for location (${lat ?? "?"}, ${lng ?? "?"}), skipping venue creation` });
    return null;
  }

  const newVenue: DirectusVenue = {
    name,
    address,
    town,
    country,
    postal_code: postalCode,
    region,
    latitude: lat ?? null,
    longitude: lng ?? null,
    address_source: addressSource,
    verified: false,
  };

  return createVenue(newVenue);
}
