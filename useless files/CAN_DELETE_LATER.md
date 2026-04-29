# Files And Folders You Can Delete Later

These are generated or temporary items that are safe to remove when you want to free space:

- `.dart_tool/`
- `build/`
- `.firebase/`
- `.flutter-plugins-dependencies`
- `apk/` if you no longer need the copied APK inside the repo folder

Notes:

- Do not delete `lib/`, `android/`, `ios/`, `web/`, `test/`, `pubspec.yaml`, or `pubspec.lock`.
- If you delete generated folders, run `flutter pub get` and then `flutter run` or `flutter build apk` again when needed.
