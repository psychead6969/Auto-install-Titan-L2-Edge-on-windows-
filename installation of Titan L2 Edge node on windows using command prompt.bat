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

REM Step 1: Install curl using winget
echo Installing curl...
winget install -e --id Curl.Curl --silent
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to install curl. Please check your system configuration.
    pause
    exit /b 1
)

REM Step 2: Download the Titan Edge ZIP file
color %info_color%
echo Downloading Titan Edge ZIP file...
curl -L -o "C:\titan-edge.zip" "https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to download Titan Edge ZIP file. Please check the download link or your internet connection.
    pause
    exit /b 1
)

REM Step 3: Extract the ZIP file
color %info_color%
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file. Exiting...
    pause
    exit /b 1
)

REM Step 4: Move goworkerd.dll to System32
color %info_color%
echo Moving goworkerd.dll to C:\Windows\System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to move goworkerd.dll. Exiting...
    pause
    exit /b 1
)

REM Step 5: Add the Titan Edge path to the system PATH environment variable
color %info_color%
echo Adding Titan Edge to system PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"

REM Step 6: Prompt the user to restart the Command Prompt or the system
color %prompt_color%
echo.
echo ================================
echo [INFO] PATH updated successfully.
echo ================================
echo.

set /p restart_choice="Do you want to restart the Command Prompt now to apply the changes? (Y/N): "

if /I "%restart_choice%" == "Y" (
    color %success_color%
    echo Restarting Command Prompt...
    timeout /t 2 /nobreak >nul
    start cmd.exe /K
    exit
) else (
    color %info_color%
    echo You can manually restart the Command Prompt later for the changes to take effect.
)

REM Step 7: Start the Titan Edge daemon
color %success_color%
echo Starting Titan Edge daemon...
titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to start Titan Edge daemon. Exiting...
    pause
    exit /b 1
)

REM Step 8: Prompt for identity code and bind the node
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
