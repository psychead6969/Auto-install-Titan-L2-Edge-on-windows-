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

REM Step 1: Check if Git Bash is installed
echo Checking for Git Bash...
if exist "C:\Program Files\Git\bin\bash.exe" (
    echo [INFO] Git Bash is already installed.
) else (
    echo [INFO] Git Bash is not installed. Installing Git Bash...
    REM Step 2: Install Git Bash using winget
    winget install --id=Git.Git --source=winget
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Git Bash. Please install Git for Windows manually and re-run this script.
        pause
        exit /b 1
    )
    echo [INFO] Git Bash installation completed.
)

REM Step 3: Check if Curl is installed
echo Checking for Curl...
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Curl is not installed. Installing Curl using winget...
    REM Install curl using winget
    winget install --id=Curl.Curl --source=winget
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install curl. Please install curl manually and re-run this script.
        pause
        exit /b 1
    )
    echo [INFO] Curl installation completed.
)

REM Step 4: Ask for Identity Code
echo.
echo ===================================================
echo   PLEASE ENTER YOUR TITAN IDENTITY CODE
echo ===================================================
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Step 5: Download edge.sh script
echo Downloading edge.sh script...
curl -s https://raw.githubusercontent.com/laodauhgc/bash-scripts/refs/heads/main/titan-network/edge.sh -o C:\temp\edge.sh

REM Step 6: Run edge.sh script using Git Bash
echo Running the edge.sh script using Git Bash with Identity Code: %identity_code%...
"C:\Program Files\Git\bin\bash.exe" C:\temp\edge.sh %identity_code%

echo.
echo ===================================================
echo   EDGE NODE INSTALLATION COMPLETED!
echo ===================================================
echo.

pause
exit
