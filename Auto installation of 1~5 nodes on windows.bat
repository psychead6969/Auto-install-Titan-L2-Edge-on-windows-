@echo off
title Titan Edge Auto Installer
color 0E
echo.
echo ====================================================
echo    🚀 Titan Edge Auto-Installation Script 🚀
echo ====================================================
echo.

REM Check if the script is running with admin privileges
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script needs to be run as Administrator. Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

REM Set color variables
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=09

REM Prompt for number of nodes (Max 5 nodes)
echo [INFO] How many nodes do you want to bind? (Max 5 nodes)
set /p num_nodes="Enter a number (1-5): "

REM Validate the input (must be between 1 and 5)
if %num_nodes% lss 1 (
    echo [ERROR] Invalid input. Enter a number between 1 and 5.
    exit /b
)
if %num_nodes% gtr 5 (
    echo [ERROR] Invalid input. Enter a number between 1 and 5.
    exit /b
)

REM Prompt for identity code
echo [INFO] Please enter your identity code to bind your node.
set /p identity_code="Enter your identity code (hash): "

REM Step 1: Check if Titan Edge ZIP file is already downloaded
if exist "C:\titan-edge.zip" (
    echo [INFO] Titan Edge ZIP file already exists, skipping download...
) else (
    color %info_color%
    echo [INFO] Downloading Titan Edge ZIP file...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1' -OutFile 'C:\titan-edge.zip'"
    if %errorlevel% neq 0 (
        color %error_color%
        echo [ERROR] Failed to download Titan Edge ZIP file.
        pause
        exit /b 1
    )
)

REM Step 2: Extract the ZIP file
color %info_color%
echo [INFO] Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file.
    pause
    exit /b 1
)

REM Introduce a brief pause to slow down
timeout /t 1 /nobreak

REM Step 3: Copy the extracted files into the same directory (no need for separate directories)
set base_dir=C:\titan-edge
echo [INFO] Copying extracted files to the base directory...
xcopy /e /i /h /y "%base_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64\*" "%base_dir%\"

REM Step 4: Move goworkerd.dll to System32
echo [INFO] Moving goworkerd.dll to System32...
move /y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to move goworkerd.dll.
    pause
    exit /b 1
)

REM Introduce a brief pause to slow down
timeout /t 1 /nobreak

REM Step 5: Add Titan Edge directory to PATH
color %info_color%
echo [INFO] Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to add Titan Edge to PATH.
    pause
    exit /b 1
)

REM Introduce a brief pause to slow down
timeout /t 1 /nobreak

REM Step 6: Start each Titan Edge Daemon in the same window
set /a port_start=5001
for /l %%i in (1,1,%num_nodes%) do (
    set port=%port_start%

    REM Check if the port is available
    :check_port
    netstat -an | findstr ": %port%" > nul
    if %errorlevel% equ 0 (
        REM Port is already in use, try the next port
        set /a port+=1
        goto :check_port
    )

    REM Start Titan Edge Daemon in the same window
    echo [INFO] Starting Node %%i on port %port%...
    cd C:\titan-edge
    start cmd /k "titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port %port%"
    
    REM Increase port for next node
    set /a port_start+=1
)

REM Step 7: Wait for 24 seconds to ensure the daemon has started
echo [INFO] Please wait 24 seconds for the nodes to start...
timeout /t 24 /nobreak

REM Step 8: Request identity code binding (done after all nodes are started)
color %prompt_color%
echo [INFO] Nodes should be running. Now binding them to your account...
timeout /t 1 /nobreak

REM Step 9: Bind the node to account after delay (1 per node)
for /l %%i in (1,1,%num_nodes%) do (
    echo [INFO] Binding Node %%i to account...
    titan-edge bind --hash %identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
)

REM Step 10: Check the node status
echo [INFO] Checking node status...
titan-edge info

REM Step 11: Success message
color %success_color%
echo ✅ [SUCCESS] Nodes are running and bound to your account!

REM Final pause to allow user to see success message
timeout /t 2 /nobreak

REM Show command prompt in foreground
pause

exit
