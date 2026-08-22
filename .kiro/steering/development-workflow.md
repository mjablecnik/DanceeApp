---
inclusion: always
---

# Development Workflow

## Development Workflow for Kiro AI

When working with this project:

1. **Setup**: Always suggest `flutter pub get` (Flutter — no Taskfile) or `task install` (backend) to install dependencies
2. **Development**: Recommend `flutter run -d chrome` for quick Flutter testing, `task dev` for backend services
3. **Code Generation & Translations**: Use `dart run build_runner watch --delete-conflicting-outputs` when working with generated code or translations (slang is driven by build_runner, not a separate task)
4. **Testing**: Suggest testing on multiple platforms when relevant
5. **Build**: Use appropriate `flutter build`/`task build` commands for production builds

## Code Standards for AI

When generating or modifying code:
- Follow Flutter/Dart conventions for frontend, TypeScript conventions for backend
- Use meaningful English variable and function names
- Add English comments for complex logic
- Ensure cross-platform compatibility for Flutter code
- Use proper state management patterns (Cubit/Bloc)
- **ALWAYS use slang translations for user-facing strings** — never hardcode text
- **Add translations to ALL language files** (en, cs, es) when creating new strings
- **Run `dart run build_runner build --delete-conflicting-outputs`** after modifying translation files

## Before Making Changes

As Kiro AI, always:
1. Check current taskfile.yaml for available backend commands (dancee_api, dancee_workflow) — `dancee_app` has no Taskfile, use the Flutter CLI directly
2. **Ensure all user-facing strings use slang translations** (never hardcode)
3. **Add translations to ALL language files** when creating new strings
4. **Flutter sensitive config** → `lib/config.dart` (gitignored), public config → `lib/core/config.dart`
5. **Backend sensitive config** → `.env` (gitignored), template → `.env.example`
6. Consider cross-platform implications for Flutter code
7. Use build_runner for code generation needs
8. **Run `dart run build_runner build --delete-conflicting-outputs`** after modifying translation files
9. Suggest appropriate task commands for backend, Flutter CLI commands for frontend
10. **Place documentation in `docs/` folder** (except README.md)
11. **Update OpenAPI specs in `dancee_api/specs/`** when changing any backend API endpoint

## AI-Specific Instructions

- **CRITICAL: Never hardcode user-facing strings** — always use slang translations
- **When adding new UI text**: Add to all 3 language files (en, cs, es) and run `dart run build_runner build --delete-conflicting-outputs`
- Utilize taskfile commands for backend suggestions; use the Flutter CLI directly for frontend (no Taskfile in `dancee_app`)
- Consider Flutter best practices and cross-platform compatibility
- When creating new files, ensure they follow the project structure
- Suggest appropriate testing strategies for multi-platform development
- **Import translations**: the generated file is `lib/i18n/strings.g.dart` (not `translations.g.dart`) — import it with the relative path matching the current file's depth under `lib/`, e.g. `import 'i18n/strings.g.dart';` from `lib/main.dart`, `import '../../i18n/strings.g.dart';` from a file two levels deep
- **Use global `t` variable** for translations: `t.keyName` or `t.method(param: value)`
- **Never commit sensitive values** — use `lib/config.dart` for Flutter, `.env` for backend
- **Documentation placement**: All docs in `docs/` folder except `README.md`
- **dancee_api**: API Gateway — Express, OpenAPI spec aggregation, Swagger UI
- **dancee_workflow**: Event processing — Restate, OpenAI, scraping, geocoding, Directus integration
- **dancee_cms**: Directus headless CMS — no custom code, configuration scripts only

## Remember

This guide ensures consistency and maintainability for international development teams working on the Dancee App project.
