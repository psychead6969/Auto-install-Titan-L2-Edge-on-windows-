@echo off
REM Enable color in the Command Prompt
echo.
echo ===========================================
echo   Titan Edge Multi-Node Auto Installation
echo ===========================================
echo.

REM Set colors for messages
set success_color=0A
set error_color=0C
set prompt_color=0E
set info_color=07

REM Prompt user for number of nodes (max 5)
set /p node_count="Enter the number of nodes you want to install (max 5): "
if %node_count% GTR 5 (
    echo [ERROR] You can install a maximum of 5 nodes.
    pause
    exit /b 1
)

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
        color %error_color%
        echo [ERROR] Failed to download Titan Edge ZIP file. Please check the download link or your internet connection.
        pause
        exit /b 1
    )
)

REM Extract Titan Edge
echo Extracting Titan Edge ZIP file...
powershell -Command "Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to extract ZIP file. Exiting...
    pause
    exit /b 1
)

REM Set Titan Edge in the system PATH
color %info_color%
echo Adding Titan Edge directory to PATH...
setx PATH "%PATH%;C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64"
if %errorlevel% neq 0 (
    color %error_color%
    echo [ERROR] Failed to add Titan Edge to PATH. Exiting...
    pause
    exit /b 1
)

REM Change directory to Titan Edge folder
cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64

REM Start and bind multiple nodes with unique ports
for /L %%i in (1,1,%node_count%) do (
    REM Create a unique directory for each node
    set "node_dir=C:\titan-edge\node_%%i"
    if not exist "!node_dir!" mkdir "!node_dir!"
    
    REM Set a unique port for each node (starting from 5001)
    set /A port=5000+%%i
    echo Starting Titan Edge Node %%i on port !port!...
    
    REM Start the node with the unique port and repository
    start /b "" titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --repo "!node_dir!" --port !port!
    
    REM Wait for 24 seconds to ensure daemon starts properly
    timeout /t 24
    
    REM Ask for identity code after daemon starts
    echo Binding Node %%i to the identity code...
    titan-edge bind --hash=%identity_code% https://api-test1.container1.titannet.io/api/v2/device/binding
    
    echo [SUCCESS] Node %%i is running on port !port! and bound to your account!
)

echo All nodes are running and bound successfully!
pause
