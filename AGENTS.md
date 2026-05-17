# Agent Instructions: Money Note

Compact guidance for agents working on this Flutter bookkeeping app.

## Developer Commands
- **Setup**: `flutter pub get`
- **Run**: `flutter run`
- **Test**: `flutter test`
- **Lint**: `flutter analyze`
- **Build APK**: `flutter build apk --release`
- **Localization**: Edits in `lib/l10n/*.arb` require `flutter gen-l10n` (automated if `generate: true` in `pubspec.yaml` is respected by the IDE).

## Architecture
- **State Management**: [Riverpod](https://riverpod.dev). Use `ConsumerWidget` or `ConsumerStatefulWidget`.
- **Database**: SQLite via `sqflite`. Logic resides in `lib/services/database_helper.dart`.
- **UI**: Material 3. Primary views are in `lib/views/`.
- **Localization**: Uses ARB files in `lib/l10n/`. Access via `AppLocalizations.of(context)!`.

## Conventions & Quirks
- **Localization**: Do NOT manually edit `lib/l10n/app_localizations.dart`. Modify `.arb` files and run `flutter gen-l10n`.
- **Models**: Simple Data Classes in `lib/models/`.
- **Providers**: Located in `lib/providers/`. Used for DB access and app settings (theme/locale).
- **Offline-first**: All data is local. SQLite is the source of truth.
