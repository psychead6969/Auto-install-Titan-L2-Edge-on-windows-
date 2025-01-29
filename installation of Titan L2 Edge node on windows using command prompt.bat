@echo off
REM Enable color in the Command Prompt
echo.
echo ================================
echo   Titan Edge Auto Installation
echo ================================
echo.

REM Step 1: Check if Chocolatey is installed, install if not
echo Checking if Chocolatey is installed...
choco -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Chocolatey not found. Installing...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    echo [INFO] Chocolatey installation complete. Please restart Command Prompt and run this script again.
    pause
    exit /b 1
) else (
    echo [INFO] Chocolatey is already installed.
)

REM Step 2: Install Curl
echo Installing Curl...
choco install curl -y
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Curl. Please check your system configuration.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Curl installed successfully!
)

REM Step 3: Download the Titan Edge ZIP file
echo Downloading Titan Edge ZIP file...
curl -L -o "C:\titan-edge.zip" "https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to download Titan Edge ZIP file. Please check the download link or your internet connection.
    pause
    exit /b 1
)

REM Step 4: Extract the ZIP file
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract ZIP file. Exiting...
    pause
    exit /b 1
)

REM Step 5: Move goworkerd.dll to System32
echo Moving goworkerd.dll to C:\Windows\System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to move goworkerd.dll. Exiting...
    pause
    exit /b 1
)

REM Step 6: Set Titan Edge in the system PATH
echo Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to add Titan Edge to PATH. Exiting...
    pause
    exit /b 1
)

REM Step 7: Create a continuation script to run after restart
echo @echo off > C:\titan-edge\continue_installation.bat
echo echo [INFO] Restarting Command Prompt... >> C:\titan-edge\continue_installation.bat
echo cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64 >> C:\titan-edge\continue_installation.bat
echo start cmd /k "titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0" >> C:\titan-edge\continue_installation.bat
echo timeout /t 24 >> C:\titan-edge\continue_installation.bat
echo set /p identity_code="Enter your identity code (hash): " >> C:\titan-edge\continue_installation.bat
echo titan-edge bind --hash=%%identity_code%% https://api-test1.container1.titannet.io/api/v2/device/binding >> C:\titan-edge\continue_installation.bat
echo echo [SUCCESS] Node is running and bound to your account! >> C:\titan-edge\continue_installation.bat
echo pause >> C:\titan-edge\continue_installation.bat

REM Step 8: Restart Command Prompt and continue installation
echo Restarting Command Prompt...
start cmd /c C:\titan-edge\continue_installation.bat

REM Exit the current session so the new session starts with the correct environment
exit
