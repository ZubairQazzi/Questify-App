@echo off
set "FRONTEND_DIR=%~dp0..\frontend"
cd /d "%FRONTEND_DIR%"
call "%FRONTEND_DIR%\flutter.bat" pub get
if errorlevel 1 (
  echo.
  echo Flutter setup failed.
  pause
  exit /b 1
)
call "%FRONTEND_DIR%\flutter.bat" run
pause
