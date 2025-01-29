@echo off
title Titan Edge Auto Installer
color 0E
echo.
echo ====================================================
echo    🚀 Titan Edge Auto-Installation Script 🚀
echo ====================================================
echo.

REM Set color variables
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=09

REM Step 1: Check if Chocolatey is installed
color %info_color%
echo [INFO] Checking if Chocolatey is installed...
choco -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Chocolatey not found. Installing now...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    color %success_color%
    echo [SUCCESS] Chocolatey installed! The installation will continue automatically after Command Prompt restart.
    
    REM Create the continuation bat file to run after restart
    echo @echo off > C:\titan-edge\continue_installation.bat
    echo color %info_color% >> C:\titan-edge\continue_installation.bat
    echo echo ==================================================== >> C:\titan-edge\continue_installation.bat
    echo echo    Continuing Titan Edge Installation Step 2   >> C:\titan-edge\continue_installation.bat
    echo echo ==================================================== >> C:\titan-edge\continue_installation.bat
    echo start cmd /c C:\titan-edge\continue_installation.bat >> C:\titan-edge\continue_installation.bat
    echo exit >> C:\titan-edge\continue_installation.bat

    REM Step 8: Restart Command Prompt and continue installation
    start cmd /c C:\titan-edge\continue_installation.bat
    exit
) else (
    color %success_color%
    echo [SUCCESS] Chocolatey is already installed!
)

REM Step 2: Install Curl
color %info_color%
echo [INFO] Installing Curl...
choco install curl -y
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to install Curl. Please check your system configuration.
    pause
    exit /b 1
) else (
    color %success_color%
    echo [SUCCESS] Curl installed successfully!
)

REM Step 3: Download the Titan Edge ZIP file
color %info_color%
echo [INFO] Downloading Titan Edge ZIP file...
curl -L -o "C:\titan-edge.zip" "https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to download Titan Edge ZIP file. Check your internet connection.
    pause
    exit /b 1
)

REM Step 4: Extract the ZIP file
color %info_color%
echo [INFO] Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file.
    pause
    exit /b 1
)

REM Step 5: Move goworkerd.dll to System32
color %info_color%
echo [INFO] Moving goworkerd.dll to C:\Windows\System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to move goworkerd.dll.
    pause
    exit /b 1
)

REM Step 6: Set Titan Edge in the system PATH
color %info_color%
echo [INFO] Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to add Titan Edge to PATH.
    pause
    exit /b 1
)

REM Step 7: Create a continuation script for running the daemon
echo @echo off > C:\titan-edge\continue_installation.bat
echo color %info_color% >> C:\titan-edge\continue_installation.bat
echo echo ==================================================== >> C:\titan-edge\continue_installation.bat
echo echo    Starting Titan Edge Daemon and Binding Node    >> C:\titan-edge\continue_installation.bat
echo echo ==================================================== >> C:\titan-edge\continue_installation.bat
echo cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64 >> C:\titan-edge\continue_installation.bat
echo start cmd /k "titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0" >> C:\titan-edge\continue_installation.bat
echo timeout /t 24 >> C:\titan-edge\continue_installation.bat
echo color %prompt_color% >> C:\titan-edge\continue_installation.bat
echo set /p identity_code="🔹 Enter your identity code (hash): " >> C:\titan-edge\continue_installation.bat
echo titan-edge bind --hash=%%identity_code%% https://api-test1.container1.titannet.io/api/v2/device/binding >> C:\titan-edge\continue_installation.bat
echo color %success_color% >> C:\titan-edge\continue_installation.bat
echo echo ✅ [SUCCESS] Node is running and bound to your account! >> C:\titan-edge\continue_installation.bat
echo exit >> C:\titan-edge\continue_installation.bat

REM Step 8: Restarting Command Prompt and continue installation
color %info_color%
echo [INFO] Restarting Command Prompt and continuing installation...
start cmd /c C:\titan-edge\continue_installation.bat
exit
