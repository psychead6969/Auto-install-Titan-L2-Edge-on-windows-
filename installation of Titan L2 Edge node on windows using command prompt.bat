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

REM Step 1: Check if Chocolatey is installed, install if not
echo Checking if Chocolatey is installed...
choco -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Chocolatey not found, installing...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    echo [INFO] Chocolatey installation complete. Restarting Command Prompt...
    pause
    exit /b 1
)

REM Step 2: Install curl using Chocolatey
echo Installing curl...
choco install curl -y
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to install curl. Please check your system configuration.
    pause
    exit /b 1
)

REM Step 3: Download the Titan Edge ZIP file
color %info_color%
echo Downloading Titan Edge ZIP file...
curl -L -o "C:\titan-edge.zip" "https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to download Titan Edge ZIP file. Please check the download link or your internet connection.
    pause
    exit /b 1
)

REM Step 4: Extract the ZIP file
color %info_color%
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file. Exiting...
    pause
    exit /b 1
)

REM Step 5: Move goworkerd.dll to System32
color %info_color%
echo Moving goworkerd.dll to C:\Windows\System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to move goworkerd.dll. Exiting...
    pause
    exit /b 1
)

REM Step 6: Set Titan Edge in the system PATH
color %info_color%
echo Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to add Titan Edge to PATH. Exiting...
    pause
    exit /b 1
)

REM Step 7: Create a new batch file with the remaining steps
echo Creating a temporary batch file to continue the installation...
echo @echo off > C:\titan-edge\continue_installation.bat
echo color %info_color% >> C:\titan-edge\continue_installation.bat
echo echo "Continuing installation..." >> C:\titan-edge\continue_installation.bat
echo cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64 >> C:\titan-edge\continue_installation.bat
echo start /b titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 >> C:\titan-edge\continue_installation.bat
echo echo "Daemon started. Waiting for registration..." >> C:\titan-edge\continue_installation.bat
echo :check_daemon >> C:\titan-edge\continue_installation.bat
echo for /f "delims=" %%i in ('titan-edge daemon status') do set output=%%i >> C:\titan-edge\continue_installation.bat
echo echo %output% >> C:\titan-edge\continue_installation.bat
echo echo Checking for "Edge registered successfully, waiting for the tasks" message... >> C:\titan-edge\continue_installation.bat
echo echo %output% | findstr /i "Edge registered successfully, waiting for the tasks" >nul && goto bind_identity_code >> C:\titan-edge\continue_installation.bat
echo timeout /t 5 >> C:\titan-edge\continue_installation.bat
echo goto check_daemon >> C:\titan-edge\continue_installation.bat
echo :bind_identity_code >> C:\titan-edge\continue_installation.bat
echo echo "Daemon registered. Please enter your identity code." >> C:\titan-edge\continue_installation.bat
echo set /p identity_code="Enter your identity code (hash): " >> C:\titan-edge\continue_installation.bat
echo titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding >> C:\titan-edge\continue_installation.bat
echo echo "Node is running and bound to your account." >> C:\titan-edge\continue_installation.bat
echo rmdir /s /q C:\titan-edge >> C:\titan-edge\continue_installation.bat
echo del C:\titan-edge.zip >> C:\titan-edge\continue_installation.bat
echo echo Installation complete! >> C:\titan-edge\continue_installation.bat

REM Step 8: Restart the Command Prompt to apply PATH changes
echo Restarting the Command Prompt to apply changes...
start /b cmd /c C:\titan-edge\continue_installation.bat

REM Exit the current session so the new session starts with the correct environment
exit
