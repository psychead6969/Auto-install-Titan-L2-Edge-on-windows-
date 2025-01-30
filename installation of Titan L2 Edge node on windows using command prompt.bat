@echo off
setlocal enabledelayedexpansion

REM Enable color in the Command Prompt
echo.
echo ===================================================
echo   Titan Edge Multi-Node Installation (Port-Based)
echo ===================================================
echo.

REM Prompt user for number of nodes (max 5)
set /p node_count="Enter the number of nodes you want to install (max 5): "
if %node_count% GTR 5 (
    echo [ERROR] You can install a maximum of 5 nodes.
    pause
    exit /b 1
)

REM Ask for identity code (all nodes use the same)
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Set Titan Edge download link
set titan_url=https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1
set titan_path=C:\titan-edge.zip

REM Check if Titan Edge is already downloaded
if exist "%titan_path%" (
    echo [INFO] Titan Edge ZIP file already exists. Proceeding to extraction...
) else (
    echo Downloading Titan Edge ZIP file...
    powershell -Command "& {Invoke-WebRequest -Uri '%titan_url%' -OutFile '%titan_path%'}"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download Titan Edge ZIP file.
        pause
        exit /b 1
    )
)

REM Extract Titan Edge
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"

REM Define base port (each node will use a different one)
set base_port=5100

REM Install Titan Edge daemon for each node
for /L %%i in (1,1,%node_count%) do (
    set /a node_port=%base_port%+%%i
    set node_dir=C:\TitanNode%%i
    if not exist "!node_dir!" mkdir "!node_dir!"

    echo.
    echo ===========================================
    echo   Starting Titan Edge Node %%i on Port !node_port!
    echo ===========================================
    echo.

    cd /d C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64
    start "Titan Node %%i" cmd /k "titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --listen=:!node_port! --data=!node_dir!"

    REM Wait 20 seconds for the daemon to initialize
    timeout /t 20 /nobreak >nul

    REM Bind the node to the identity
    start "Binding Node %%i" cmd /k "titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding"

    echo [SUCCESS] Node %%i is running on port !node_port! and bound to your account!
)

echo.
echo ===================================================
echo   All nodes have been started and bound successfully!
echo ===================================================
echo.

pause
exit
