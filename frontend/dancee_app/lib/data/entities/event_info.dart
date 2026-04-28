import 'package:equatable/equatable.dart';

enum EventInfoType { url, price, dresscode }

class EventInfo extends Equatable {
  const EventInfo({
    required this.type,
    required this.key,
    required this.value,
  });

  final EventInfoType type;
  final String key;
  final String value;

  factory EventInfo.fromDirectus(
    Map<String, dynamic> json, {
    Map<String, dynamic>? translation,
  }) {
    final rawType = (json['type'] as String?) ?? '';
    final type = switch (rawType) {
      'price' => EventInfoType.price,
      'dresscode' => EventInfoType.dresscode,
      _ => EventInfoType.url,
    };

    final translatedKey =
        (translation?['key'] as String?) ?? (json['key'] as String?) ?? '';
    final value = (json['value'] as String?) ?? '';

    return EventInfo(type: type, key: translatedKey, value: value);
  }

  @override
  List<Object?> get props => [type, key, value];
}
