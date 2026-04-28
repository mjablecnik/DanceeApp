import '../../i18n/strings.g.dart';
import '../../logic/cubits/event_cubit.dart';

/// Translates a region code to a display label.
/// Converts [kAbroadRegionKey] to the localized "Abroad" string,
/// converts "Other" to a localized "Unknown location" string,
/// passes other region names through unchanged.
String regionLabel(String region) {
  if (region == kAbroadRegionKey) return t.events.filter.abroad;
  if (region == 'Other') return t.events.filter.unknownRegion;
  return region;
}
