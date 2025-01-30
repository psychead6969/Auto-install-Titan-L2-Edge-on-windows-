@echo off
REM Enable color in the Command Prompt
echo.
echo ===========================================
echo   Titan Edge Single-Node Installation
echo ===========================================
echo.

REM Set Titan Edge download link
set titan_url=https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1
set titan_path=C:\titan-edge.zip

REM Check if Titan Edge is already downloaded
if exist "%titan_path%" (
    echo [INFO] Titan Edge ZIP file already exists. Proceeding to extraction...
) else (
    echo Downloading Titan Edge ZIP file...
    powershell -Command "Invoke-WebRequest -Uri '%titan_url%' -OutFile '%titan_path%'"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download Titan Edge ZIP file. Please check your internet connection.
        pause
        exit /b 1
    )
)

REM Extract Titan Edge
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract ZIP file. Exiting...
    pause
    exit /b 1
)

REM Move GoWorked DLL to Windows System32
echo Moving GoWorked DLL to System32...
if exist "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworked.dll" (
    move /Y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworked.dll" "C:\Windows\System32\goworked.dll"
) else (
    echo [WARNING] goworked.dll not found. Titan Edge may not work correctly.
)

REM Add Titan Edge to system PATH
echo Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to add Titan Edge to PATH. Exiting...
    pause
    exit /b 1
)

REM Change directory to Titan Edge folder
cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64

REM Start the Titan Edge node in the background
echo Starting Titan Edge node in the background...
start /b titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 > nul 2>&1

REM Wait for the daemon to initialize
echo Waiting for 24 seconds to ensure the daemon starts properly...
timeout /t 24 > nul

REM Prompt for identity code after daemon starts
set /p identity_code="Enter your identity code (hash) for binding: "
titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding

echo [SUCCESS] Node is running in the background and bound to your account!
pause
