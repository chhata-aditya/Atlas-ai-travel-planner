@echo off
title Atlas - Full Stack Runner
cls

echo ====================================================================
echo                   ATLAS TRAVEL APP - RUNNER
echo ====================================================================
echo.

:: 1. Launch Spring Boot Backend
echo [1/2] Starting Spring Boot Backend (http://localhost:8080/api)...
set BACKEND_DIR=c:\Users\chhat\atlas-server
if exist "%BACKEND_DIR%" (
    start "Atlas Backend - Spring Boot [Port 8080]" cmd /k "cd /d %BACKEND_DIR% && title Atlas Spring Boot [Port 8080] && echo Starting Spring Boot Backend... && .\mvnw.cmd spring-boot:run"
    echo       Backend started in a separate window.
) else (
    echo       [WARNING] Backend directory not found at %BACKEND_DIR%
)
echo.

:: 2. Launch Flutter
echo [2/2] Starting Atlas App...
cd /d c:\Users\chhat\test_app
echo.
echo       Select Target Platform:
echo       [1] Android Phone (USB Debugging)
echo       [2] Windows Desktop Application
echo       [3] Google Chrome (Web)
echo.
set /p DEVICE_CHOICE="Enter choice [1-3, default=1]: "

if "%DEVICE_CHOICE%"=="2" (
    echo Starting Windows Desktop App...
    flutter run -d windows
) else if "%DEVICE_CHOICE%"=="3" (
    echo Starting on Google Chrome...
    flutter run -d chrome
) else (
    echo.
    echo Setting up USB port forwarding for backend (port 8080)...
    where adb >nul 2>nul
    if %errorlevel%==0 (
        adb reverse tcp:8080 tcp:8080
    ) else if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:8080 tcp:8080
    ) else (
        echo [NOTE] adb command not in PATH. If login does not connect, run 'adb reverse tcp:8080 tcp:8080'.
    )
    echo Starting on connected Android phone...
    flutter run
)

pause
