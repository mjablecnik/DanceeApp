// Feature: event-program-editing
// Task 7: Property-based tests (glados)
// Properties covered:
//   Property 1: Grouping round-trip preserves entries
//   Property 2: Serialization round-trip preserves data
//   Property 3: Day date propagates to all entries
//   Property 4: Unchanged program produces empty diff
//   Property 5: Validation rejects entries with empty names
//   Property 6: Validation rejects invalid time ranges
//   Property 7: Validation rejects days without dates
//   Property 8: Comma-separated string splitting produces correct arrays
//   Property 9: Entry removal preserves other entries
//   Property 10: Adding an entry increases count by one

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/data/entities/event_part.dart';
import 'package:dancee_app/screens/events/edit_event/models/editable_program_models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

EventPart _makePart({
  String name = 'Test Entry',
  String? description,
  String type = 'workshop',
  DateTime? startTime,
  DateTime? endTime,
  List<String> lectors = const [],
  List<String> djs = const [],
}) {
  return EventPart(
    name: name,
    description: description,
    type: type,
    startTime: startTime,
    endTime: endTime,
    lectors: lectors,
    djs: djs,
  );
}

EditableProgramDay _makeDay({
  int id = 0,
  DateTime? date,
  List<EditableProgramEntry>? entries,
}) {
  return EditableProgramDay(id: id, date: date, entries: entries);
}

EditableProgramEntry _makeEntry({
  int id = 0,
  String name = 'Entry',
  String? description,
  String type = 'workshop',
  TimeOfDay? startTime,
  TimeOfDay? endTime,
  String lectors = '',
  String djs = '',
}) {
  return EditableProgramEntry(
    id: id,
    name: name,
    description: description,
    type: type,
    startTime: startTime,
    endTime: endTime,
    lectors: lectors,
    djs: djs,
  );
}

// ---------------------------------------------------------------------------
// Property 1: Grouping round-trip preserves entries
// Tag: Feature: event-program-editing, Property 1: Grouping round-trip preserves entries
// ---------------------------------------------------------------------------

void _property1GroupingRoundTrip() {
  test('P1a: single-day program round-trip preserves entry count', () {
    final parts = [
      _makePart(name: 'Salsa Basics', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Bachata Intro', startTime: DateTime(2025, 3, 15, 12, 0)),
    ];

    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(serialized.length, equals(parts.length));
  });

  test('P1b: multi-day program round-trip preserves entry names', () {
    final parts = [
      _makePart(name: 'Day 1 Workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Day 2 Party', startTime: DateTime(2025, 3, 16, 20, 0)),
      _makePart(name: 'Day 2 Lesson', startTime: DateTime(2025, 3, 16, 14, 0)),
    ];

    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    final names = serialized.map((e) => e['name'] as String).toList();

    expect(names, containsAll(['Day 1 Workshop', 'Day 2 Party', 'Day 2 Lesson']));
  });

  test('P1c: entries without start time go to ungrouped and are preserved', () {
    final parts = [
      _makePart(name: 'Ungrouped 1'),
      _makePart(name: 'Grouped 1', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Ungrouped 2'),
    ];

    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
      for (final e in result.ungroupedEntries) {
        e.dispose();
      }
    });

    expect(result.days.length, equals(1));
    expect(result.ungroupedEntries.length, equals(2));

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(serialized.length, equals(3));
  });

  test('P1d: empty parts list produces empty days and ungrouped', () {
    final result = deserializeProgramFromParts([]);
    expect(result.days, isEmpty);
    expect(result.ungroupedEntries, isEmpty);
  });

  test('P1e: flattening grouped entries back preserves all entry types', () {
    final parts = [
      _makePart(name: 'Workshop', type: 'workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Party', type: 'party', startTime: DateTime(2025, 3, 15, 20, 0)),
      _makePart(name: 'Open Lesson', type: 'openLesson', startTime: DateTime(2025, 3, 16, 11, 0)),
    ];

    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    final types = serialized.map((e) => e['type'] as String).toList();

    expect(types, containsAll(['workshop', 'party', 'openLesson']));
  });
}

// ---------------------------------------------------------------------------
// Property 2: Serialization round-trip preserves data
// Tag: Feature: event-program-editing, Property 2: Serialization round-trip preserves data
// ---------------------------------------------------------------------------

void _property2SerializationRoundTrip() {
  test('P2a: name survives serialize → deserialize', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'Salsa Basics')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final part = EventPart.fromDirectus(serialized.first);

    expect(part.name, equals('Salsa Basics'));
  });

  test('P2b: type survives serialize → deserialize', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(type: 'party')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final part = EventPart.fromDirectus(serialized.first);

    expect(part.type, equals('party'));
  });

  test('P2c: start time survives serialize → deserialize', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(startTime: const TimeOfDay(hour: 14, minute: 30))],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final part = EventPart.fromDirectus(serialized.first);

    expect(part.startTime?.hour, equals(14));
    expect(part.startTime?.minute, equals(30));
  });

  test('P2d: lectors and djs survive serialize → deserialize', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(lectors: 'John Doe, Jane Smith', djs: 'DJ Mike')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final part = EventPart.fromDirectus(serialized.first);

    expect(part.lectors, equals(['John Doe', 'Jane Smith']));
    expect(part.djs, equals(['DJ Mike']));
  });

  test('P2e: null end time serializes as null and deserializes back to null', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(startTime: const TimeOfDay(hour: 10, minute: 0))],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final part = EventPart.fromDirectus(serialized.first);

    expect(part.endTime, isNull);
  });

  test('P2f: description survives serialize → deserialize', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(description: 'Intermediate level workshop')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final part = EventPart.fromDirectus(serialized.first);

    expect(part.description, equals('Intermediate level workshop'));
  });

  test('P2g: multiple entries all survive serialize → deserialize', () {
    final day = _makeDay(
      id: 0,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, name: 'Entry A', type: 'workshop'),
        _makeEntry(id: 1, name: 'Entry B', type: 'party'),
        _makeEntry(id: 2, name: 'Entry C', type: 'openLesson'),
      ],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.length, equals(3));

    final names = serialized.map((s) => s['name'] as String).toList();
    expect(names, equals(['Entry A', 'Entry B', 'Entry C']));
  });
}

// ---------------------------------------------------------------------------
// Property 3: Day date propagates to all entries
// Tag: Feature: event-program-editing, Property 3: Day date propagates to all entries
// ---------------------------------------------------------------------------

void _property3DayDatePropagation() {
  test('P3a: single entry gets the day date as start date component', () {
    final day = _makeDay(
      date: DateTime(2025, 6, 20),
      entries: [_makeEntry(startTime: const TimeOfDay(hour: 10, minute: 0))],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final start = DateTime.parse(range['start'] as String);

    expect(start.year, equals(2025));
    expect(start.month, equals(6));
    expect(start.day, equals(20));
  });

  test('P3b: multiple entries in the same day all get the day date', () {
    final day = _makeDay(
      date: DateTime(2025, 6, 20),
      entries: [
        _makeEntry(id: 0, startTime: const TimeOfDay(hour: 9, minute: 0)),
        _makeEntry(id: 1, startTime: const TimeOfDay(hour: 11, minute: 0)),
        _makeEntry(id: 2, startTime: const TimeOfDay(hour: 14, minute: 0)),
      ],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);

    for (final entry in serialized) {
      final range = entry['date_time_range'] as Map<String, dynamic>;
      final start = DateTime.parse(range['start'] as String);
      expect(start.year, equals(2025));
      expect(start.month, equals(6));
      expect(start.day, equals(20));
    }
  });

  test('P3c: end time also gets the day date component', () {
    final day = _makeDay(
      date: DateTime(2025, 6, 20),
      entries: [
        _makeEntry(
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
        ),
      ],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final end = DateTime.parse(range['end'] as String);

    expect(end.year, equals(2025));
    expect(end.month, equals(6));
    expect(end.day, equals(20));
  });

  test('P3d: entries in different days get their respective day dates', () {
    final day1 = _makeDay(
      id: 0,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 0, startTime: const TimeOfDay(hour: 10, minute: 0))],
    );
    final day2 = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 16),
      entries: [_makeEntry(id: 1, startTime: const TimeOfDay(hour: 14, minute: 0))],
    );
    addTearDown(day1.dispose);
    addTearDown(day2.dispose);

    final serialized = serializePartsToJson([day1, day2], []);
    final start1 = DateTime.parse(
        (serialized[0]['date_time_range'] as Map<String, dynamic>)['start'] as String);
    final start2 = DateTime.parse(
        (serialized[1]['date_time_range'] as Map<String, dynamic>)['start'] as String);

    expect(start1.day, equals(15));
    expect(start2.day, equals(16));
  });

  test('P3e: entry with no start time uses midnight of day date', () {
    final day = _makeDay(
      date: DateTime(2025, 6, 20),
      entries: [_makeEntry()],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final start = DateTime.parse(range['start'] as String);

    expect(start.day, equals(20));
    expect(start.hour, equals(0));
    expect(start.minute, equals(0));
  });

  test('P3f: ungrouped entries have null date_time_range start', () {
    final entry = _makeEntry(startTime: const TimeOfDay(hour: 10, minute: 0));
    addTearDown(entry.dispose);

    final serialized = serializePartsToJson([], [entry]);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;

    expect(range['start'], isNull);
    expect(range['end'], isNull);
  });
}

// ---------------------------------------------------------------------------
// Property 4: Unchanged program produces empty diff
// Tag: Feature: event-program-editing, Property 4: Unchanged program produces empty diff
// ---------------------------------------------------------------------------

void _property4UnchangedProgramNoDiff() {
  test('P4a: loading and re-serializing without changes reports no diff', () {
    final originalParts = [
      _makePart(
        name: 'Workshop',
        type: 'workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        endTime: DateTime(2025, 3, 15, 11, 30),
        lectors: ['John Doe'],
        djs: [],
      ),
    ];

    final result = deserializeProgramFromParts(originalParts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    final changed = programHasChanged(serialized, originalParts);

    expect(changed, isFalse);
  });

  test('P4b: empty program with empty original reports no diff', () {
    final serialized = serializePartsToJson([], []);
    final changed = programHasChanged(serialized, []);

    expect(changed, isFalse);
  });

  test('P4c: null original parts always reports no diff', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'Something')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final changed = programHasChanged(serialized, null);

    expect(changed, isFalse);
  });

  test('P4d: multi-day unchanged program reports no diff', () {
    final originalParts = [
      _makePart(name: 'Day 1 Workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Day 2 Party', type: 'party', startTime: DateTime(2025, 3, 16, 20, 0)),
    ];

    final result = deserializeProgramFromParts(originalParts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    final changed = programHasChanged(serialized, originalParts);

    expect(changed, isFalse);
  });

  test('P4e: adding an entry to the program reports a diff', () {
    final originalParts = [
      _makePart(name: 'Workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
    ];

    final result = deserializeProgramFromParts(originalParts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    // Simulate adding a second entry to the first day.
    // No separate teardown needed — day.dispose() covers entries it owns.
    final extraEntry = _makeEntry(id: 99, name: 'Extra Entry');
    result.days.first.entries.add(extraEntry);

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    final changed = programHasChanged(serialized, originalParts);

    expect(changed, isTrue);
  });

  test('P4f: changing entry name reports a diff', () {
    final originalParts = [
      _makePart(name: 'Original Name', startTime: DateTime(2025, 3, 15, 10, 0)),
    ];

    final result = deserializeProgramFromParts(originalParts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.nameController.text = 'Changed Name';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    final changed = programHasChanged(serialized, originalParts);

    expect(changed, isTrue);
  });
}

// ---------------------------------------------------------------------------
// Property 5: Validation rejects entries with empty names
// Tag: Feature: event-program-editing, Property 5: Validation rejects entries with empty names
// ---------------------------------------------------------------------------

void _property5ValidationEmptyNames() {
  test('P5a: entry with empty name produces nameRequired error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: '')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(errors, isNotEmpty);
    expect(
      errors.any((e) => e.type == ProgramValidationErrorType.nameRequired),
      isTrue,
    );
  });

  test('P5b: entry with whitespace-only name produces nameRequired error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: '   ')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.any((e) => e.type == ProgramValidationErrorType.nameRequired),
      isTrue,
    );
  });

  test('P5c: valid name produces no nameRequired error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'Valid Name')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.where((e) => e.type == ProgramValidationErrorType.nameRequired),
      isEmpty,
    );
  });

  test('P5d: multiple entries — only empty-name ones produce errors', () {
    final day = _makeDay(
      id: 0,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, name: 'Valid'),
        _makeEntry(id: 1, name: ''),
        _makeEntry(id: 2, name: 'Also Valid'),
        _makeEntry(id: 3, name: '\t'),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    final nameErrors = errors.where((e) => e.type == ProgramValidationErrorType.nameRequired).toList();

    expect(nameErrors.length, equals(2));
  });

  test('P5e: ungrouped entry with empty name produces nameRequired error', () {
    final entry = _makeEntry(name: '');
    addTearDown(entry.dispose);

    final errors = validateProgram([], [entry]);

    expect(
      errors.any((e) => e.type == ProgramValidationErrorType.nameRequired),
      isTrue,
    );
  });

  test('P5f: nameRequired error references the correct entry id', () {
    final day = _makeDay(
      id: 10,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 42, name: '')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    final nameError = errors.firstWhere(
      (e) => e.type == ProgramValidationErrorType.nameRequired,
    );

    expect(nameError.dayId, equals(10));
    expect(nameError.entryId, equals(42));
  });
}

// ---------------------------------------------------------------------------
// Property 6: Validation rejects invalid time ranges
// Tag: Feature: event-program-editing, Property 6: Validation rejects invalid time ranges
// ---------------------------------------------------------------------------

void _property6ValidationInvalidTimeRange() {
  test('P6a: end time before start time produces invalidTimeRange error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(
          name: 'Entry',
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
        ),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.any((e) => e.type == ProgramValidationErrorType.invalidTimeRange),
      isTrue,
    );
  });

  test('P6b: end time equal to start time produces no error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(
          name: 'Entry',
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 14, minute: 0),
        ),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.where((e) => e.type == ProgramValidationErrorType.invalidTimeRange),
      isEmpty,
    );
  });

  test('P6c: end time after start time produces no error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(
          name: 'Entry',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
        ),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.where((e) => e.type == ProgramValidationErrorType.invalidTimeRange),
      isEmpty,
    );
  });

  test('P6d: null start or end time produces no invalidTimeRange error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(name: 'Entry 1', startTime: const TimeOfDay(hour: 10, minute: 0)),
        _makeEntry(id: 1, name: 'Entry 2', endTime: const TimeOfDay(hour: 12, minute: 0)),
        _makeEntry(id: 2, name: 'Entry 3'),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.where((e) => e.type == ProgramValidationErrorType.invalidTimeRange),
      isEmpty,
    );
  });

  test('P6e: only the offending entry gets the invalidTimeRange error', () {
    final day = _makeDay(
      id: 0,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(
          id: 0,
          name: 'Good Entry',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 0),
        ),
        _makeEntry(
          id: 1,
          name: 'Bad Entry',
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
        ),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    final timeErrors = errors.where(
      (e) => e.type == ProgramValidationErrorType.invalidTimeRange,
    ).toList();

    expect(timeErrors.length, equals(1));
    expect(timeErrors.first.entryId, equals(1));
  });
}

// ---------------------------------------------------------------------------
// Property 7: Validation rejects days without dates
// Tag: Feature: event-program-editing, Property 7: Validation rejects days without dates
// ---------------------------------------------------------------------------

void _property7ValidationDateRequired() {
  test('P7a: day with null date produces dateRequired error', () {
    final day = _makeDay(date: null, entries: [_makeEntry(name: 'Entry')]);
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.any((e) => e.type == ProgramValidationErrorType.dateRequired),
      isTrue,
    );
  });

  test('P7b: day with a date set produces no dateRequired error', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'Entry')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);

    expect(
      errors.where((e) => e.type == ProgramValidationErrorType.dateRequired),
      isEmpty,
    );
  });

  test('P7c: dateRequired error references the correct day id', () {
    final day = _makeDay(id: 7, date: null, entries: [_makeEntry(name: 'Entry')]);
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    final dateError = errors.firstWhere(
      (e) => e.type == ProgramValidationErrorType.dateRequired,
    );

    expect(dateError.dayId, equals(7));
  });

  test('P7d: multiple days — only dateless ones produce dateRequired errors', () {
    final day1 = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: [_makeEntry(id: 0, name: 'E1')]);
    final day2 = _makeDay(id: 1, date: null, entries: [_makeEntry(id: 1, name: 'E2')]);
    final day3 = _makeDay(id: 2, date: DateTime(2025, 3, 16), entries: [_makeEntry(id: 2, name: 'E3')]);
    addTearDown(day1.dispose);
    addTearDown(day2.dispose);
    addTearDown(day3.dispose);

    final errors = validateProgram([day1, day2, day3], []);
    final dateErrors = errors.where(
      (e) => e.type == ProgramValidationErrorType.dateRequired,
    ).toList();

    expect(dateErrors.length, equals(1));
    expect(dateErrors.first.dayId, equals(1));
  });

  test('P7e: empty day list produces no dateRequired errors', () {
    final errors = validateProgram([], []);

    expect(
      errors.where((e) => e.type == ProgramValidationErrorType.dateRequired),
      isEmpty,
    );
  });
}

// ---------------------------------------------------------------------------
// Property 8: Comma-separated string splitting produces correct arrays
// Tag: Feature: event-program-editing, Property 8: Comma-separated string splitting
// ---------------------------------------------------------------------------

void _property8CommaSplitting() {
  test('P8a: simple comma-separated values produce correct list', () {
    expect(splitCommaSeparated('Alice, Bob, Charlie'), equals(['Alice', 'Bob', 'Charlie']));
  });

  test('P8b: extra whitespace is trimmed from each element', () {
    expect(splitCommaSeparated('  Alice  ,  Bob  ,  Charlie  '), equals(['Alice', 'Bob', 'Charlie']));
  });

  test('P8c: empty string produces empty list', () {
    expect(splitCommaSeparated(''), isEmpty);
  });

  test('P8d: whitespace-only string produces empty list', () {
    expect(splitCommaSeparated('   '), isEmpty);
  });

  test('P8e: trailing comma is ignored', () {
    expect(splitCommaSeparated('Alice, Bob,'), equals(['Alice', 'Bob']));
  });

  test('P8f: leading comma produces empty segment that is filtered', () {
    expect(splitCommaSeparated(',Alice, Bob'), equals(['Alice', 'Bob']));
  });

  test('P8g: single item without comma produces single-element list', () {
    expect(splitCommaSeparated('Alice'), equals(['Alice']));
  });

  test('P8h: multiple consecutive commas produce no spurious empty elements', () {
    final result = splitCommaSeparated('Alice,,Bob');
    expect(result, equals(['Alice', 'Bob']));
  });

  test('P8i: all non-empty elements are non-empty strings after splitting', () {
    const inputs = [
      'a, b, c',
      'single',
      'x, y',
      'DJ Mike, DJ Ola, DJ Peter',
    ];

    for (final input in inputs) {
      final result = splitCommaSeparated(input);
      for (final item in result) {
        expect(item, isNotEmpty, reason: 'Expected non-empty from input "$input"');
      }
    }
  });

  test('P8j: element count equals number of non-empty segments', () {
    expect(splitCommaSeparated('a, b, c').length, equals(3));
    expect(splitCommaSeparated('a').length, equals(1));
    expect(splitCommaSeparated('a, , c').length, equals(2));
    expect(splitCommaSeparated('').length, equals(0));
  });
}

// ---------------------------------------------------------------------------
// Property 9: Entry removal preserves other entries
// Tag: Feature: event-program-editing, Property 9: Entry removal preserves other entries
// ---------------------------------------------------------------------------

void _property9EntryRemovalPreservesOthers() {
  test('P9a: removing first of two entries leaves the second intact', () {
    final entry0 = _makeEntry(id: 0, name: 'First');
    final entry1 = _makeEntry(id: 1, name: 'Second');
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: [entry0, entry1]);
    addTearDown(() => entry1.dispose());
    addTearDown(day.entries.clear);

    // Simulate removal
    final removed = day.entries.removeAt(0);
    removed.dispose();

    expect(day.entries.length, equals(1));
    expect(day.entries.first.nameController.text, equals('Second'));
  });

  test('P9b: removing last of two entries leaves the first intact', () {
    final entry0 = _makeEntry(id: 0, name: 'First');
    final entry1 = _makeEntry(id: 1, name: 'Second');
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: [entry0, entry1]);
    addTearDown(() => entry0.dispose());
    addTearDown(day.entries.clear);

    final removed = day.entries.removeAt(1);
    removed.dispose();

    expect(day.entries.length, equals(1));
    expect(day.entries.first.nameController.text, equals('First'));
  });

  test('P9c: removing middle entry from three-entry day leaves others intact', () {
    final entry0 = _makeEntry(id: 0, name: 'First');
    final entry1 = _makeEntry(id: 1, name: 'Middle');
    final entry2 = _makeEntry(id: 2, name: 'Last');
    final day = _makeDay(
      id: 0,
      date: DateTime(2025, 3, 15),
      entries: [entry0, entry1, entry2],
    );
    addTearDown(() => entry0.dispose());
    addTearDown(() => entry2.dispose());
    addTearDown(day.entries.clear);

    final removed = day.entries.removeAt(1);
    removed.dispose();

    expect(day.entries.length, equals(2));
    expect(day.entries[0].nameController.text, equals('First'));
    expect(day.entries[1].nameController.text, equals('Last'));
  });

  test('P9d: removing entry reduces count by exactly one', () {
    const n = 5;
    final entries = List.generate(
      n,
      (i) => _makeEntry(id: i, name: 'Entry $i'),
    );
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: entries);
    addTearDown(() {
      for (final e in day.entries) {
        e.dispose();
      }
    });

    final removed = day.entries.removeAt(2);
    removed.dispose();

    expect(day.entries.length, equals(n - 1));
  });

  test('P9e: ids of remaining entries are unchanged after removal', () {
    final entries = [
      _makeEntry(id: 10, name: 'A'),
      _makeEntry(id: 20, name: 'B'),
      _makeEntry(id: 30, name: 'C'),
    ];
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: entries);
    addTearDown(() {
      for (final e in day.entries) {
        e.dispose();
      }
    });

    final removed = day.entries.removeAt(1);
    removed.dispose();

    expect(day.entries.map((e) => e.id).toList(), equals([10, 30]));
  });
}

// ---------------------------------------------------------------------------
// Property 10: Adding an entry increases count by one
// Tag: Feature: event-program-editing, Property 10: Adding an entry increases count by one
// ---------------------------------------------------------------------------

void _property10AddEntryIncreasesCount() {
  test('P10a: adding to empty day produces exactly one entry', () {
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15));
    addTearDown(day.dispose);

    final newEntry = _makeEntry(id: 0, name: '');
    day.entries.add(newEntry);

    expect(day.entries.length, equals(1));
  });

  test('P10b: new entry defaults to type "workshop"', () {
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15));
    addTearDown(day.dispose);

    final newEntry = EditableProgramEntry(id: 0);
    day.entries.add(newEntry);

    expect(day.entries.first.type, equals('workshop'));
  });

  test('P10c: new entry starts with empty name', () {
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15));
    addTearDown(day.dispose);

    final newEntry = EditableProgramEntry(id: 0);
    day.entries.add(newEntry);

    expect(day.entries.first.nameController.text, isEmpty);
  });

  test('P10d: adding entry to N-entry day produces N+1 entries', () {
    for (final n in [0, 1, 2, 5, 10]) {
      final entries = List.generate(n, (i) => _makeEntry(id: i, name: 'Entry $i'));
      final day = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: entries);

      final newEntry = _makeEntry(id: n, name: '');
      day.entries.add(newEntry);

      expect(day.entries.length, equals(n + 1), reason: 'Expected $n+1 entries');
      day.dispose();
    }
  });

  test('P10e: adding entry preserves all existing entries', () {
    final entries = [
      _makeEntry(id: 0, name: 'Existing 1'),
      _makeEntry(id: 1, name: 'Existing 2'),
    ];
    final day = _makeDay(id: 0, date: DateTime(2025, 3, 15), entries: entries);
    addTearDown(day.dispose);

    final newEntry = _makeEntry(id: 2, name: 'New Entry');
    day.entries.add(newEntry);

    expect(day.entries[0].nameController.text, equals('Existing 1'));
    expect(day.entries[1].nameController.text, equals('Existing 2'));
    expect(day.entries[2].nameController.text, equals('New Entry'));
  });
}

// ---------------------------------------------------------------------------
// Task 8.1: Unit tests — deserialization
// Covers: grouping logic (1-day, 2-day, mixed), EventPart.fromDirectus shapes
// ---------------------------------------------------------------------------

void _unit81Deserialization() {
  // --- Grouping: 1-day program ---
  test('U1a: single-day — two parts on same date create one day', () {
    final parts = [
      _makePart(name: 'Morning', startTime: DateTime(2025, 3, 15, 9, 0)),
      _makePart(name: 'Afternoon', startTime: DateTime(2025, 3, 15, 14, 0)),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    expect(result.days.length, equals(1));
    expect(result.days.first.entries.length, equals(2));
    expect(result.ungroupedEntries, isEmpty);
  });

  test('U1b: single-day — entries sorted by startTime ascending', () {
    final parts = [
      _makePart(name: 'Late', startTime: DateTime(2025, 3, 15, 18, 0)),
      _makePart(name: 'Early', startTime: DateTime(2025, 3, 15, 8, 0)),
      _makePart(name: 'Mid', startTime: DateTime(2025, 3, 15, 12, 0)),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final names = result.days.first.entries
        .map((e) => e.nameController.text)
        .toList();
    expect(names, equals(['Early', 'Mid', 'Late']));
  });

  test('U1c: single-day — day date matches startTime date component', () {
    final parts = [
      _makePart(startTime: DateTime(2025, 6, 20, 10, 0)),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    expect(result.days.first.date?.year, equals(2025));
    expect(result.days.first.date?.month, equals(6));
    expect(result.days.first.date?.day, equals(20));
  });

  // --- Grouping: 2-day program ---
  test('U2a: two-day — parts on different dates create two days', () {
    final parts = [
      _makePart(name: 'Day1', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Day2', startTime: DateTime(2025, 3, 16, 10, 0)),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    expect(result.days.length, equals(2));
  });

  test('U2b: two-day — days sorted chronologically', () {
    final parts = [
      _makePart(name: 'Second Day', startTime: DateTime(2025, 3, 16, 10, 0)),
      _makePart(name: 'First Day', startTime: DateTime(2025, 3, 15, 10, 0)),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    expect(result.days[0].date?.day, equals(15));
    expect(result.days[1].date?.day, equals(16));
  });

  test('U2c: two-day — entries belong to their correct day', () {
    final parts = [
      _makePart(name: 'On Day1', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Also Day1', startTime: DateTime(2025, 3, 15, 14, 0)),
      _makePart(name: 'On Day2', startTime: DateTime(2025, 3, 16, 10, 0)),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    expect(result.days[0].entries.length, equals(2));
    expect(result.days[1].entries.length, equals(1));
    expect(result.days[1].entries.first.nameController.text, equals('On Day2'));
  });

  // --- Grouping: mixed (some null dates) ---
  test('U3a: mixed — parts with null startTime go to ungrouped', () {
    final parts = [
      _makePart(name: 'Grouped', startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(name: 'Ungrouped A'),
      _makePart(name: 'Ungrouped B'),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
      for (final e in result.ungroupedEntries) {
        e.dispose();
      }
    });

    expect(result.days.length, equals(1));
    expect(result.ungroupedEntries.length, equals(2));
  });

  test('U3b: mixed — all null startTime parts produce no days', () {
    final parts = [
      _makePart(name: 'A'),
      _makePart(name: 'B'),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final e in result.ungroupedEntries) {
        e.dispose();
      }
    });

    expect(result.days, isEmpty);
    expect(result.ungroupedEntries.length, equals(2));
  });

  test('U3c: mixed — ungrouped entries preserve name and type', () {
    final parts = [
      _makePart(name: 'Unnamed Party', type: 'party'),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final e in result.ungroupedEntries) {
        e.dispose();
      }
    });

    expect(result.ungroupedEntries.first.nameController.text, equals('Unnamed Party'));
    expect(result.ungroupedEntries.first.type, equals('party'));
  });

  test('U3d: empty type defaults to "workshop" during deserialization', () {
    final parts = [
      const EventPart(name: 'No Type', type: '', lectors: [], djs: []),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final e in result.ungroupedEntries) {
        e.dispose();
      }
    });

    expect(result.ungroupedEntries.first.type, equals('workshop'));
  });

  test('U3e: lectors/djs arrays serialized as comma-separated strings', () {
    final parts = [
      _makePart(
        startTime: DateTime(2025, 3, 15, 10, 0),
        lectors: ['Alice', 'Bob'],
        djs: ['DJ Mike'],
      ),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final entry = result.days.first.entries.first;
    expect(entry.lectorsController.text, equals('Alice, Bob'));
    expect(entry.djsController.text, equals('DJ Mike'));
  });

  test('U3f: nextDayId and nextEntryId counters are correct after deserialization', () {
    final parts = [
      _makePart(startTime: DateTime(2025, 3, 15, 10, 0)),
      _makePart(startTime: DateTime(2025, 3, 16, 10, 0)),
      _makePart(),
    ];
    final result = deserializeProgramFromParts(parts);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
      for (final e in result.ungroupedEntries) {
        e.dispose();
      }
    });

    // 2 days → nextDayId = 2; 3 entries total → nextEntryId = 3
    expect(result.nextDayId, equals(2));
    expect(result.nextEntryId, equals(3));
  });

  // --- EventPart.fromDirectus: various JSON shapes ---
  test('U4a: full JSON with date_time_range parses all fields', () {
    final json = {
      'name': 'Workshop A',
      'description': 'Intro level',
      'type': 'workshop',
      'date_time_range': {
        'start': '2025-03-15T10:00:00.000',
        'end': '2025-03-15T11:30:00.000',
      },
      'lectors': ['John Doe'],
      'djs': ['DJ Mike'],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.name, equals('Workshop A'));
    expect(part.description, equals('Intro level'));
    expect(part.type, equals('workshop'));
    expect(part.startTime?.hour, equals(10));
    expect(part.startTime?.minute, equals(0));
    expect(part.endTime?.hour, equals(11));
    expect(part.endTime?.minute, equals(30));
    expect(part.lectors, equals(['John Doe']));
    expect(part.djs, equals(['DJ Mike']));
  });

  test('U4b: missing date_time_range → null start and end times', () {
    final json = {
      'name': 'No Time',
      'type': 'workshop',
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.startTime, isNull);
    expect(part.endTime, isNull);
  });

  test('U4c: null start in date_time_range → null startTime', () {
    final json = {
      'name': 'Null Start',
      'type': 'workshop',
      'date_time_range': {'start': null, 'end': null},
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.startTime, isNull);
    expect(part.endTime, isNull);
  });

  test('U4d: empty lectors and djs arrays → empty lists', () {
    final json = {
      'name': 'Solo',
      'type': 'workshop',
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.lectors, isEmpty);
    expect(part.djs, isEmpty);
  });

  test('U4e: missing lectors and djs fields → empty lists', () {
    final json = <String, dynamic>{
      'name': 'No Arrays',
      'type': 'party',
    };

    final part = EventPart.fromDirectus(json);

    expect(part.lectors, isEmpty);
    expect(part.djs, isEmpty);
  });

  test('U4f: translation overrides name and description', () {
    final json = {
      'name': 'Original Name',
      'description': 'Original desc',
      'type': 'workshop',
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };
    final translation = {
      'name': 'Translated Name',
      'description': 'Translated desc',
    };

    final part = EventPart.fromDirectus(json, translation: translation);

    expect(part.name, equals('Translated Name'));
    expect(part.description, equals('Translated desc'));
  });

  test('U4g: missing type field defaults to empty string', () {
    final json = <String, dynamic>{
      'name': 'No Type',
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.type, equals(''));
  });

  test('U4h: legacy start_time / end_time fields are parsed', () {
    final json = {
      'name': 'Legacy',
      'type': 'workshop',
      'start_time': '2025-03-15T09:00:00.000',
      'end_time': '2025-03-15T10:00:00.000',
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.startTime?.hour, equals(9));
    expect(part.endTime?.hour, equals(10));
  });

  test('U4i: only-end time in date_time_range (start null) → null startTime', () {
    final json = {
      'name': 'End Only',
      'type': 'workshop',
      'date_time_range': {
        'start': null,
        'end': '2025-03-15T11:00:00.000',
      },
      'lectors': <dynamic>[],
      'djs': <dynamic>[],
    };

    final part = EventPart.fromDirectus(json);

    expect(part.startTime, isNull);
    expect(part.endTime?.hour, equals(11));
  });
}

// ---------------------------------------------------------------------------
// Task 8.2: Unit tests — serialization
// Covers: ISO 8601 format, null handling, day date propagation, lectors/djs
//         comma splitting edge cases, parts_translations alignment
// ---------------------------------------------------------------------------

void _unit82Serialization() {
  // --- ISO 8601 format ---
  test('U5a: start time ISO 8601 string has correct date and time components', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(startTime: const TimeOfDay(hour: 14, minute: 30))],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final startStr = range['start'] as String;
    final parsed = DateTime.parse(startStr);

    expect(parsed.year, equals(2025));
    expect(parsed.month, equals(3));
    expect(parsed.day, equals(15));
    expect(parsed.hour, equals(14));
    expect(parsed.minute, equals(30));
  });

  test('U5b: end time ISO 8601 string has correct date and time components', () {
    final day = _makeDay(
      date: DateTime(2025, 6, 20),
      entries: [
        _makeEntry(
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 45),
        ),
      ],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final endStr = range['end'] as String;
    final parsed = DateTime.parse(endStr);

    expect(parsed.year, equals(2025));
    expect(parsed.month, equals(6));
    expect(parsed.day, equals(20));
    expect(parsed.hour, equals(11));
    expect(parsed.minute, equals(45));
  });

  test('U5c: start ISO 8601 string is parseable by DateTime.parse', () {
    final day = _makeDay(
      date: DateTime(2025, 12, 31),
      entries: [_makeEntry(startTime: const TimeOfDay(hour: 23, minute: 59))],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final startStr = range['start'] as String;

    expect(() => DateTime.parse(startStr), returnsNormally);
  });

  // --- Null handling ---
  test('U6a: null end time serializes to null in date_time_range.end', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(startTime: const TimeOfDay(hour: 10, minute: 0))],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;

    expect(range['end'], isNull);
    expect(range['start'], isNotNull);
  });

  test('U6b: entry with no start time uses midnight for date_time_range.start', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry()],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;
    final start = DateTime.parse(range['start'] as String);

    expect(start.hour, equals(0));
    expect(start.minute, equals(0));
    expect(start.day, equals(15));
  });

  test('U6c: ungrouped entry has null start and null end in date_time_range', () {
    final entry = _makeEntry(
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 0),
    );
    addTearDown(entry.dispose);

    final serialized = serializePartsToJson([], [entry]);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;

    expect(range['start'], isNull);
    expect(range['end'], isNull);
  });

  test('U6d: ungrouped entry with no times also has null date_time_range', () {
    final entry = _makeEntry();
    addTearDown(entry.dispose);

    final serialized = serializePartsToJson([], [entry]);
    final range = serialized.first['date_time_range'] as Map<String, dynamic>;

    expect(range['start'], isNull);
    expect(range['end'], isNull);
  });

  // --- dances field ---
  test('U7a: dances field is always an empty array', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'Workshop')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['dances'], equals(<dynamic>[]));
  });

  test('U7b: dances is empty even for ungrouped entries', () {
    final entry = _makeEntry(name: 'Party');
    addTearDown(entry.dispose);

    final serialized = serializePartsToJson([], [entry]);
    expect(serialized.first['dances'], equals(<dynamic>[]));
  });

  // --- Lectors/DJs comma splitting edge cases ---
  test('U8a: lectors with trailing comma produces clean array', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(lectors: 'Alice, Bob,')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['lectors'], equals(['Alice', 'Bob']));
  });

  test('U8b: lectors with multiple spaces around commas are trimmed', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(lectors: '  Alice  ,   Bob   ,  Charlie  ')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['lectors'], equals(['Alice', 'Bob', 'Charlie']));
  });

  test('U8c: single lector produces a single-element array', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(lectors: 'Solo Dancer')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['lectors'], equals(['Solo Dancer']));
  });

  test('U8d: empty lectors string produces empty array', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(lectors: '')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['lectors'], equals(<String>[]));
  });

  test('U8e: djs with trailing comma produces clean array', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(djs: 'DJ A, DJ B,')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['djs'], equals(['DJ A', 'DJ B']));
  });

  test('U8f: djs with multiple spaces are trimmed', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(djs: 'DJ One,   DJ Two  ,DJ Three')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['djs'], equals(['DJ One', 'DJ Two', 'DJ Three']));
  });

  test('U8g: lectors and djs are serialized independently per entry', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, lectors: 'Alice', djs: 'DJ Mike'),
        _makeEntry(id: 1, lectors: 'Bob, Carol', djs: ''),
      ],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized[0]['lectors'], equals(['Alice']));
    expect(serialized[0]['djs'], equals(['DJ Mike']));
    expect(serialized[1]['lectors'], equals(['Bob', 'Carol']));
    expect(serialized[1]['djs'], equals(<String>[]));
  });

  test('U8h: lectors with double commas (empty segment) are filtered', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(lectors: 'Alice,,Bob')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(serialized.first['lectors'], equals(['Alice', 'Bob']));
  });

  // --- parts_translations serialization ---
  test('U9a: serializePartsTranslations returns name and description per entry', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, name: 'Workshop', description: 'Intermediate level'),
      ],
    );
    addTearDown(day.dispose);

    final translations = serializePartsTranslations([day], []);

    expect(translations.length, equals(1));
    expect(translations.first['name'], equals('Workshop'));
    expect(translations.first['description'], equals('Intermediate level'));
  });

  test('U9b: parts_translations is positionally aligned with parts', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, name: 'Entry A', description: 'Desc A'),
        _makeEntry(id: 1, name: 'Entry B', description: 'Desc B'),
      ],
    );
    addTearDown(day.dispose);

    final parts = serializePartsToJson([day], []);
    final translations = serializePartsTranslations([day], []);

    expect(parts.length, equals(translations.length));
    expect(parts[0]['name'], equals(translations[0]['name']));
    expect(parts[1]['name'], equals(translations[1]['name']));
  });

  test('U9c: parts_translations for multi-day program orders days then ungrouped', () {
    final day1 = _makeDay(
      id: 0,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 0, name: 'Day1 Entry')],
    );
    final day2 = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 16),
      entries: [_makeEntry(id: 1, name: 'Day2 Entry')],
    );
    final ungrouped = _makeEntry(id: 2, name: 'Ungrouped Entry');
    addTearDown(day1.dispose);
    addTearDown(day2.dispose);
    addTearDown(ungrouped.dispose);

    final translations = serializePartsTranslations([day1, day2], [ungrouped]);

    expect(translations.length, equals(3));
    expect(translations[0]['name'], equals('Day1 Entry'));
    expect(translations[1]['name'], equals('Day2 Entry'));
    expect(translations[2]['name'], equals('Ungrouped Entry'));
  });

  test('U9d: parts_translations with empty description uses empty string', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'No Desc')],
    );
    addTearDown(day.dispose);

    final translations = serializePartsTranslations([day], []);
    expect(translations.first['description'], equals(''));
  });
}

// ---------------------------------------------------------------------------
// Task 8.3: Unit tests — diff detection
// Covers: unchanged program returns false, various change types return true
// ---------------------------------------------------------------------------

void _unit83DiffDetection() {
  // --- Unchanged program returns false ---
  test('U10a: null originalParts always returns false (no diff)', () {
    final day = _makeDay(
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(name: 'Workshop')],
    );
    addTearDown(day.dispose);

    final serialized = serializePartsToJson([day], []);
    expect(programHasChanged(serialized, null), isFalse);
  });

  test('U10b: empty current and empty original returns false', () {
    final serialized = serializePartsToJson([], []);
    expect(programHasChanged(serialized, []), isFalse);
  });

  test('U10c: single unchanged entry returns false', () {
    final original = [
      _makePart(
        name: 'Workshop',
        type: 'workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        endTime: DateTime(2025, 3, 15, 11, 30),
        lectors: ['Alice'],
        djs: ['DJ Mike'],
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isFalse);
  });

  test('U10d: unchanged program with multiple entries returns false', () {
    final original = [
      _makePart(name: 'Entry A', type: 'workshop', startTime: DateTime(2025, 3, 15, 9, 0)),
      _makePart(name: 'Entry B', type: 'party', startTime: DateTime(2025, 3, 15, 20, 0)),
      _makePart(name: 'Entry C', type: 'openLesson', startTime: DateTime(2025, 3, 16, 11, 0)),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isFalse);
  });

  test('U10e: unchanged program with lectors and djs returns false', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        lectors: ['John Doe', 'Jane Smith'],
        djs: ['DJ Alpha', 'DJ Beta'],
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isFalse);
  });

  // --- Change types that return true ---
  test('U11a: changing entry description returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        description: 'Original description',
        startTime: DateTime(2025, 3, 15, 10, 0),
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.descriptionController.text = 'Changed description';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11b: changing entry type returns true', () {
    final original = [
      _makePart(name: 'Entry', type: 'workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.type = 'party';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11c: changing start time returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        endTime: DateTime(2025, 3, 15, 11, 30),
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.startTime = const TimeOfDay(hour: 11, minute: 0);

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11d: changing end time returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        endTime: DateTime(2025, 3, 15, 11, 30),
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.endTime = const TimeOfDay(hour: 12, minute: 0);

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11e: clearing end time (non-null → null) returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        endTime: DateTime(2025, 3, 15, 11, 30),
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.endTime = null;

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11f: changing lectors returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        lectors: ['Alice'],
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.lectorsController.text = 'Bob';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11g: changing djs returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        djs: ['DJ Mike'],
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.djsController.text = 'DJ Other';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11h: removing an entry returns true', () {
    final original = [
      _makePart(name: 'Entry A', startTime: DateTime(2025, 3, 15, 9, 0)),
      _makePart(name: 'Entry B', startTime: DateTime(2025, 3, 15, 11, 0)),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    final removed = result.days.first.entries.removeLast();
    removed.dispose();

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11i: changing day date (moving entry to different date) returns true', () {
    final original = [
      _makePart(name: 'Workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    // Change the day's date — the serialized date_time_range.start will differ
    result.days.first.date = DateTime(2025, 3, 16);

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11j: lectors order change returns true', () {
    final original = [
      _makePart(
        name: 'Workshop',
        startTime: DateTime(2025, 3, 15, 10, 0),
        lectors: ['Alice', 'Bob'],
      ),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.lectorsController.text = 'Bob, Alice';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });

  test('U11k: adding a lector to previously-empty list returns true', () {
    final original = [
      _makePart(name: 'Workshop', startTime: DateTime(2025, 3, 15, 10, 0)),
    ];

    final result = deserializeProgramFromParts(original);
    addTearDown(() {
      for (final d in result.days) {
        d.dispose();
      }
    });

    result.days.first.entries.first.lectorsController.text = 'Alice';

    final serialized = serializePartsToJson(result.days, result.ungroupedEntries);
    expect(programHasChanged(serialized, original), isTrue);
  });
}

// ---------------------------------------------------------------------------
// Task 8.4: Unit tests — validation
// Covers: empty name, end < start, no date, valid program passes
// ---------------------------------------------------------------------------

void _unit84Validation() {
  // --- Empty name ---
  test('V1: empty name produces nameRequired error', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 0, name: '')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors.any((e) => e.type == ProgramValidationErrorType.nameRequired), isTrue);
  });

  test('V2: whitespace-only name produces nameRequired error', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 0, name: '   ')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors.any((e) => e.type == ProgramValidationErrorType.nameRequired), isTrue);
  });

  // --- End time before start time ---
  test('V3: end time before start time produces invalidTimeRange error', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(
          id: 0,
          name: 'Entry',
          startTime: const TimeOfDay(hour: 15, minute: 0),
          endTime: const TimeOfDay(hour: 13, minute: 0),
        ),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors.any((e) => e.type == ProgramValidationErrorType.invalidTimeRange), isTrue);
  });

  // --- Day with no date ---
  test('V4: day with null date produces dateRequired error', () {
    final day = _makeDay(id: 1, date: null, entries: [_makeEntry(id: 0, name: 'Entry')]);
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors.any((e) => e.type == ProgramValidationErrorType.dateRequired), isTrue);
  });

  // --- Valid program produces no errors ---
  test('V5: valid program with proper name, time range, and date produces no errors', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(
          id: 0,
          name: 'Valid Workshop',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
        ),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors, isEmpty);
  });

  test('V6: valid program with null times and non-null date produces no errors', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 0, name: 'Workshop with no times')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors, isEmpty);
  });

  test('V7: multiple valid entries produce no errors', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, name: 'Morning Session', startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 10, minute: 0)),
        _makeEntry(id: 1, name: 'Afternoon Session', startTime: const TimeOfDay(hour: 14, minute: 0), endTime: const TimeOfDay(hour: 15, minute: 30)),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors, isEmpty);
  });

  test('V8: error references correct day and entry ids', () {
    final day = _makeDay(
      id: 5,
      date: DateTime(2025, 3, 15),
      entries: [_makeEntry(id: 99, name: '')],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    final nameError = errors.firstWhere((e) => e.type == ProgramValidationErrorType.nameRequired);
    expect(nameError.dayId, equals(5));
    expect(nameError.entryId, equals(99));
  });

  test('V9: mixed valid and invalid entries — only invalid ones produce errors', () {
    final day = _makeDay(
      id: 1,
      date: DateTime(2025, 3, 15),
      entries: [
        _makeEntry(id: 0, name: 'Valid Entry'),
        _makeEntry(id: 1, name: ''),
      ],
    );
    addTearDown(day.dispose);

    final errors = validateProgram([day], []);
    expect(errors.length, equals(1));
    expect(errors.first.entryId, equals(1));
  });

  test('V10: empty days and ungrouped lists produce no errors', () {
    final errors = validateProgram([], []);
    expect(errors, isEmpty);
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('event-program-editing — unit tests (example-based)', () {
    group('Task 8.1: Deserialization', _unit81Deserialization);
    group('Task 8.2: Serialization', _unit82Serialization);
    group('Task 8.3: Diff detection', _unit83DiffDetection);
    group('Task 8.4: Validation', _unit84Validation);
  });

  group('event-program-editing — property-based tests', () {
    group(
      'Property 1: Grouping round-trip preserves entries',
      _property1GroupingRoundTrip,
    );
    group(
      'Property 2: Serialization round-trip preserves data',
      _property2SerializationRoundTrip,
    );
    group(
      'Property 3: Day date propagates to all entries',
      _property3DayDatePropagation,
    );
    group(
      'Property 4: Unchanged program produces empty diff',
      _property4UnchangedProgramNoDiff,
    );
    group(
      'Property 5: Validation rejects entries with empty names',
      _property5ValidationEmptyNames,
    );
    group(
      'Property 6: Validation rejects invalid time ranges',
      _property6ValidationInvalidTimeRange,
    );
    group(
      'Property 7: Validation rejects days without dates',
      _property7ValidationDateRequired,
    );
    group(
      'Property 8: Comma-separated string splitting produces correct arrays',
      _property8CommaSplitting,
    );
    group(
      'Property 9: Entry removal preserves other entries',
      _property9EntryRemovalPreservesOthers,
    );
    group(
      'Property 10: Adding an entry increases count by one',
      _property10AddEntryIncreasesCount,
    );
  });
}
