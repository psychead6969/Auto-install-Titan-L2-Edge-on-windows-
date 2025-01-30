@echo off
setlocal enabledelayedexpansion

REM Enable color in the Command Prompt
echo.
echo ===================================================
echo   TITAN EDGE NODE - AUTO INSTALLATION
echo ===================================================
echo.

REM Step 1: Check if Git Bash is installed
echo Checking for Git Bash...
if exist "C:\Program Files\Git\bin\bash.exe" (
    echo [INFO] Git Bash is already installed.
) else (
    echo [INFO] Git Bash is not installed. Installing Git Bash...
    winget install --id=Git.Git --source=winget
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Git Bash. Please install Git manually and re-run this script.
        pause
        exit /b 1
    )
    echo [INFO] Git Bash installation completed.
)

REM Step 2: Check if Curl is installed
echo Checking for Curl...
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Curl is not installed. Installing Curl...
    winget install --id=Curl.Curl --source=winget
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Curl. Please install it manually.
        pause
        exit /b 1
    )
    echo [INFO] Curl installation completed.
)

REM Step 3: Ask for Identity Code
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Step 4: Ask for Number of Nodes (1 to 5)
:ask_nodes
set /p node_count="Enter the number of nodes to deploy (1-5): "
echo %node_count%| findstr /r "^[1-5]$" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Invalid input. Enter a number between 1 and 5.
    goto ask_nodes
)

REM Step 5: Download the script
echo Downloading installation script...
curl -s -o C:\temp\install_nodes.sh https://raw.githubusercontent.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/refs/heads/main/Installation%20of%201~5%20nodes%20on%20windows.sh

REM Step 6: Execute script using Git Bash
echo Running the script with Identity Code and Node Count...
"C:\Program Files\Git\bin\bash.exe" C:\temp\install_nodes.sh %identity_code% %node_count%

echo.
echo ===================================================
echo   EDGE NODE INSTALLATION COMPLETED!
echo ===================================================
echo.

pause
exit
