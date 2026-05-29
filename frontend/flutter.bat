@echo off
setlocal

set "PROJECT_FLUTTER=C:\Users\zubai\flutter_sdk\bin\flutter.bat"

if exist "%PROJECT_FLUTTER%" (
  call "%PROJECT_FLUTTER%" %*
  exit /b %errorlevel%
)

where flutter >nul 2>nul
if %errorlevel% equ 0 (
  flutter %*
  exit /b %errorlevel%
)

echo Flutter SDK not found.
echo Expected: C:\Users\zubai\flutter_sdk\bin\flutter.bat
exit /b 1
