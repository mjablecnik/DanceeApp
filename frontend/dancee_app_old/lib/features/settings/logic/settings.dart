import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/entities.dart';
import '../data/settings_repository.dart';

part 'settings.freezed.dart';

// ============================================================================
// State
// ============================================================================

/// State for the SettingsCubit.
///
/// Uses freezed for immutability and union types:
/// - [initial]: Before any settings have been loaded
/// - [loading]: While a settings operation is in progress
/// - [loaded]: Settings loaded successfully (carries [UserSettings] entity)
/// - [error]: An error occurred during a settings operation
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsInitial;

  const factory SettingsState.loading() = SettingsLoading;

  const factory SettingsState.loaded(UserSettings settings) = SettingsLoaded;

  const factory SettingsState.error(String message) = SettingsError;
}

// ============================================================================
// Cubit
// ============================================================================

/// Cubit for managing user settings state.
///
/// Placeholder implementation — all methods emit appropriate states
/// until backend settings endpoints are integrated.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsState.initial());

  /// Loads the current user's settings.
  Future<void> loadSettings() async {
    emit(const SettingsState.loading());
    // TODO: Implement with repository
    emit(const SettingsState.initial());
  }

  /// Updates the user's settings.
  Future<void> updateSettings(UserSettings settings) async {
    emit(const SettingsState.loading());
    // TODO: Implement with repository
    emit(const SettingsState.initial());
  }

  /// Updates a single setting field.
  Future<void> updateSetting(String key, dynamic value) async {
    emit(const SettingsState.loading());
    // TODO: Implement with repository
    emit(const SettingsState.initial());
  }
}
