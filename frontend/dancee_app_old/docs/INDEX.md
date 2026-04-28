# Dancee App Documentation

Complete documentation for the Dancee Flutter application.

## 📚 Documentation Files

### Main Documentation
- **[README.md](../README.md)** - Project overview, setup, and architecture
- **[TRANSLATIONS.md](./TRANSLATIONS.md)** - Complete guide to internationalization (i18n)

## 🚀 Quick Start

1. **Install dependencies:**
   ```bash
   task get-deps
   ```

2. **Run the app:**
   ```bash
   task run-web
   ```

3. **Generate translations (if needed):**
   ```bash
   task slang
   ```

## 📖 Key Topics

### Setup & Installation
See [README.md](../README.md) - Getting Started section

### Internationalization (i18n)
See [TRANSLATIONS.md](./TRANSLATIONS.md) for:
- Adding new translations
- Using translations in code
- Translation commands
- Best practices

### Architecture
See [README.md](../README.md) - Architecture section for:
- Repository pattern
- State management with Cubit
- Dependency injection
- Data flow

### Project Structure
See [README.md](../README.md) - Project Structure section

## 🔧 Common Tasks

```bash
# Development
task run-web              # Run on web (port 3000)
task run-android          # Run on Android
task run-ios              # Run on iOS

# Translations
task slang                # Generate translations
task slang-watch          # Auto-regenerate on changes
task slang-analyze        # Check for missing keys

# Code Generation
task build-runner         # Run build runner
task build-runner-watch   # Watch mode

# Building
task build-web            # Build for web
task build-android        # Build APK
task build-ios            # Build for iOS

# Maintenance
task clean                # Clean project
task get-deps             # Install dependencies
```

## 🌍 Supported Languages

- **English (en)** - Base locale
- **Czech (cs)** - Primary target audience
- **Spanish (es)** - Additional language

## 🎯 Key Features

- Multi-language support (EN, CS, ES)
- Event browsing and filtering
- Favorites management
- Search functionality
- Clean architecture with Cubit state management
- REST API integration
- Type-safe translations with slang

## 📱 Supported Platforms

- Web (primary development platform)
- Android
- iOS

## 🔗 External Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Slang Package](https://pub.dev/packages/slang)
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- [Get It](https://pub.dev/packages/get_it)

## 📝 Documentation Standards

- All documentation in English
- All code in English (variables, functions, classes, comments)
- User-facing strings use slang translations (never hardcoded)
- Keep documentation up-to-date with code changes
