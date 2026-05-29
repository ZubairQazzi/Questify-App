# Questify App

Questify is a Firebase-powered Flutter productivity app that helps students beat procrastination with quests, boss battles, focus progress, XP, streaks, rewards, and profile tracking.

## Live Web App

- https://deadline-defender-a272c.web.app
- https://deadline-defender-a272c.firebaseapp.com

## Latest Build

- Android APK: `build/app-release.apk`
- Web build archive: `build/web-release.zip`

## Project Structure

```text
backend/
  .firebaserc
  firebase.json

frontend/
  android/
  ios/
  lib/
    backend/
      config/
      data/
      models/
      services/
    frontend/
      app/
      controllers/
      screens/
      theme/
      widgets/
    main.dart
  test/
  web/
  pubspec.yaml

build/
  app-release.apk
  web-release.zip
  run_questify.bat
  build_questify_apk.bat
  deploy_web_hosting.bat
  serve_web.js
  WEB_LINKS.md
```

## Features

- Firebase Authentication with email/password login and registration
- Cloud Firestore sync for quests, boss battles, rewards, profile progress, and settings
- Quest CRUD with mission steps, progress states, and validation
- XP, levels, coins, streaks, reward badges, and boss health tracking
- Focus timer, progress map, history, notifications, and profile/settings
- Responsive Flutter UI with light and dark mode

## Run Locally

```cmd
cd frontend
flutter pub get
flutter run
```

Or run:

```cmd
build\run_questify.bat
```

## Build APK

```cmd
build\build_questify_apk.bat
```

The APK is copied to:

```text
build/app-release.apk
```

## Deploy Web

```cmd
build\deploy_web_hosting.bat
```

Firebase hosting config is stored in `backend/`.

## Test

```cmd
cd frontend
flutter analyze
flutter test
```
