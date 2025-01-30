@echo off
setlocal enabledelayedexpansion

REM Enable color in the Command Prompt
echo.
echo ===================================================
echo   TITAN EDGE NODE - AUTO INSTALLATION
echo ===================================================
echo.

REM Step 1: Check if Chocolatey is installed
choco -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Chocolatey is not installed. Installing Chocolatey now...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Chocolatey. Please install it manually from:
        echo https://chocolatey.org/install
        pause
        exit /b 1
    )
    
    echo [INFO] Chocolatey installation completed. Restarting Command Prompt...
    exit
)

REM Step 2: Install Git Bash if not installed
if exist "C:\Program Files\Git\bin\bash.exe" (
    echo [INFO] Git Bash is already installed.
) else (
    echo [INFO] Installing Git Bash...
    choco install git -y
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Git Bash. Please install it manually from:
        echo https://git-scm.com/downloads
        pause
        exit /b 1
    )
)

REM Step 3: Install Curl if not installed
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Installing Curl...
    choco install curl -y
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Curl. Please install it manually from:
        echo https://curl.se/windows/
        pause
        exit /b 1
    )
)

REM Step 4: Ask for Identity Code
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Step 5: Ask for Number of Nodes (1 to 5)
:ask_nodes
set /p node_count="Enter the number of nodes to deploy (1-5): "
echo %node_count%| findstr /r "^[1-5]$" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Invalid input. Enter a number between 1 and 5.
    goto ask_nodes
)

REM Step 6: Download the Titan Edge installation script
curl -s -o C:\temp\install_nodes.sh https://raw.githubusercontent.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/refs/heads/main/Installation%20of%201~5%20nodes%20on%20windows.sh

REM Step 7: Execute script using Git Bash
echo Running the script with Identity Code and Node Count...
"C:\Program Files\Git\bin\bash.exe" C:\temp\install_nodes.sh %identity_code% %node_count%

echo.
echo ===================================================
echo   EDGE NODE INSTALLATION COMPLETED!
echo ===================================================
echo.

pause
exit
