# Set the color for success and error messages
$success_color = "Green"
$error_color = "Red"
$info_color = "Cyan"

# Prompt for number of nodes
Write-Host "[INFO] How many nodes do you want to bind? (Max 5 nodes)" -ForegroundColor $info_color
$num_nodes = Read-Host "Enter a number (1-5)"

# Validate input
if ($num_nodes -lt 1 -or $num_nodes -gt 5) {
    Write-Host "[ERROR] Invalid input. Please enter a number between 1 and 5." -ForegroundColor $error_color
    exit
}

# Prompt for Identity Code
Write-Host "[INFO] Please enter your identity code to bind your node." -ForegroundColor $info_color
$identity_code = Read-Host "Enter your identity code (hash)"

# Set directories for each node
$base_dir = "C:\titan-edge"
$node_dirs = @()

for ($i = 1; $i -le $num_nodes; $i++) {
    $node_dirs += "${base_dir}-node$i"
}

# Step 1: Download the Titan Edge ZIP file once
Write-Host "[INFO] Downloading Titan Edge ZIP file..." -ForegroundColor $info_color
Invoke-WebRequest -Uri 'https://www.dropbox.com/scl/fi/82nsa6y23y6wc24yv1yve/titan-edge_v0.1.20_246b9dd_widnows_amd64.tar.zip?rlkey=6y2z6n0t8ms0o6odxgodue87p&dl=1' -OutFile 'C:\titan-edge.zip'

# Step 2: Extract the ZIP file
Write-Host "[INFO] Extracting Titan Edge ZIP file..." -ForegroundColor $info_color
Expand-Archive -Path 'C:\titan-edge.zip' -DestinationPath 'C:\titan-edge' -Force

# Step 3: Copy the extracted files to each node's directory
for ($i = 1; $i -le $num_nodes; $i++) {
    $node_dir = $node_dirs[$i - 1]
    Write-Host "[INFO] Copying extracted files to Node $i directory..." -ForegroundColor $info_color
    New-Item -Path $node_dir -ItemType Directory -Force
    Copy-Item -Path 'C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64\*' -Destination $node_dir -Recurse
}

# Step 4: Move goworkerd.dll to System32 for each node
for ($i = 1; $i -le $num_nodes; $i++) {
    $node_dir = $node_dirs[$i - 1]
    Write-Host "[INFO] Moving goworkerd.dll for Node $i..." -ForegroundColor $info_color
    Move-Item -Path "$node_dir\goworkerd.dll" -Destination "C:\Windows\System32" -Force
}

# Step 5: Add Titan Edge directory to PATH environment variable
Write-Host "[INFO] Adding Titan Edge to system PATH..." -ForegroundColor $info_color
[System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\titan-edge\titan-edge_v0.1.20_246b9dd_widnows_amd64", [System.EnvironmentVariableTarget]::Machine)

# Step 6: Start Titan Edge Daemon for each node with unique ports
$port_start = 5001

for ($i = 1; $i -le $num_nodes; $i++) {
    $node_dir = $node_dirs[$i - 1]
    $port = $port_start + ($i - 1)
    Write-Host "[INFO] Starting Titan Edge Daemon for Node $i on port $port..." -ForegroundColor $info_color
    
    Start-Process "cmd.exe" -ArgumentList "/c cd $node_dir && titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0 --port $port"
}

# Step 7: Add a delay to make sure all nodes are started before binding
Start-Sleep -Seconds 5

# Step 8: Bind Nodes to Account (LAST STEP)
for ($i = 1; $i -le $num_nodes; $i++) {
    Write-Host "[INFO] Binding Node $i..." -ForegroundColor $info_color
    Start-Process "cmd.exe" -ArgumentList "/c titan-edge bind --hash $identity_code https://api-test1.container1.titannet.io/api/v2/device/binding"
}

# Step 9: Success message
Write-Host "[SUCCESS] All nodes are running and bound to your account!" -ForegroundColor $success_color
