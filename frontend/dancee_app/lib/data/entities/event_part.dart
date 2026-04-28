import 'package:equatable/equatable.dart';

class EventPart extends Equatable {
  const EventPart({
    required this.name,
    this.description,
    required this.type,
    this.startTime,
    this.endTime,
    required this.lectors,
    required this.djs,
  });

  final String name;
  final String? description;
  final String type;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> lectors;
  final List<String> djs;

  factory EventPart.fromDirectus(
    Map<String, dynamic> json, {
    Map<String, dynamic>? translation,
  }) {
    final translatedName =
        (translation?['name'] as String?) ?? (json['name'] as String?) ?? '';
    final translatedDescription =
        (translation?['description'] as String?) ??
        (json['description'] as String?);

    final rawDateRange = json['date_time_range'] as Map<String, dynamic>?;
    final startTimeStr = rawDateRange?['start'] as String? ?? json['start_time'] as String?;
    final endTimeStr = rawDateRange?['end'] as String? ?? json['end_time'] as String?;

    final lectors = (json['lectors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final djs =
        (json['djs'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    return EventPart(
      name: translatedName,
      description: translatedDescription,
      type: (json['type'] as String?) ?? '',
      startTime:
          startTimeStr != null ? DateTime.tryParse(startTimeStr) : null,
      endTime: endTimeStr != null ? DateTime.tryParse(endTimeStr) : null,
      lectors: lectors,
      djs: djs,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        type,
        startTime,
        endTime,
        lectors,
        djs,
      ];
}
