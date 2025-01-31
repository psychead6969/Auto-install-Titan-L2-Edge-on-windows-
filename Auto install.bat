@echo off
title Titan Edge Auto Installer
chcp 437 >nul  REM Set CMD encoding to display properly
color 0E
echo.
echo ================================================================
echo                   TITAN EDGE AUTO-INSTALLER
echo ================================================================
echo.

REM Step 0: Check for Administrator Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] This script must be run as an Administrator!
    echo ------------------------------------------------------------
    echo  Please restart the Command Prompt as Administrator.
    echo  To do this, right-click on "Command Prompt" and select
    echo  "Run as administrator."
    echo ------------------------------------------------------------
    pause
    exit /b 1
)

REM Step 1: Prompt for Identity Code Before Installation
color 0E
echo.
echo ================================================================
echo                      NODE BINDING SETUP
echo ================================================================
set /p identity_code="Enter your identity code (hash): "

REM Step 2: Check if Titan Edge is already installed
color 09
echo.
echo [INFO] Checking if Titan Edge is already installed...

if exist "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" (
    color 0A
    echo [SUCCESS] Titan Edge is already installed! Proceeding with extraction and setup...
) else (
    color 09
    echo [INFO] Titan Edge not installed. Proceeding with installation...
    REM Step 3: Download Titan Edge
    echo.
    echo [INFO] Downloading Titan Edge ZIP file...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1' -OutFile 'C:\titan-edge.zip'"
    if %errorlevel% neq 0 (
        color 0C
        echo [ERROR] Failed to download Titan Edge ZIP file. Check your internet connection.
        pause
        exit /b 1
    )
    timeout /t 2 /nobreak

    REM Step 4: Extract ZIP File
    color 09
    echo.
    echo [INFO] Extracting Titan Edge ZIP file...
    powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
    if %errorlevel% neq 0 (
        color 0C
        echo [ERROR] Failed to extract ZIP file.
        pause
        exit /b 1
    )
    timeout /t 2 /nobreak

    REM Step 5: Move goworkerd.dll to System32
    color 09
    echo.
    echo [INFO] Moving goworkerd.dll to C:\Windows\System32...
    move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
    if %errorlevel% neq 0 (
        color 0C
        echo [ERROR] Failed to move goworkerd.dll.
        pause
        exit /b 1
    )
    timeout /t 2 /nobreak

    REM Step 6: Set Titan Edge in the system PATH
    color 09
    echo.
    echo [INFO] Adding Titan Edge directory to system PATH...
    setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
    if %errorlevel% neq 0 (
        color 0C
        echo [ERROR] Failed to add Titan Edge to PATH.
        pause
        exit /b 1
    )
    timeout /t 2 /nobreak
)

:proceed_with_setup

REM Step 7: Set up auto-start for the daemon using Task Scheduler
color 09
echo.
echo ================================================================
echo              CONFIGURING AUTO-START FOR DAEMON...
echo ================================================================
echo [INFO] Adding Titan Edge Daemon to Windows startup...

schtasks /create /tn "TitanEdgeDaemon" /tr "\"C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\titan-edge.exe\" daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0" /sc onstart /ru SYSTEM /f
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Failed to configure auto-start for Titan Edge Daemon.
    pause
    exit /b 1
)

timeout /t 2 /nobreak

REM Step 8: Start Titan Edge Daemon in the Background
color 09
echo.
echo ================================================================
echo              STARTING TITAN EDGE DAEMON...
echo ================================================================
echo [INFO] Titan Edge Daemon is starting in the background...
cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64
start "" /B titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0

REM Step 9: Display Countdown Timer (24 Seconds)
color 0B
echo.
echo ================================================================
echo               WAITING FOR DAEMON INITIALIZATION
echo ================================================================

for /l %%i in (24,-1,1) do (
    set /a "remaining=%%i"
    call :timer
    timeout /t 1 >nul
)
goto :continue

:timer
cls
echo ================================================================
echo                TITAN EDGE INITIALIZATION IN PROGRESS...
echo ================================================================
echo.
echo     Please wait... Daemon is starting.
echo     Remaining time: %remaining% seconds
echo.

:continue

REM Step 10: Bind Node to Account
color 09
echo.
echo ================================================================
echo                   BINDING NODE TO ACCOUNT
echo ================================================================
echo [INFO] Binding node with identity code...
titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Failed to bind node to your account.
    pause
    exit /b 1
)

REM Step 11: Success Message
color 0A
echo.
echo ================================================================
echo                  ✅ NODE SUCCESSFULLY BOUND! ✅
echo ================================================================
echo Your Titan Edge node is now running and connected to the network!
timeout /t 2 /nobreak

exit
