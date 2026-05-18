# Money Note

A simple, straightforward bookkeeping app built with Flutter and Material 3. It's designed to help you track where your money goes without making it a chore.

### What it does

- **Quick Entry:** Adding a record is fast. If you've typed something before, the app suggests it and fills in the category and amount for you.
- **Dashboard:** See your spending and earnings for the last week in a simple chart. It also shows your net earnings for the current week and month.
- **History:** A clean list of everything you've recorded. You can also export your data if you need it elsewhere.
- **Offline First:** Everything is stored locally on your device using SQLite.

### Tech Stuff

- **Framework:** Flutter
- **State Management:** Riverpod
- **Database:** SQLite (sqflite)
- **Charts:** fl_chart

### Running it

Standard Flutter rules apply:

1. `flutter pub get`
2. `flutter run`

### Download

You can download the latest compiled binaries for Android and iOS from the [Releases](https://github.com/sokinpui/money-note/releases) page.

### Development & Deployment

#### Android

To build a release APK:

```bash
flutter build apk --release
```

To install it on a connected device via ADB:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### iOS

To build for iOS (requires macOS and Xcode):

```bash
flutter build ios --release
```

Then you can open `ios/Runner.xcworkspace` in Xcode to deploy to a physical device.
