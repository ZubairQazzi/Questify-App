@echo off
cd /d "%~dp0"
call "%~dp0flutter.bat" pub get
if errorlevel 1 (
  echo.
  echo Flutter setup failed.
  pause
  exit /b 1
)
call "%~dp0flutter.bat" run
pause
