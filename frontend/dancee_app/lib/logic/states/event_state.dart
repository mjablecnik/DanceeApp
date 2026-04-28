import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/entities/event.dart';

part 'event_state.freezed.dart';

@freezed
class EventState with _$EventState {
  const factory EventState.initial() = _Initial;
  const factory EventState.loading() = _Loading;
  const factory EventState.loaded({
    required List<Event> allEvents,
    required List<Event> filteredEvents,
    required List<Event> featuredEvents,
  }) = _Loaded;
  const factory EventState.error({required String message}) = _Error;
}
