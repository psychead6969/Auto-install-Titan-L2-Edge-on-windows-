@echo off
setlocal enabledelayedexpansion

REM Enable color in the Command Prompt
echo.
echo ===================================================
echo   TITAN EDGE NODE - AUTO INSTALLATION
echo ===================================================
echo.

REM Set colors for messages
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=07

REM Step 1: Check if Curl is installed
echo Checking for Curl...
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Curl is not installed. Please install Curl manually and re-run this script.
    pause
    exit /b 1
)

REM Step 2: Set up variables
set titan_url=https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1
set titan_path=C:\titan-edge.zip
set titan_dir=C:\TitanNode

REM Step 3: Download Titan Edge if not already downloaded
if exist "%titan_path%" (
    echo [INFO] Titan Edge ZIP file already exists. Proceeding to extraction...
) else (
    echo Downloading Titan Edge ZIP file...
    curl -L -o "%titan_path%" "%titan_url%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download Titan Edge ZIP file.
        pause
        exit /b 1
    )
)

REM Step 4: Extract Titan Edge
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path '%titan_path%' -DestinationPath '%titan_dir%' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract ZIP file.
    pause
    exit /b 1
)

REM Step 5: Move goworkerd.dll to System32
echo Moving necessary files...
move /y "%titan_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"

REM Step 6: Add Titan Edge to PATH
echo Adding Titan Edge to system PATH...
setx PATH "%PATH%;%titan_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64"

REM Step 7: Start the Titan Edge daemon in the same Command Prompt window
echo.
echo ===========================================
echo   STARTING TITAN EDGE NODE...
echo ===========================================
echo.
cd /d %titan_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64
start "" cmd /k "titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0"

REM Step 8: Wait 24 seconds for daemon to initialize
timeout /t 24 /nobreak >nul

REM Step 9: Ask for the Titan Identity Code
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Step 10: Bind the node (No PowerShell, just run the binding directly)
echo Binding the Titan Edge node...
titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding

echo.
echo ===================================================
echo   NODE SUCCESSFULLY INSTALLED & BOUND!
echo ===================================================
echo.

pause
exit
