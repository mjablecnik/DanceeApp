import 'package:flutter/material.dart';

import '../../../../data/entities/event_part.dart';

// Task 1.7: Comma-separated string splitting utility
List<String> splitCommaSeparated(String value) {
  return value
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

// Task 1.1: Form model classes
class EditableProgramEntry {
  final int id;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  String type;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController lectorsController;
  final TextEditingController djsController;

  EditableProgramEntry({
    required this.id,
    String name = '',
    String? description,
    this.type = 'workshop',
    this.startTime,
    this.endTime,
    String lectors = '',
    String djs = '',
  })  : nameController = TextEditingController(text: name),
        descriptionController = TextEditingController(text: description ?? ''),
        lectorsController = TextEditingController(text: lectors),
        djsController = TextEditingController(text: djs);

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    lectorsController.dispose();
    djsController.dispose();
  }
}

class EditableProgramDay {
  final int id;
  DateTime? date;
  final List<EditableProgramEntry> entries;

  EditableProgramDay({
    required this.id,
    this.date,
    List<EditableProgramEntry>? entries,
  }) : entries = entries ?? [];

  void dispose() {
    for (final entry in entries) {
      entry.dispose();
    }
  }
}

// Task 1.2: Deserialization — Event.parts → form state
({
  List<EditableProgramDay> days,
  List<EditableProgramEntry> ungroupedEntries,
  int nextDayId,
  int nextEntryId,
}) deserializeProgramFromParts(List<EventPart> parts) {
  int dayId = 0;
  int entryId = 0;

  // Group by date component of startTime
  final Map<String, List<EventPart>> grouped = {};
  final List<EventPart> ungrouped = [];

  for (final part in parts) {
    if (part.startTime != null) {
      final dt = part.startTime!;
      final key =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(part);
    } else {
      ungrouped.add(part);
    }
  }

  // Sort groups chronologically
  final sortedKeys = grouped.keys.toList()..sort();

  final days = <EditableProgramDay>[];
  for (final key in sortedKeys) {
    final partsInDay = grouped[key]!;
    // Sort entries by startTime, nulls at end
    partsInDay.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    final date = DateTime.parse(key);
    final entries = partsInDay.map((part) {
      return EditableProgramEntry(
        id: entryId++,
        name: part.name,
        description: part.description,
        type: part.type.isNotEmpty ? part.type : 'workshop',
        startTime:
            part.startTime != null ? TimeOfDay.fromDateTime(part.startTime!) : null,
        endTime:
            part.endTime != null ? TimeOfDay.fromDateTime(part.endTime!) : null,
        lectors: part.lectors.join(', '),
        djs: part.djs.join(', '),
      );
    }).toList();

    days.add(EditableProgramDay(id: dayId++, date: date, entries: entries));
  }

  // Ungrouped entries
  final ungroupedEntryObjects = ungrouped.map((part) {
    return EditableProgramEntry(
      id: entryId++,
      name: part.name,
      description: part.description,
      type: part.type.isNotEmpty ? part.type : 'workshop',
      startTime:
          part.startTime != null ? TimeOfDay.fromDateTime(part.startTime!) : null,
      endTime:
          part.endTime != null ? TimeOfDay.fromDateTime(part.endTime!) : null,
      lectors: part.lectors.join(', '),
      djs: part.djs.join(', '),
    );
  }).toList();

  return (
    days: days,
    ungroupedEntries: ungroupedEntryObjects,
    nextDayId: dayId,
    nextEntryId: entryId,
  );
}

// Task 1.3 & 1.4: Serialization — form state → EventPart JSON arrays
List<Map<String, dynamic>> serializePartsToJson(
  List<EditableProgramDay> days,
  List<EditableProgramEntry> ungroupedEntries,
) {
  final result = <Map<String, dynamic>>[];

  for (final day in days) {
    for (final entry in day.entries) {
      result.add(_serializeEntry(entry, day.date));
    }
  }

  for (final entry in ungroupedEntries) {
    result.add(_serializeEntry(entry, null));
  }

  return result;
}

Map<String, dynamic> _serializeEntry(
  EditableProgramEntry entry,
  DateTime? dayDate,
) {
  Map<String, dynamic>? dateTimeRange;

  if (dayDate != null) {
    final startTime = entry.startTime ?? const TimeOfDay(hour: 0, minute: 0);
    final startDt = DateTime(
      dayDate.year,
      dayDate.month,
      dayDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime? endDt;
    if (entry.endTime != null) {
      endDt = DateTime(
        dayDate.year,
        dayDate.month,
        dayDate.day,
        entry.endTime!.hour,
        entry.endTime!.minute,
      );
    }

    dateTimeRange = {
      'start': startDt.toIso8601String(),
      'end': endDt?.toIso8601String(),
    };
  } else {
    dateTimeRange = {'start': null, 'end': null};
  }

  return {
    'name': entry.nameController.text,
    'description': entry.descriptionController.text,
    'type': entry.type,
    'dances': <dynamic>[],
    'date_time_range': dateTimeRange,
    'lectors': splitCommaSeparated(entry.lectorsController.text),
    'djs': splitCommaSeparated(entry.djsController.text),
  };
}

// Task 1.4: parts_translations serialization
List<Map<String, dynamic>> serializePartsTranslations(
  List<EditableProgramDay> days,
  List<EditableProgramEntry> ungroupedEntries,
) {
  final result = <Map<String, dynamic>>[];

  for (final day in days) {
    for (final entry in day.entries) {
      result.add({
        'name': entry.nameController.text,
        'description': entry.descriptionController.text,
      });
    }
  }

  for (final entry in ungroupedEntries) {
    result.add({
      'name': entry.nameController.text,
      'description': entry.descriptionController.text,
    });
  }

  return result;
}

// Task 1.5: Diff detection
bool programHasChanged(
  List<Map<String, dynamic>> currentSerialized,
  List<EventPart>? originalParts,
) {
  if (originalParts == null) return false;

  // Serialize original parts to comparable format
  final originalSerialized = originalParts.map((part) {
    Map<String, dynamic>? dateTimeRange;
    if (part.startTime != null) {
      dateTimeRange = {
        'start': part.startTime!.toIso8601String(),
        'end': part.endTime?.toIso8601String(),
      };
    } else {
      dateTimeRange = {'start': null, 'end': null};
    }

    return {
      'name': part.name,
      'description': part.description ?? '',
      'type': part.type,
      'dances': <dynamic>[],
      'date_time_range': dateTimeRange,
      'lectors': part.lectors,
      'djs': part.djs,
    };
  }).toList();

  if (currentSerialized.length != originalSerialized.length) return true;

  for (var i = 0; i < currentSerialized.length; i++) {
    final cur = currentSerialized[i];
    final orig = originalSerialized[i];

    if (cur['name'] != orig['name']) return true;
    if ((cur['description'] ?? '') != (orig['description'] ?? '')) return true;
    if (cur['type'] != orig['type']) return true;

    final curRange = cur['date_time_range'] as Map<String, dynamic>?;
    final origRange = orig['date_time_range'] as Map<String, dynamic>?;
    if (curRange?['start'] != origRange?['start']) return true;
    if (curRange?['end'] != origRange?['end']) return true;

    final curLectors = (cur['lectors'] as List).cast<String>();
    final origLectors = (orig['lectors'] as List).cast<String>();
    if (!_listsEqual(curLectors, origLectors)) return true;

    final curDjs = (cur['djs'] as List).cast<String>();
    final origDjs = (orig['djs'] as List).cast<String>();
    if (!_listsEqual(curDjs, origDjs)) return true;
  }

  return false;
}

bool _listsEqual(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Task 1.6: Validation logic
class ProgramValidationError {
  final int? dayId;
  final int? entryId;
  final ProgramValidationErrorType type;

  const ProgramValidationError({
    this.dayId,
    this.entryId,
    required this.type,
  });
}

enum ProgramValidationErrorType {
  nameRequired,
  invalidTimeRange,
  dateRequired,
}

List<ProgramValidationError> validateProgram(
  List<EditableProgramDay> days,
  List<EditableProgramEntry> ungroupedEntries,
) {
  final errors = <ProgramValidationError>[];

  for (final day in days) {
    if (day.date == null) {
      errors.add(ProgramValidationError(
        dayId: day.id,
        type: ProgramValidationErrorType.dateRequired,
      ));
    }

    for (final entry in day.entries) {
      if (entry.nameController.text.trim().isEmpty) {
        errors.add(ProgramValidationError(
          dayId: day.id,
          entryId: entry.id,
          type: ProgramValidationErrorType.nameRequired,
        ));
      }

      if (entry.startTime != null && entry.endTime != null) {
        final startMinutes =
            entry.startTime!.hour * 60 + entry.startTime!.minute;
        final endMinutes = entry.endTime!.hour * 60 + entry.endTime!.minute;
        if (endMinutes < startMinutes) {
          errors.add(ProgramValidationError(
            dayId: day.id,
            entryId: entry.id,
            type: ProgramValidationErrorType.invalidTimeRange,
          ));
        }
      }
    }
  }

  for (final entry in ungroupedEntries) {
    if (entry.nameController.text.trim().isEmpty) {
      errors.add(ProgramValidationError(
        entryId: entry.id,
        type: ProgramValidationErrorType.nameRequired,
      ));
    }
  }

  return errors;
}
