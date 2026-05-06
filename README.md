# Questify

Questify is a Flutter productivity game that helps users fight procrastination by turning study tasks into quests, deadlines into boss battles, and daily consistency into visible rewards.

## What the app includes

- Firebase email/password authentication
- Forgot-password flow with reset email support
- Show/hide password toggle on login and register
- Quest creation, editing, deletion, and completion
- Mission steps for breaking large tasks into smaller actions
- Boss battles linked to major quests
- XP, levels, coins, streaks, and badges
- Focus timer with quest progress tracking
- History, progress map, rewards, and profile/settings
- Light mode by default, with optional dark mode toggle

## Tech stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Provider
- Shared Preferences
- Flutter Local Notifications

## Project structure

```text
android/
ios/
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
test/
web/
apk/
```

## Run the project

```bash
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Build APK

```bash
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Shareable APK stored in the repo:

```text
apk/Questify-v1.0.0.apk
```

## Firebase setup

This repository is already connected to Firebase for the current project setup.

If you want to connect it to a different Firebase project:

1. Create a Firebase project.
2. Enable Email/Password in Authentication.
3. Create a Firestore database.
4. Run `flutterfire configure`.
5. Replace `lib/firebase_options.dart`.
6. Replace `android/app/google-services.json` if needed.

## Firestore structure

```text
users/{userId}
  quests/{questId}
  bossBattles/{bossId}
  rewards/{rewardId}
```

## Live web app

- [https://deadline-defender-a272c.web.app](https://deadline-defender-a272c.web.app)
- [https://deadline-defender-a272c.firebaseapp.com](https://deadline-defender-a272c.firebaseapp.com)

## Download and use

- If you want to use the app in a browser, open the live web link above.
- If you want the Android version, download `apk/Questify-v1.0.0.apk`.
- If you want to edit or rebuild the project, download the full repository and run Flutter locally.
