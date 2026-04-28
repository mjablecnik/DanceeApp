import 'package:equatable/equatable.dart';

import 'event_info.dart';
import 'event_part.dart';
import 'translation_utils.dart';
import 'venue.dart';

enum EventDurationType { evening, weekend, multiDay }

class Event extends Equatable {
  const Event({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    this.timezone,
    required this.organizer,
    this.venue,
    required this.dances,
    required this.eventType,
    required this.info,
    required this.parts,
    this.originalUrl,
    this.registrationUrl,
    required this.isFavorited,
  });

  final int id;
  final String? imageUrl;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? timezone;
  final String organizer;
  final Venue? venue;
  final List<String> dances;
  final String eventType;
  final List<EventInfo> info;
  final List<EventPart> parts;
  final String? originalUrl;
  final String? registrationUrl;
  final bool isFavorited;

  /// Computed duration type for filtering.
  EventDurationType get durationType {
    final end = endTime;
    if (end != null) {
      final days = end.difference(startTime).inHours / 24;
      if (days >= 2 || eventType == 'festival' || eventType == 'holiday') {
        // Weekend: starts Fri/Sat, lasts 2-3 days
        final weekday = startTime.weekday; // 1=Mon .. 7=Sun
        if (days <= 3 && (weekday == 5 || weekday == 6)) {
          return EventDurationType.weekend;
        }
        return EventDurationType.multiDay;
      }
    }
    // Festival/holiday type without end time
    if (eventType == 'festival' || eventType == 'holiday') {
      return EventDurationType.multiDay;
    }
    // Evening: starts at 17:00 or later
    if (startTime.hour >= 17) return EventDurationType.evening;
    return EventDurationType.evening;
  }

  factory Event.fromDirectus(
    Map<String, dynamic> json, {
    required String languageCode,
    required String directusBaseUrl,
    Set<int> favoriteEventIds = const {},
  }) {
    final translations = (json['translations'] as List<dynamic>?) ?? [];
    final translation = extractTranslation(translations, languageCode);

    final title = (translation?['title'] as String?) ??
        (json['title'] as String?) ??
        '';
    final description =
        (translation?['description'] as String?) ?? '';

    // Parse parts with translations
    final rawParts = (json['parts'] as List<dynamic>?) ?? [];
    final partsTranslations =
        (translation?['parts_translations'] as List<dynamic>?) ?? [];
    final parts = rawParts.asMap().entries.map((entry) {
      final partJson = entry.value as Map<String, dynamic>;
      final partTranslation = entry.key < partsTranslations.length
          ? partsTranslations[entry.key] as Map<String, dynamic>?
          : null;
      return EventPart.fromDirectus(partJson, translation: partTranslation);
    }).toList();

    // Parse info with translations
    final rawInfo = (json['info'] as List<dynamic>?) ?? [];
    final infoTranslations =
        (translation?['info_translations'] as List<dynamic>?) ?? [];
    final info = rawInfo.asMap().entries.map((entry) {
      final infoJson = entry.value as Map<String, dynamic>;
      final infoTranslation = entry.key < infoTranslations.length
          ? infoTranslations[entry.key] as Map<String, dynamic>?
          : null;
      return EventInfo.fromDirectus(infoJson, translation: infoTranslation);
    }).toList();

    // Parse venue
    final venueJson = json['venue'];
    final venue = venueJson is Map<String, dynamic>
        ? Venue.fromDirectus(venueJson)
        : null;

    // Construct image URL — image can be a UUID string or an expanded object with 'id'
    final rawImage = json['image'];
    final String? fileId;
    if (rawImage is Map<String, dynamic>) {
      fileId = rawImage['id']?.toString();
    } else if (rawImage != null) {
      fileId = rawImage.toString();
    } else {
      fileId = null;
    }
    final imageUrl = fileId != null ? '$directusBaseUrl/assets/$fileId' : null;

    // Parse dances
    final dances = (json['dances'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final startTimeStr = (json['start_time'] as String?) ?? '';
    final endTimeStr = json['end_time'] as String?;

    final id = json['id'] as int;

    return Event(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
      startTime: DateTime.tryParse(startTimeStr) ?? DateTime.now(),
      endTime: endTimeStr != null ? DateTime.tryParse(endTimeStr) : null,
      timezone: json['timezone'] as String?,
      organizer: (json['organizer'] as String?) ?? '',
      venue: venue,
      dances: dances,
      eventType: (json['event_type'] as String?) ?? '',
      info: info,
      parts: parts,
      originalUrl: json['original_url'] as String?,
      registrationUrl: json['registration_url'] as String?,
      isFavorited: favoriteEventIds.contains(id),
    );
  }

  Event copyWith({bool? isFavorited}) {
    return Event(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      timezone: timezone,
      organizer: organizer,
      venue: venue,
      dances: dances,
      eventType: eventType,
      info: info,
      parts: parts,
      originalUrl: originalUrl,
      registrationUrl: registrationUrl,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        title,
        description,
        startTime,
        endTime,
        timezone,
        organizer,
        venue,
        dances,
        eventType,
        info,
        parts,
        originalUrl,
        registrationUrl,
        isFavorited,
      ];
}

