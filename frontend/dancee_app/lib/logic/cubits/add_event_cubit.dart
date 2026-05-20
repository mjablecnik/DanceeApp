import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/repositories/event_repository.dart';
import '../states/add_event_state.dart';

class AddEventCubit extends Cubit<AddEventState> {
  AddEventCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const AddEventState.idle());

  final EventRepository _eventRepository;

  /// Submits a new user event. Always sets published=false and reviewed=false.
  Future<void> submitEvent(Map<String, dynamic> fields) async {
    emit(const AddEventState.submitting());
    try {
      await _eventRepository.createEvent(fields);
      emit(const AddEventState.success());
    } catch (e) {
      emit(AddEventState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  void reset() => emit(const AddEventState.idle());
}
