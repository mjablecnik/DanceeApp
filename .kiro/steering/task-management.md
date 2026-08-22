---
inclusion: always
---

# Task Management

This project uses **Taskfile** for automation. Always use tasks instead of direct commands when suggesting or running commands.

## Frontend Commands (Flutter)

`dancee_app` has no Taskfile — use the Flutter CLI directly.

### Essential Commands
- `flutter run -d chrome` - Run app on web
- `flutter run -d <device-id>` - Run app on Android/iOS device or emulator (`flutter devices` lists targets)
- `flutter pub get` - Install Flutter dependencies
- `flutter clean` - Clean project

### Build Commands
- `flutter build web` - Build for web production
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS

### Code Generation (slang)

Translation strings live in `lib/i18n/*.i18n.json` and are compiled by `slang_build_runner` to `lib/i18n/strings.g.dart`. After changing a translation file:
- `dart run build_runner build --delete-conflicting-outputs` - Regenerate `strings.g.dart`
- `dart run build_runner watch --delete-conflicting-outputs` - Watch and auto-regenerate

### Testing Commands
- `flutter test` - Run all Flutter tests
- `flutter test --coverage` - Run tests with coverage report

## Backend Tasks

### dancee_api (TypeScript/Express)
```bash
task install        # Install dependencies (npm)
task dev            # Start development server with hot reload
task build          # Build TypeScript to JavaScript
task start          # Start production server
task test           # Run all tests
task test-watch     # Run tests in watch mode
task test-coverage  # Run tests with coverage report
task lint           # Run ESLint
task lint-fix       # Run ESLint and fix issues
task format         # Format code with Prettier
task format-check   # Check code formatting
task clean          # Clean build artifacts
task clean-build    # Clean and rebuild
```

### dancee_workflow (TypeScript/Restate)
```bash
task install          # Install dependencies (bun)
task dev              # Start development server with hot reload
task build            # Build TypeScript to JavaScript
task start            # Start production server
task test             # Run all tests
task setup-directus   # Create Directus collections and seed languages
task docker-build     # Build Docker image
task docker-up        # Start service with Docker Compose
task docker-down      # Stop Docker Compose service
task clean            # Clean build artifacts
task clean-build      # Clean and rebuild
```

## Quick Commands Reference

**Frontend (Flutter) — no Taskfile, use the Flutter CLI directly:**
```bash
# Start development
flutter pub get
flutter run -d chrome

# Code generation (slang translations, generated code)
dart run build_runner watch --delete-conflicting-outputs

# Testing
flutter test
flutter test --coverage

# Build for production
flutter build web
flutter build apk
flutter build ios
```

**Backend - dancee_api (Express):**
```bash
# Start development
task install
task dev

# Code quality
task lint
task format

# Testing
task test
task test-watch
task test-coverage

# Build for production
task build
task start
```

**Backend - dancee_workflow (Restate):**
```bash
# Start development
task install
task dev

# Testing
task test

# Docker
task docker-build
task docker-up
task docker-down

# Directus setup
task setup-directus

# Build for production
task build
task start
```
