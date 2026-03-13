# Smart Class Check-in & Learning Reflection App

MVP mobile application for class attendance verification and learning reflection.

## Features

- Home screen with navigation to Check-in and Finish Class
- Check-in flow:
	- Capture GPS location
	- Scan class QR code (or manual fallback)
	- Fill previous topic, expected topic, and mood (1-5)
- Finish Class flow:
	- Capture GPS location
	- Scan class QR code (or manual fallback)
	- Fill learned summary and feedback
- Local data storage using SQLite
- Record list on Home screen

## Tech Stack

- Flutter (Dart)
- geolocator (GPS)
- mobile_scanner (QR scan)
- sqflite + path (local database)

## Project Structure

- `lib/main.dart`: app UI, navigation, form logic, scanner, and SQLite service
- `PRD.md`: product requirement document
- `AI_USAGE_REPORT.md`: short AI usage declaration
- `firebase.json`: Firebase Hosting configuration

## Setup Instructions

1. Install Flutter SDK.
2. Run:

```bash
flutter pub get
```

3. Run on Android emulator/device:

```bash
flutter run
```

## Firebase Configuration Notes

This repository includes `firebase.json` for Hosting deployment.

Typical deployment steps:

1. Install Firebase CLI:

```bash
npm install -g firebase-tools
```

2. Login and initialize:

```bash
firebase login
firebase init hosting
```

3. Build Flutter web and deploy:

```bash
flutter build web
firebase deploy
```

4. Firebase CLI will return a public Hosting URL.

## Notes

- Android location and camera permissions are configured in `AndroidManifest.xml`.
- iOS usage descriptions are configured in `ios/Runner/Info.plist`.
