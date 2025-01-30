@echo off
title Titan Edge Auto Installer
color 0E
echo.
echo ================================================================
echo            Titan Edge Auto-Installation Script
echo ================================================================
echo.

REM Set color variables
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=09
set banner_color=0B

REM Step 1: Check if Titan Edge is already installed
color %info_color%
echo [INFO] Checking if Titan Edge is already installed...

if exist "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" (
    color %success_color%
    echo ✅ [SUCCESS] Titan Edge is already installed!
    echo [INFO] Exiting script.
    pause
    exit /b 0
)

REM Introduce a 2-second pause to slow down
timeout /t 2 /nobreak

REM Step 2: Download the Titan Edge ZIP file directly using Invoke-WebRequest
color %info_color%
echo [INFO] Downloading Titan Edge ZIP file...
powershell -Command "Invoke-WebRequest -Uri 'https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1' -OutFile 'C:\titan-edge.zip'"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to download Titan Edge ZIP file. Check your internet connection.
    pause
    exit /b 1
)

REM Introduce a 2-second pause to slow down
timeout /t 2 /nobreak

REM Step 3: Extract the ZIP file
color %info_color%
echo [INFO] Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file.
    pause
    exit /b 1
)

REM Introduce a 2-second pause to slow down
timeout /t 2 /nobreak

REM Step 4: Move goworkerd.dll to System32
color %info_color%
echo [INFO] Moving goworkerd.dll to C:\Windows\System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to move goworkerd.dll.
    pause
    exit /b 1
)

REM Introduce a 2-second pause to slow down
timeout /t 2 /nobreak

REM Step 5: Set Titan Edge in the system PATH
color %info_color%
echo [INFO] Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to add Titan Edge to PATH.
    pause
    exit /b 1
)

REM Introduce a 2-second pause to slow down
timeout /t 2 /nobreak

REM Step 6: Start Titan Edge Daemon in the background
color %info_color%
echo [INFO] Starting Titan Edge Daemon in the background...
cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64
start "" /B titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0

REM Step 7: Display countdown timer (24 seconds)
color %banner_color%
echo [INFO] Waiting for the daemon to initialize...
for /l %%i in (24,-1,1) do (
    set /a "remaining=%%i"
    call :timer
    timeout /t 1 >nul
)
goto :continue

:timer
cls
echo [INFO] Daemon is initializing... %remaining% seconds remaining.
echo.
echo   ███████████████████████████████████████████
echo   ████  Please wait, setting up Titan Edge...  ████
echo   ███████████████████████████████████████████
echo.

:continue

REM Step 8: Request Identity Code
color %prompt_color%
echo [INFO] Please enter your identity code to bind your node.
set /p identity_code="🔹 Enter your identity code (hash): "

REM Introduce a 2-second pause to slow down
timeout /t 2 /nobreak

REM Step 9: Bind Node to Account
color %info_color%
echo [INFO] Binding node to account...
titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to bind node to your account.
    pause
    exit /b 1
)

REM Step 10: Success message
color %success_color%
echo ✅ [SUCCESS] Node is running and bound to your account!

REM Final pause to allow user to see success message
timeout /t 2 /nobreak

exit
