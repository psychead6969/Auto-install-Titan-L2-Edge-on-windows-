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
    echo [INFO] Curl is not installed. Installing Curl using winget...
    REM Step 2: Install curl using winget
    winget install --id=Curl.Curl --source=winget
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install curl. Please install curl manually and re-run this script.
        pause
        exit /b 1
    )
    echo [INFO] Curl installation completed.
)

REM Step 3: Check if WSL is installed
echo Checking for WSL installation...
wsl --list >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] WSL is not installed. Installing WSL...
    REM Step 4: Install WSL
    powershell -Command "wsl --install"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install WSL. Please install WSL manually and re-run this script.
        pause
        exit /b 1
    )
    echo [INFO] WSL installation completed. Please restart your machine if prompted.
    pause
    exit /b 1
)

REM Step 5: Download edge.sh script
echo Downloading edge.sh script...
curl -s https://raw.githubusercontent.com/laodauhgc/bash-scripts/refs/heads/main/titan-network/edge.sh -o C:\temp\edge.sh

REM Step 6: Run edge.sh script using WSL
echo Running the edge.sh script using WSL...
wsl bash /mnt/c/temp/edge.sh 355EE3C6-B533-4712-9C70-F251EF8CA5CB

echo.
echo ===================================================
echo   EDGE NODE INSTALLATION COMPLETED!
echo ===================================================
echo.

pause
exit
