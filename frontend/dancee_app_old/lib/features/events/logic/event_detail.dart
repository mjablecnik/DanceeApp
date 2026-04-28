import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../i18n/translations.g.dart';
import '../data/entities.dart';
import 'event_list.dart';

/// Cubit for managing the event detail page state.
///
/// Emits [Event?] directly — null means event not found.
/// Reads the event from [EventListCubit] state, delegates favorite
/// toggling to [EventListCubit.toggleFavorite], and stays in sync
/// via stream subscription. Launches external map/URL navigation
/// via url_launcher.
class EventDetailCubit extends Cubit<Event?> {
  final EventListCubit _eventListCubit;
  final String eventId;
  StreamSubscription<EventListState>? _subscription;
  final _errorController = StreamController<String>.broadcast();

  /// Stream of error messages for URL-launch failures.
  ///
  /// The UI layer should listen to this stream and show appropriate feedback
  /// (e.g. a snackbar) when a URL fails to open.
  Stream<String> get errorStream => _errorController.stream;

  EventDetailCubit({
    required EventListCubit eventListCubit,
    required this.eventId,
  })  : _eventListCubit = eventListCubit,
        super(null) {
    _loadEvent();
    _subscription = _eventListCubit.stream.listen(_onListStateChanged);
  }

  void _loadEvent() {
    final listState = _eventListCubit.state;
    if (listState is EventListLoaded) {
      final event = listState.allEvents
          .where((e) => e.id == eventId)
          .firstOrNull;
      emit(event);
    }
  }

  void _onListStateChanged(EventListState listState) {
    if (listState is EventListLoaded) {
      final event = listState.allEvents
          .where((e) => e.id == eventId)
          .firstOrNull;
      emit(event);
    }
  }

  /// Delegates favorite toggling to [EventListCubit].
  ///
  /// The list cubit handles the API call, optimistic update, and error
  /// recovery. This cubit picks up the change via stream subscription.
  Future<void> toggleFavorite() async {
    await _eventListCubit.toggleFavorite(eventId);
  }

  /// Opens an external map application with directions to the venue.
  ///
  /// Uses venue coordinates for navigation.
  Future<void> openMap(Venue venue) async {
    try {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log(
        'Failed to open map: $e',
        name: 'EventDetailCubit',
        level: 900,
      );
      _errorController.add(t.errors.genericError);
    }
  }

  /// Opens an external URL via url_launcher.
  Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log(
        'Failed to open URL: $e',
        name: 'EventDetailCubit',
        level: 900,
      );
      _errorController.add(t.errors.genericError);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _errorController.close();
    return super.close();
  }
}
