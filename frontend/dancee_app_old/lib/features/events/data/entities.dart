import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';

// ============================================================================
// Address
// ============================================================================

/// Represents a physical address with street, city, postal code, and country.
class Address extends Equatable {
  final String street;
  final String city;
  final String postalCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  String get fullAddress => '$street, $postalCode $city, $country';

  /// Creates an Address from a Directus venue JSON (flat structure).
  factory Address.fromDirectusVenue(Map<String, dynamic> json) {
    final street = json['street'] as String? ?? '';
    final number = json['number'] as String? ?? '';
    final fullStreet = number.isNotEmpty ? '$street $number' : street;
    return Address(
      street: fullStreet,
      city: json['town'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  /// Creates an Address from the format produced by [toJson].
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }

  Address copyWith({
    String? street,
    String? city,
    String? postalCode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [street, city, postalCode, country];
}

// ============================================================================
// Venue
// ============================================================================

/// Represents a venue where dance events take place.
class Venue extends Equatable {
  final String name;
  final Address address;
  final String description;
  final double latitude;
  final double longitude;
  final String region;

  const Venue({
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.region = '',
  });

  /// Creates a Venue from a Directus venue JSON (expanded via `venue.*`).
  factory Venue.fromDirectus(Map<String, dynamic> json) {
    return Venue(
      name: json['name'] as String? ?? '',
      address: Address.fromDirectusVenue(json),
      description: '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      region: json['region'] as String? ?? '',
    );
  }

  /// Creates a Venue from the format produced by [toJson].
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'] as String? ?? '',
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      region: json['region'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address.toJson(),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'region': region,
    };
  }

  Venue copyWith({
    String? name,
    Address? address,
    String? description,
    double? latitude,
    double? longitude,
    String? region,
  }) {
    return Venue(
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      region: region ?? this.region,
    );
  }

  @override
  List<Object?> get props => [name, address, description, latitude, longitude, region];
}

// ============================================================================
// EventInfo
// ============================================================================

enum EventInfoType { text, url, price }

/// Represents additional information about an event.
class EventInfo extends Equatable {
  final EventInfoType type;
  final String key;
  final String value;

  const EventInfo({
    required this.type,
    required this.key,
    required this.value,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      type: EventInfoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventInfoType.text,
      ),
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return { 'type': type.name, 'key': key, 'value': value };
  }

  EventInfo copyWith({EventInfoType? type, String? key, String? value}) {
    return EventInfo(
      type: type ?? this.type,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [type, key, value];
}

// ============================================================================
// EventPart
// ============================================================================

enum EventPartType { party, workshop, openLesson }

/// Represents a part of an event (e.g., workshop before party).
class EventPart extends Equatable {
  final String name;
  final String? description;
  final EventPartType type;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String>? lectors;
  final List<String>? djs;

  const EventPart({
    required this.name,
    this.description,
    required this.type,
    required this.startTime,
    this.endTime,
    this.lectors,
    this.djs,
  });

  /// Creates an EventPart from Directus JSON.
  ///
  /// Directus stores parts as JSON with `date_time_range.start/end`
  /// instead of `startTime/endTime`.
  factory EventPart.fromDirectus(Map<String, dynamic> json) {
    final dateRange = json['date_time_range'] as Map<String, dynamic>?;
    final startStr = dateRange?['start'] as String?;
    final endStr = dateRange?['end'] as String?;

    if (startStr == null) {
      developer.log(
        'EventPart.fromDirectus: missing start time in date_time_range for part '
        '"${json['name']}"; falling back to DateTime.now()',
        name: 'EventPart',
        level: 900,
      );
    }

    return EventPart(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: _parsePartType(json['type'] as String?),
      startTime: startStr != null
          ? DateTime.parse(startStr)
          : DateTime.now(),
      endTime: endStr != null ? DateTime.parse(endStr) : null,
      lectors: (json['lectors'] as List<dynamic>?)?.cast<String>(),
      djs: (json['djs'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Creates an EventPart from the format produced by [toJson].
  factory EventPart.fromJson(Map<String, dynamic> json) {
    final startTimeStr = json['startTime'] as String?;
    final endTimeStr = json['endTime'] as String?;
    return EventPart(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: _parsePartType(json['type'] as String?),
      startTime: startTimeStr != null
          ? DateTime.parse(startTimeStr)
          : DateTime.now(),
      endTime: endTimeStr != null ? DateTime.parse(endTimeStr) : null,
      lectors: (json['lectors'] as List<dynamic>?)?.cast<String>(),
      djs: (json['djs'] as List<dynamic>?)?.cast<String>(),
    );
  }

  static EventPartType _parsePartType(String? type) {
    switch (type) {
      case 'party':
        return EventPartType.party;
      case 'workshop':
        return EventPartType.workshop;
      case 'openLesson':
        return EventPartType.openLesson;
      default:
        return EventPartType.party;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'lectors': lectors,
      'djs': djs,
    };
  }

  EventPart copyWith({
    String? name,
    String? description,
    EventPartType? type,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? lectors,
    List<String>? djs,
  }) {
    return EventPart(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lectors: lectors ?? this.lectors,
      djs: djs ?? this.djs,
    );
  }

  @override
  List<Object?> get props =>
      [name, description, type, startTime, endTime, lectors, djs];
}

// ============================================================================
// Event
// ============================================================================

/// Represents a dance event with all its details.
class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final Venue venue;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final List<String> dances;
  final List<EventInfo> info;
  final List<EventPart> parts;
  final bool isFavorite;
  final bool isPast;
  final String? badge;
  final String? sourceUrl;
  final String? timezone;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.venue,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.dances,
    this.info = const [],
    this.parts = const [],
    this.isFavorite = false,
    this.isPast = false,
    this.badge,
    this.sourceUrl,
    this.timezone,
  });

  /// Creates an Event from a Directus API response.
  ///
  /// Expects the event to be fetched with `fields=*,venue.*,translations.*`
  /// so that venue and translations are expanded objects.
  /// The [language] parameter selects which translation to use for
  /// title and description (defaults to 'cs').
  /// The [favoriteIds] set marks events as favorites locally.
  factory Event.fromDirectus(
    Map<String, dynamic> json, {
    String language = 'cs',
    Set<String> favoriteIds = const {},
    DateTime? now,
  }) {
    final id = json['id'].toString();

    // Parse venue (expanded M2O relation)
    Venue venue;
    final venueData = json['venue'];
    if (venueData is Map<String, dynamic>) {
      venue = Venue.fromDirectus(venueData);
    } else {
      venue = const Venue(
        name: '',
        address: Address(street: '', city: '', postalCode: '', country: ''),
        description: '',
        latitude: 0,
        longitude: 0,
        region: '',
      );
    }

    // Parse translations to find the requested language
    String title = json['title'] as String? ?? '';
    String description = json['original_description'] as String? ?? '';
    final translations = json['translations'] as List<dynamic>?;
    if (translations != null) {
      for (final t in translations) {
        if (t is Map<String, dynamic> &&
            t['languages_code'] == language) {
          title = t['title'] as String? ?? title;
          description = t['description'] as String? ?? description;
          break;
        }
      }
    }

    // Parse start/end times
    final startTime = DateTime.parse(json['start_time'] as String);
    final endTimeStr = json['end_time'] as String?;
    final endTime = endTimeStr != null ? DateTime.parse(endTimeStr) : null;

    // Compute duration
    Duration? duration;
    if (endTime != null) {
      duration = endTime.difference(startTime);
    }

    // Compute isPast relative to the provided [now] (defaults to DateTime.now()).
    // Accepting [now] as a parameter enables deterministic unit testing.
    final effectiveNow = now ?? DateTime.now();
    final isPast = endTime != null
        ? endTime.isBefore(effectiveNow)
        : startTime.isBefore(effectiveNow);

    // Parse dances
    final dances = (json['dances'] as List<dynamic>?)?.cast<String>() ?? [];

    // Parse info
    final info = (json['info'] as List<dynamic>?)
            ?.map((i) => EventInfo.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse parts
    final parts = (json['parts'] as List<dynamic>?)
            ?.map((p) => EventPart.fromDirectus(p as Map<String, dynamic>))
            .toList() ??
        [];

    return Event(
      id: id,
      title: title,
      description: description,
      organizer: json['organizer'] as String? ?? '',
      venue: venue,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      dances: dances,
      info: info,
      parts: parts,
      isFavorite: favoriteIds.contains(id),
      isPast: isPast,
      sourceUrl: json['original_url'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Creates an Event from the format produced by [toJson].
  ///
  /// Note: this factory reads the camelCase keys produced by [toJson] (e.g.
  /// `startTime`, `venue` as a nested object). It is NOT interchangeable with
  /// [Event.fromDirectus], which reads Directus-specific snake_case keys.
  factory Event.fromJson(Map<String, dynamic> json) {
    final startTimeStr = json['startTime'] as String?;
    final endTimeStr = json['endTime'] as String?;
    final durationSeconds = json['duration'] as int?;

    final startTime = startTimeStr != null
        ? DateTime.parse(startTimeStr)
        : DateTime.now();
    final endTime = endTimeStr != null ? DateTime.parse(endTimeStr) : null;

    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      venue: Venue.fromJson(json['venue'] as Map<String, dynamic>? ?? {}),
      startTime: startTime,
      endTime: endTime,
      duration: durationSeconds != null
          ? Duration(seconds: durationSeconds)
          : null,
      dances: (json['dances'] as List<dynamic>?)?.cast<String>() ?? [],
      info: (json['info'] as List<dynamic>?)
              ?.map((i) => EventInfo.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      parts: (json['parts'] as List<dynamic>?)
              ?.map((p) => EventPart.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPast: json['isPast'] as bool? ?? false,
      badge: json['badge'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'venue': venue.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'dances': dances,
      'info': info.map((i) => i.toJson()).toList(),
      'parts': parts.map((p) => p.toJson()).toList(),
      'isFavorite': isFavorite,
      'isPast': isPast,
      'badge': badge,
      'sourceUrl': sourceUrl,
      'timezone': timezone,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? organizer,
    Venue? venue,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    List<String>? dances,
    List<EventInfo>? info,
    List<EventPart>? parts,
    bool? isFavorite,
    bool? isPast,
    String? badge,
    String? sourceUrl,
    String? timezone,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      venue: venue ?? this.venue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      dances: dances ?? this.dances,
      info: info ?? this.info,
      parts: parts ?? this.parts,
      isFavorite: isFavorite ?? this.isFavorite,
      isPast: isPast ?? this.isPast,
      badge: badge ?? this.badge,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, organizer, venue, startTime, endTime,
        duration, dances, info, parts, isFavorite, isPast, badge, sourceUrl,
        timezone,
      ];
}

// ============================================================================
// DanceStyle
// ============================================================================

/// Represents a dance style from the backend `dance_styles` collection.
///
/// Parent styles have [parentCode] == null.
/// Child styles have [parentCode] set to their parent's [code].
class DanceStyle extends Equatable {
  final String code;
  final String name;
  final String? parentCode;

  const DanceStyle({
    required this.code,
    required this.name,
    this.parentCode,
  });

  factory DanceStyle.fromJson(Map<String, dynamic> json) {
    return DanceStyle(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      parentCode: json['parent_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'parent_code': parentCode,
    };
  }

  DanceStyle copyWith({
    String? code,
    String? name,
    String? parentCode,
  }) {
    return DanceStyle(
      code: code ?? this.code,
      name: name ?? this.name,
      parentCode: parentCode ?? this.parentCode,
    );
  }

  @override
  List<Object?> get props => [code, name, parentCode];
}
