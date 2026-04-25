@echo off
cd /d "%~dp0"
call "%~dp0flutter.bat" build web
if errorlevel 1 (
  echo.
  echo Flutter web build failed.
  pause
  exit /b 1
)
npx firebase-tools deploy --only hosting --project deadline-defender-a272c
echo.
echo If deploy succeeded, open:
echo https://deadline-defender-a272c.web.app
echo https://deadline-defender-a272c.firebaseapp.com
pause
