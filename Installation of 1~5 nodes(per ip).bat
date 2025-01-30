@echo off
setlocal enabledelayedexpansion

REM Enable color in the Command Prompt
echo.
echo ===================================================
echo   TITAN EDGE NODE - AUTO INSTALLATION
echo ===================================================
echo.

REM Set up variables
set titan_url=https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1
set titan_path=C:\titan-edge.zip
set titan_dir=C:\TitanNode
set base_port=5001

REM Step 1: Download Titan Edge if not already downloaded
if exist "%titan_path%" (
    echo [INFO] Titan Edge ZIP file already exists. Proceeding to extraction...
) else (
    echo Downloading Titan Edge ZIP file...
    powershell -Command "Invoke-WebRequest -Uri '%titan_url%' -OutFile '%titan_path%'"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download Titan Edge ZIP file.
        pause
        exit /b 1
    )
)

REM Step 2: Extract Titan Edge
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path '%titan_path%' -DestinationPath '%titan_dir%' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract ZIP file.
    pause
    exit /b 1
)

REM Step 3: Move goworkerd.dll to System32
echo Moving necessary files...
move /y "%titan_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64\goworkerd.dll" "C:\Windows\System32"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to move goworkerd.dll to System32.
    pause
    exit /b 1
)

REM Step 4: Add Titan Edge to PATH
echo Adding Titan Edge to system PATH...
setx PATH "%PATH%;%titan_dir%\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to add Titan Edge to system PATH.
    pause
    exit /b 1
)

REM Step 5: Prompt user for the number of nodes
set /p num_nodes="Enter the number of nodes to set up (1-5): "

REM Validate the input
if !num_nodes! lss 1 (
    echo [ERROR] You must set at least 1 node.
    pause
    exit /b 1
)

if !num_nodes! gtr 5 (
    echo [ERROR] The maximum number of nodes allowed is 5.
    pause
    exit /b 1
)

REM Prompt user for the Titan Identity Code
set /p identity_code="Enter your Titan Identity Code (hash): "

REM Step 6: Loop to create and start the specified number of nodes
for /L %%i in (1,1,!num_nodes!) do (
    set node_dir=%titan_dir%\Node%%i
    set /a node_port=!base_port!+%%i

    echo.
    echo ===========================================
    echo   SETTING UP TITAN EDGE NODE %%i
    echo ===========================================
    echo.

    REM Create a directory for the node
    mkdir "!node_dir!"

    REM Start the Titan Edge daemon for this node in the background
    start /B cmd /c "cd /d !node_dir! && titan-edge daemon start --init --url https://cassini-locator.titannet.io:!node_port!/rpc/v0"

    REM Wait for a few seconds to allow the node to initialize
    timeout /t 5 /nobreak >nul

    REM Bind the node using the same identity code
    echo Binding Titan Edge node %%i...
    titan-edge bind --hash=!identity_code! https://api-test1.container1.titannet.io/api/v2/device/binding
)

echo.
echo ===================================================
echo   ALL NODES SUCCESSFULLY INSTALLED & BOUND!
echo ===================================================
echo.

pause
exit
