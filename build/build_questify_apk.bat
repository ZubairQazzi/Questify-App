@echo off
set "BUILD_DIR=%~dp0"
set "FRONTEND_DIR=%~dp0..\frontend"
cd /d "%FRONTEND_DIR%"
call "%FRONTEND_DIR%\flutter.bat" pub get
if errorlevel 1 (
  echo.
  echo Flutter setup failed.
  pause
  exit /b 1
)
call "%FRONTEND_DIR%\flutter.bat" build apk
if errorlevel 1 (
  echo.
  echo APK build failed.
  pause
  exit /b 1
)
copy /Y "%FRONTEND_DIR%\build\app\outputs\flutter-apk\app-release.apk" "%BUILD_DIR%app-release.apk" >nul
rmdir /S /Q "%FRONTEND_DIR%\build"
echo.
echo APK copied to build\app-release.apk
pause
