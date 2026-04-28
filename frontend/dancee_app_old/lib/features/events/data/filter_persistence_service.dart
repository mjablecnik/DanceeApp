import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../logic/event_filter.dart';

/// Handles optional persistence of [FilterState] via SharedPreferences.
///
/// Filters are only persisted when the user explicitly calls [saveFilters].
/// On deserialization failure, [loadFilters] returns `null` so the caller
/// can fall back to the default empty state.
class FilterPersistenceService {
  static const _key = 'saved_event_filters';

  /// Loads the previously saved [FilterState] from SharedPreferences.
  ///
  /// Returns `null` if no filters are saved or if the stored JSON is corrupt.
  Future<FilterState?> loadFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FilterState.fromJson(json);
    } catch (e, stack) {
      developer.log(
        'Failed to load filters: $e',
        name: 'FilterPersistenceService',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Serializes [filters] to JSON and writes it to SharedPreferences.
  ///
  /// Throws if the write fails (e.g. storage full). Callers should handle
  /// persistence errors and show appropriate user feedback.
  Future<void> saveFilters(FilterState filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(filters.toJson());
      await prefs.setString(_key, jsonString);
    } catch (e, stack) {
      developer.log(
        'Failed to save filters: $e',
        name: 'FilterPersistenceService',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Removes the saved filters from SharedPreferences.
  ///
  /// Throws if the remove fails. Callers should handle persistence errors.
  Future<void> clearFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e, stack) {
      developer.log(
        'Failed to clear filters: $e',
        name: 'FilterPersistenceService',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
