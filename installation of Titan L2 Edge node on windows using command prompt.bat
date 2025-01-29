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

REM Restart Command Prompt for PATH changes
echo Restarting Command Prompt...
start /b cmd /c C:\titan-edge\continue_installation.bat
exit

REM Create a new batch file for the remaining steps
echo @echo off > C:\titan-edge\continue_installation.bat
echo color %info_color% >> C:\titan-edge\continue_installation.bat
echo echo "Continuing installation..." >> C:\titan-edge\continue_installation.bat
echo cd C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64 >> C:\titan-edge\continue_installation.bat

REM Start and bind multiple nodes
for /L %%i in (1,1,%node_count%) do (
    echo echo Starting Titan Edge Node %%i... >> C:\titan-edge\continue_installation.bat
    echo start /b titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --repo C:\titan-edge\node_%%i >> C:\titan-edge\continue_installation.bat
    echo timeout /t 24 >> C:\titan-edge\continue_installation.bat
    echo set /p identity_code%%i="Enter your identity code (hash) for Node %%i: " >> C:\titan-edge\continue_installation.bat
    echo titan-edge bind --hash=%%identity_code%%i https://api-test1.container1.titannet.io/api/v2/device/binding >> C:\titan-edge\continue_installation.bat
)

echo echo All nodes are running and bound to your account! >> C:\titan-edge\continue_installation.bat
echo pause >> C:\titan-edge\continue_installation.bat
