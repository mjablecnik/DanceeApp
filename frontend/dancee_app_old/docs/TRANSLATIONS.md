# Translations Guide

This document provides a quick reference for working with translations in the Dancee App.

## Overview

The app uses **slang_flutter** for type-safe, compile-time checked translations across three languages:
- **English (en)** - Base locale
- **Czech (cs)** - Primary target audience
- **Spanish (es)** - Additional language

## Quick Start

### Using Translations in Code

```dart
import '../i18n/translations.g.dart';

// Simple string
Text(t.events)
Text(t.favorites)
Text(t.settings)

// With parameters (named parameters required)
Text(t.eventsCount(count: 5))
Text(t.savedEvents(count: totalEvents))
Text(t.tuesdayDate(date: '4.2.2025'))
```

### Adding New Translations

1. **Edit all three JSON files** in `lib/i18n/`:

**strings.i18n.json** (English):
```json
{
  "myNewKey": "My new text",
  "greetUser": "Hello, {name}!"
}
```

**strings_cs.i18n.json** (Czech):
```json
{
  "myNewKey": "Můj nový text",
  "greetUser": "Ahoj, {name}!"
}
```

**strings_es.i18n.json** (Spanish):
```json
{
  "myNewKey": "Mi nuevo texto",
  "greetUser": "¡Hola, {name}!"
}
```

2. **Generate translations:**
```bash
task slang
```

3. **Use in code:**
```dart
Text(t.myNewKey)
Text(t.greetUser(name: userName))
```

## Commands

```bash
# Generate translations once
task slang

# Watch mode (auto-regenerate on file changes)
task slang-watch

# Analyze for missing keys
task slang-analyze
```

## Parameter Syntax

### In JSON Files

Use curly braces `{paramName}`:

```json
{
  "simpleString": "Hello World",
  "withOneParam": "Hello, {name}!",
  "withMultipleParams": "{count} events on {date}",
  "withNumber": "{count} items"
}
```

### In Dart Code

Use named parameters:

```dart
// Simple string (no parameters)
t.simpleString

// With one parameter
t.withOneParam(name: 'John')

// With multiple parameters
t.withMultipleParams(count: 5, date: '2025-02-06')

// With number
t.withNumber(count: items.length)
```

## Current Translations

### Simple Strings

| Key | Usage |
|-----|-------|
| `appTitle` | `t.appTitle` |
| `events` | `t.events` |
| `favorites` | `t.favorites` |
| `settings` | `t.settings` |
| `searchEvents` | `t.searchEvents` |
| `filters` | `t.filters` |
| `today` | `t.today` |
| `tomorrow` | `t.tomorrow` |
| `thisWeek` | `t.thisWeek` |
| `thisMonth` | `t.thisMonth` |
| `prague` | `t.prague` |
| `detail` | `t.detail` |
| `errorLoadingEvents` | `t.errorLoadingEvents` |
| `retry` | `t.retry` |
| `favoriteEvents` | `t.favoriteEvents` |
| `all` | `t.all` |
| `upcomingEvents` | `t.upcomingEvents` |
| `pastEvents` | `t.pastEvents` |
| `noFavoriteEvents` | `t.noFavoriteEvents` |
| `noFavoriteEventsDescription` | `t.noFavoriteEventsDescription` |
| `browseEvents` | `t.browseEvents` |
| `errorLoadingFavorites` | `t.errorLoadingFavorites` |
| `dancee` | `t.dancee` |

### Parameterized Strings

| Key | Parameters | Usage Example |
|-----|------------|---------------|
| `eventsCount` | `count` | `t.eventsCount(count: 5)` |
| `hours` | `count` | `t.hours(count: 3)` |
| `savedEvents` | `count` | `t.savedEvents(count: 10)` |
| `tuesdayDate` | `date` | `t.tuesdayDate(date: '4.2.2025')` |
| `wednesdayDate` | `date` | `t.wednesdayDate(date: '5.2.2025')` |

## Best Practices

### ✅ DO

- Always add translations to ALL three language files
- Use the global `t` variable for translations
- Use named parameters for parameterized strings
- Run `task slang` after modifying translation files
- Import translations: `import '../i18n/translations.g.dart';`
- Use descriptive key names in camelCase
- Keep translations consistent across languages

### ❌ DON'T

- Hardcode user-facing strings in Dart code
- Add translations to only one language file
- Use positional parameters: `t.eventsCount(5)` ❌
- Forget to regenerate after changes
- Use the old `AppLocalizations.of(context)` system
- Edit the generated `translations.g.dart` file

## Common Patterns

### Loading States

```dart
if (state is Loading) {
  return Center(
    child: CircularProgressIndicator(),
  );
}
```

### Error States

```dart
if (state is Error) {
  return Column(
    children: [
      Text(t.errorLoadingEvents),
      ElevatedButton(
        onPressed: retry,
        child: Text(t.retry),
      ),
    ],
  );
}
```

### Empty States

```dart
if (items.isEmpty) {
  return Column(
    children: [
      Text(t.noFavoriteEvents),
      Text(t.noFavoriteEventsDescription),
      ElevatedButton(
        onPressed: browse,
        child: Text(t.browseEvents),
      ),
    ],
  );
}
```

### Lists with Counts

```dart
Text(t.eventsCount(count: events.length))
Text(t.savedEvents(count: favorites.length))
```

### Date Formatting

```dart
Text(t.tuesdayDate(date: formattedDate))
Text(t.wednesdayDate(date: formattedDate))
```

## Troubleshooting

### Translations not found

**Solution:** Run `task slang` to regenerate the translations file.

### IDE not recognizing `t`

**Solution:** 
1. Make sure you've imported: `import '../i18n/translations.g.dart';`
2. Run `task slang` to generate the file
3. Restart your IDE or run "Dart: Restart Analysis Server"

### Build errors after adding translations

**Solution:**
1. Clean the project: `task clean`
2. Get dependencies: `task get-deps`
3. Generate translations: `task slang`
4. Run the app: `task run-web`

### Parameter type errors

**Solution:** Use named parameters with the exact parameter name from the JSON file:
```dart
// ❌ Wrong
t.eventsCount(5)

// ✅ Correct
t.eventsCount(count: 5)
```

## File Locations

```
frontend/dancee_app/
├── lib/i18n/
│   ├── strings.i18n.json        # English (edit this)
│   ├── strings_cs.i18n.json     # Czech (edit this)
│   ├── strings_es.i18n.json     # Spanish (edit this)
│   └── translations.g.dart      # Generated (don't edit)
├── slang.yaml                   # Slang configuration
└── pubspec.yaml                 # Dependencies
```

## Resources

- [Slang Documentation](https://pub.dev/packages/slang)
- [Slang Flutter Documentation](https://pub.dev/packages/slang_flutter)

---

**Remember:** Always add translations to ALL three language files and run `task slang` after changes!
