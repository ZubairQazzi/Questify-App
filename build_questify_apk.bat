@echo off
cd /d "%~dp0"
call "%~dp0flutter.bat" pub get
if errorlevel 1 (
  echo.
  echo Flutter setup failed.
  pause
  exit /b 1
)
call "%~dp0flutter.bat" build apk
echo.
echo APK created at build\app\outputs\flutter-apk\app-release.apk
pause
