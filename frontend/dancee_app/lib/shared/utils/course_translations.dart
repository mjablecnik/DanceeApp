import '../../i18n/strings.g.dart';

/// Translates an English day name to the current locale.
String translateDay(String day) {
  switch (day.toLowerCase()) {
    case 'monday':
      return t.courses.detail.days.monday;
    case 'tuesday':
      return t.courses.detail.days.tuesday;
    case 'wednesday':
      return t.courses.detail.days.wednesday;
    case 'thursday':
      return t.courses.detail.days.thursday;
    case 'friday':
      return t.courses.detail.days.friday;
    case 'saturday':
      return t.courses.detail.days.saturday;
    case 'sunday':
      return t.courses.detail.days.sunday;
    default:
      return day;
  }
}

/// Translates an English level name to the current locale.
String translateLevel(String level) {
  switch (level.toLowerCase().replaceAll('_', '')) {
    case 'beginner':
      return t.courses.detail.levels.beginner;
    case 'intermediate':
      return t.courses.detail.levels.intermediate;
    case 'advanced':
      return t.courses.detail.levels.advanced;
    case 'alllevels':
      return t.courses.detail.levels.allLevels;
    default:
      return level;
  }
}
