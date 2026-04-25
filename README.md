# Questify

Questify is a Firebase-powered Flutter productivity app that helps students fight procrastination through quests, boss battles, focus sessions, streaks, rewards, and progress tracking.

## Main features

- Firebase Authentication with email/password login and registration
- Cloud Firestore sync for quests, boss battles, rewards, profile progress, and settings
- Quest CRUD with mission steps, progress states, and validation
- XP, levels, coins, streaks, reward badges, and boss battle health tracking
- Focus timer, progress map, history, notifications, and profile/settings
- Responsive Flutter UI with light and dark mode
- Android APK build and Firebase Hosting web deployment support

## Tech stack

- Flutter
- Firebase Authentication
- Cloud Firestore
- Provider
- Shared Preferences
- Flutter Local Notifications

## Project structure

```text
lib/
  app/
  backend/
    data/
    models/
    services/
  frontend/
    controllers/
    screens/
    theme/
    widgets/
  firebase_options.dart
  main.dart
```

## Run locally

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Firebase setup

This project is already wired to Firebase. If you want to connect it to a different Firebase project:

1. Create a Firebase project.
2. Enable Email/Password in Authentication.
3. Create a Firestore database.
4. Run `flutterfire configure`.
5. Replace `lib/firebase_options.dart`.
6. Add platform config files such as `android/app/google-services.json` if needed.

## Firestore structure

```text
users/{userId}
  quests/{questId}
  bossBattles/{bossId}
  rewards/{rewardId}
```

## Web deployment

```bash
npx firebase-tools deploy --only hosting --project deadline-defender-a272c
```

Live URL:

- `https://deadline-defender-a272c.web.app`
- `https://deadline-defender-a272c.firebaseapp.com`
