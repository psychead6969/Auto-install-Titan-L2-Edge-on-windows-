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

REM Step 7: Start the Titan Edge daemon
echo.
echo ===========================================
echo   STARTING TITAN EDGE NODE...
echo ===========================================
echo.
cd /d %titan_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64
start "Titan Edge Daemon" cmd /k "titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0"

REM Step 8: Wait 24 seconds for daemon to initialize
timeout /t 24 /nobreak >nul

REM Step 9: Ask for the number of nodes to install (maximum of 5)
set /p node_count="Enter the number of nodes to install (max 5): "
if "%node_count%" lss "1" (
    echo [ERROR] Invalid number of nodes. Please enter a value between 1 and 5.
    pause
    exit /b 1
)
if "%node_count%" gtr "5" (
    echo [ERROR] Too many nodes. Please enter a value between 1 and 5.
    pause
    exit /b 1
)

REM Step 10: Ask for the Titan Identity Code
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Step 11: Invoke PowerShell to start the binding for each node
echo Invoking PowerShell to start Titan Edge node bindings...

powershell -Command "
for ($i = 1; $i -le %node_count%; $i++) {
    Write-Host 'Binding node' $i;
    Start-Process 'titan-edge' -ArgumentList 'bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding' -NoNewWindow
    Start-Sleep -Seconds 2
}
"

echo.
echo ===================================================
echo   NODES SUCCESSFULLY INSTALLED & BOUND!
echo ===================================================
echo.

pause
exit
