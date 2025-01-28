@echo off
REM Enable color in the Command Prompt
REM Changing text color to bright yellow for headers
echo.
echo ================================
echo   Titan Edge Auto Installation
echo ================================
echo.

REM Set colors for messages
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=07

REM Step 1: Check if we just restarted
if exist "C:\restart_flag.txt" (
    REM Skip Chocolatey installation and go directly to step 3
    del "C:\restart_flag.txt"
    goto Step3
)

REM Step 2: Check if Chocolatey is installed, if not install it
echo Checking for Chocolatey...
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Chocolatey not found, installing...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %errorlevel% neq 0 (
        color %error_color%
        echo [ERROR] Failed to install Chocolatey. Exiting...
        pause
        exit /b 1
    )
    REM Create a restart flag and restart Command Prompt
    echo Restart flag set. Please wait while the Command Prompt restarts...
    echo > C:\restart_flag.txt
    shutdown /r /f /t 0
    exit /b
)

REM Step 3: Check if curl is installed, if not, install it via Chocolatey
where curl >nul 2>nul
if %errorlevel% neq 0 (
    color %info_color%
    echo Installing curl via Chocolatey...
    choco install curl -y
    if %errorlevel% neq 0 (
        color %error_color%
        echo [ERROR] Failed to install curl. Exiting...
        pause
        exit /b 1
    )
)

REM Step 4: Download the Titan Edge ZIP file
color %info_color%
echo Downloading Titan Edge ZIP file...
curl -L -o "C:\titan-edge.zip" "https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to download Titan Edge ZIP file. Please check the download link or your internet connection.
    pause
    exit /b 1
)

REM Step 5: Extract the ZIP file
color %info_color%
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file. Exiting...
    pause
    exit /b 1
)

REM Step 6: Move goworkerd.dll to System32
color %info_color%
echo Moving goworkerd.dll to C:\Windows\System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to move goworkerd.dll. Exiting...
    pause
    exit /b 1
)

REM Step 7: Start the Titan Edge daemon
color %success_color%
echo Starting Titan Edge daemon...
start /B titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0
timeout /t 10 >nul
REM Force exit if the daemon command doesn't exit after 10 seconds
taskkill /f /im titan-edge.exe >nul

REM Step 8: Check if the daemon is running and proceed with binding
color %prompt_color%
set /p identity_code="Enter your identity code (hash): "
color %success_color%
echo Binding Titan Edge node with the provided identity code...
titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to bind Titan Edge node. Please check the identity code or connection.
    pause
    exit /b 1
)

REM Step 9: Clean up extracted files
color %info_color%
echo Cleaning up extracted files...
rmdir /s /q "C:\titan-edge"
del "C:\titan-edge.zip"

color %success_color%
echo ================================
echo Titan Edge installation complete!
echo ================================
pause
