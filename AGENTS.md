# Agent Instructions: Money Note

Compact guidance for agents working on this Flutter bookkeeping app.

## Developer Commands
- **Run**: `flutter run`
- **Test**: `flutter test`
- **Lint**: `flutter analyze`
- **Build APK**: `flutter build apk --release`
- **L10n**: Edits in `lib/l10n/*.arb` require `flutter gen-l10n`. `generate: true` is enabled in `pubspec.yaml`.

## Architecture
- **State**: [Riverpod](https://riverpod.dev). Use `AsyncNotifier` (see `record_provider.dart`) for DB-backed state.
- **Database**: SQLite via `sqflite`. Schema and seeding in `lib/services/database_helper.dart`.
- **UI**: Material 3. Entry point `MainScaffold` in `lib/views/`.
- **L10n**: Access strings via `AppLocalizations.of(context)!`.

## Key Logic
- **Calculator**: Custom implementation in `lib/views/add_record_page.dart` for the `value` field.
- **Suggestions**: `RecordNotifier.getSuggestions` provides auto-fill based on previous record names.
- **Offline-first**: SQLite is the source of truth. No remote sync.

## Conventions & Quirks
- **L10n**: NEVER manually edit `lib/l10n/app_localizations.dart`. Modify `.arb` files and run `flutter gen-l10n`.
- **Models**: Simple Data Classes in `lib/models/` with `toMap`/`fromMap`.
- **Database Versioning**: Incremented in `DatabaseHelper` with `_onUpgrade` logic. Current version: 2.
