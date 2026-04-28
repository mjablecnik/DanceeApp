import 'package:equatable/equatable.dart';

import 'translation_utils.dart';
import 'venue.dart';

enum CourseType { workshop, regular }

class Course extends Equatable {
  const Course({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.description,
    this.instructorName,
    this.instructorBio,
    this.instructorAvatarUrl,
    this.venue,
    this.startDate,
    this.endDate,
    this.scheduleDay,
    this.scheduleTime,
    this.lessonCount,
    this.lessonDurationMinutes,
    this.maxParticipants,
    this.currentParticipants,
    this.price,
    this.priceNote,
    this.level,
    required this.dances,
    required this.learningItems,
    this.originalUrl,
    this.registrationUrl,
    required this.isFavorited,
  });

  final int id;
  final String? imageUrl;
  final String title;
  final String description;
  final String? instructorName;
  final String? instructorBio;
  final String? instructorAvatarUrl;
  final Venue? venue;
  final String? startDate;
  final String? endDate;
  final String? scheduleDay;
  final String? scheduleTime;
  final int? lessonCount;
  final int? lessonDurationMinutes;
  final int? maxParticipants;
  final int? currentParticipants;
  final String? price;
  final String? priceNote;
  final String? level;
  final List<String> dances;
  final List<String> learningItems;
  final String? originalUrl;
  final String? registrationUrl;
  final bool isFavorited;

  /// Computed course type for filtering.
  CourseType get courseType {
    if (lessonCount != null && lessonCount! > 1) return CourseType.regular;
    if (startDate != null && endDate != null && startDate != endDate) {
      return CourseType.regular;
    }
    return CourseType.workshop;
  }

  factory Course.fromDirectus(
    Map<String, dynamic> json, {
    required String languageCode,
    required String directusBaseUrl,
    Set<int> favoriteCourseIds = const {},
  }) {
    final translations = (json['translations'] as List<dynamic>?) ?? [];
    final translation = extractTranslation(translations, languageCode);

    final title = (translation?['title'] as String?) ??
        (json['title'] as String?) ??
        '';
    final description =
        (translation?['description'] as String?) ?? '';
    final learningItems =
        (translation?['learning_items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

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

    final id = json['id'] as int;

    return Course(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
      instructorName: json['instructor_name'] as String?,
      instructorBio: json['instructor_bio'] as String?,
      instructorAvatarUrl: json['instructor_avatar_url'] as String?,
      venue: venue,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      scheduleDay: json['schedule_day'] as String?,
      scheduleTime: json['schedule_time'] as String?,
      lessonCount: json['lesson_count'] as int?,
      lessonDurationMinutes: json['lesson_duration_minutes'] as int?,
      maxParticipants: json['max_participants'] as int?,
      currentParticipants: json['current_participants'] as int?,
      price: json['price'] as String?,
      priceNote: json['price_note'] as String?,
      level: json['level'] as String?,
      dances: dances,
      learningItems: learningItems,
      originalUrl: json['original_url'] as String?,
      registrationUrl: json['registration_url'] as String?,
      isFavorited: favoriteCourseIds.contains(id),
    );
  }

  Course copyWith({bool? isFavorited}) {
    return Course(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
      instructorName: instructorName,
      instructorBio: instructorBio,
      instructorAvatarUrl: instructorAvatarUrl,
      venue: venue,
      startDate: startDate,
      endDate: endDate,
      scheduleDay: scheduleDay,
      scheduleTime: scheduleTime,
      lessonCount: lessonCount,
      lessonDurationMinutes: lessonDurationMinutes,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      price: price,
      priceNote: priceNote,
      level: level,
      dances: dances,
      learningItems: learningItems,
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
        instructorName,
        instructorBio,
        instructorAvatarUrl,
        venue,
        startDate,
        endDate,
        scheduleDay,
        scheduleTime,
        lessonCount,
        lessonDurationMinutes,
        maxParticipants,
        currentParticipants,
        price,
        priceNote,
        level,
        dances,
        learningItems,
        originalUrl,
        registrationUrl,
        isFavorited,
      ];
}

