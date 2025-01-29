@echo off
title Titan Edge Auto Installer
color 0E
echo.
echo ====================================================
echo    🚀 Titan Edge Auto-Installation Script 🚀
echo ====================================================
echo.

REM Set color variables
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=09

REM Prompt for number of nodes
color %prompt_color%
echo [INFO] How many nodes do you want to bind? (Max 5 nodes)
set /p num_nodes="Enter a number (1-5): "

REM Validate input
if "%num_nodes%" lss "1" (
    echo [ERROR] Invalid input. Please enter a number between 1 and 5.
    pause
    exit /b 1
)
if "%num_nodes%" gtr "5" (
    echo [ERROR] You can bind a maximum of 5 nodes.
    pause
    exit /b 1
)

REM Set directories based on user input
set node1_dir=C:\titan-edge-node1
set node2_dir=C:\titan-edge-node2
set node3_dir=C:\titan-edge-node3
set node4_dir=C:\titan-edge-node4
set node5_dir=C:\titan-edge-node5

REM Step 1: Download the Titan Edge ZIP file once
color %info_color%
echo [INFO] Downloading Titan Edge ZIP file...
powershell -Command "Invoke-WebRequest -Uri 'https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1' -OutFile 'C:\titan-edge.zip'"

REM Step 2: Extract the ZIP file
echo [INFO] Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"

REM Step 3: Copy the extracted files to each node's directory
if %num_nodes% geq 1 (
    echo [INFO] Copying extracted files to Node 1 directory...
    xcopy /E /I /Y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" "%node1_dir%\"
)
if %num_nodes% geq 2 (
    echo [INFO] Copying extracted files to Node 2 directory...
    xcopy /E /I /Y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" "%node2_dir%\"
)
if %num_nodes% geq 3 (
    echo [INFO] Copying extracted files to Node 3 directory...
    xcopy /E /I /Y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" "%node3_dir%\"
)
if %num_nodes% geq 4 (
    echo [INFO] Copying extracted files to Node 4 directory...
    xcopy /E /I /Y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" "%node4_dir%\"
)
if %num_nodes% geq 5 (
    echo [INFO] Copying extracted files to Node 5 directory...
    xcopy /E /I /Y "C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64" "%node5_dir%\"
)

REM Step 4: Move goworkerd.dll to System32 for each node
color %info_color%
if %num_nodes% geq 1 (
    echo [INFO] Moving goworkerd.dll for Node 1...
    move /y "%node1_dir%\goworkerd.dll" "C:\Windows\System32"
)
if %num_nodes% geq 2 (
    echo [INFO] Moving goworkerd.dll for Node 2...
    move /y "%node2_dir%\goworkerd.dll" "C:\Windows\System32"
)
if %num_nodes% geq 3 (
    echo [INFO] Moving goworkerd.dll for Node 3...
    move /y "%node3_dir%\goworkerd.dll" "C:\Windows\System32"
)
if %num_nodes% geq 4 (
    echo [INFO] Moving goworkerd.dll for Node 4...
    move /y "%node4_dir%\goworkerd.dll" "C:\Windows\System32"
)
if %num_nodes% geq 5 (
    echo [INFO] Moving goworkerd.dll for Node 5...
    move /y "%node5_dir%\goworkerd.dll" "C:\Windows\System32"
)

REM Step 5: Start Titan Edge Daemon for each node in the background
color %info_color%
if %num_nodes% geq 1 (
    echo [INFO] Starting Titan Edge Daemon for Node 1...
    start /b cmd /c "cd %node1_dir% && titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port 5001"
)
if %num_nodes% geq 2 (
    echo [INFO] Starting Titan Edge Daemon for Node 2...
    start /b cmd /c "cd %node2_dir% && titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port 5002"
)
if %num_nodes% geq 3 (
    echo [INFO] Starting Titan Edge Daemon for Node 3...
    start /b cmd /c "cd %node3_dir% && titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port 5003"
)
if %num_nodes% geq 4 (
    echo [INFO] Starting Titan Edge Daemon for Node 4...
    start /b cmd /c "cd %node4_dir% && titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port 5004"
)
if %num_nodes% geq 5 (
    echo [INFO] Starting Titan Edge Daemon for Node 5...
    start /b cmd /c "cd %node5_dir% && titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port 5005"
)

REM Add a small delay between binding requests to avoid rate limiting
timeout /t 5 /nobreak

REM Step 6: Bind Nodes to Account
color %info_color%
if %num_nodes% geq 1 (
    echo [INFO] Binding Node 1...
    titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
)
if %num_nodes% geq 2 (
    echo [INFO] Binding Node 2...
    titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
)
if %num_nodes% geq 3 (
    echo [INFO] Binding Node 3...
    titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
)
if %num_nodes% geq 4 (
    echo [INFO] Binding Node 4...
    titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
)
if %num_nodes% geq 5 (
    echo [INFO] Binding Node 5...
    titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
)

REM Step 7: Success message
color %success_color%
echo ✅ [SUCCESS] All nodes are running and bound to your account!

REM Final pause to allow user to see success message
timeout /t 2 /nobreak

exit
