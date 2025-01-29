# Titan Edge Auto-Installation Script for Windows

## Overview
This script automates the installation of Titan Edge on Windows, handling dependencies, downloads, and setup with minimal user intervention.

## Installation Steps
### 1. Download and Run the Script

https://raw.githubusercontent.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/refs/heads/main/installation%20of%20Titan%20L2%20Edge%20node%20on%20windows%20using%20command%20prompt.bat



To install Titan Edge, download and execute the batch file using the following command in Command Prompt:


```cmd
curl -L -o install_titan.bat "https://raw.githubusercontent.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/refs/heads/main/installation%20of%20Titan%20L2%20Edge%20node%20on%20windows%20using%20command%20prompt.bat" && install_titan.bat
```

### 2. Manual Installation of Chocolatey and Curl (If Needed)
If Chocolatey and Curl are not installed automatically, you can manually install them with the following commands:

#### Install Chocolatey:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### Install Curl using Chocolatey:
```cmd
choco install curl -y
```

Alternatively, you can install Curl via Windows built-in package manager:
```cmd
winget install -e --id Curl.Curl
```

## Notes
- The script will restart the Command Prompt automatically after installing Chocolatey to apply system changes.
- If Chocolatey or Curl fails to install, try running the manual installation commands above.
- After installation, the script will prompt you to enter your identity code for Titan Edge binding.

## Troubleshooting
- If Titan Edge is not recognized, ensure the installation directory is added to the system PATH.
- Restart Command Prompt and re-run the script if any steps fail.
- Check your internet connection if downloads fail.

## Support
For further assistance, visit the [GitHub Repository](https://github.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/) or refer to the official Titan Edge documentation.

