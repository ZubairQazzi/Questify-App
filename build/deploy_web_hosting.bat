@echo off
set "BUILD_DIR=%~dp0"
set "PROJECT_ROOT=%~dp0.."
set "FRONTEND_DIR=%PROJECT_ROOT%\frontend"
set "BACKEND_DIR=%PROJECT_ROOT%\backend"
set "HOSTING_DIR=%BACKEND_DIR%\web"

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
call "%FRONTEND_DIR%\flutter.bat" pub get
if errorlevel 1 (
  echo.
  echo Flutter setup failed.
  pause
  exit /b 1
)
call "%FRONTEND_DIR%\flutter.bat" build web --pwa-strategy=none --output "%HOSTING_DIR%"
if errorlevel 1 (
  echo.
  echo Flutter web build failed.
  pause
  exit /b 1
)
cd /d "%BACKEND_DIR%"
npx firebase-tools deploy --only hosting,firestore:rules --project deadline-defender-a272c --config "%BACKEND_DIR%\firebase.json"
echo.
echo If deploy succeeded, open:
echo https://deadline-defender-a272c.web.app
echo https://deadline-defender-a272c.firebaseapp.com
pause
