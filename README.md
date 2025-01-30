# Titan L2 Edge Installation Guide

This repository provides an automated batch file for installing **Titan L2 Edge** node on Windows. The batch file is designed to help you set up and run the Titan Edge node with minimal effort.

## Features

- Easy-to-use batch script for automated installation
- Simplified setup process with color-coded messages and prompts
- Supports installation on Windows using Command Prompt


## Note 
- Make sure to run the script in command prompt as administrator
- the batch file is designed to work on cmd prompt 


## Installation

To install the Titan L2 Edge node, follow these steps:

1. Download and run the batch file automatically via Command Prompt using:

    ```cmd
    powershell -Command "& {Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/main/installation%20of%20Titan%20L2%20Edge%20node%20on%20windows%20using%20command%20prompt.bat' -OutFile '%TEMP%\install.bat'; Start-Process -FilePath '%TEMP%\install.bat' -Wait}"
    ```

2. Follow the on-screen prompts to complete the installation.

## Usage

Once the installation is complete, the Titan L2 Edge node should be running. The batch file will guide you through any necessary steps.


```cmd
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/refs/heads/main/Installation%20of%201%7E5%20nodes%20on%20windows.sh' -OutFile 'C:\Windows\Temp\Installation_of_1~5_nodes_on_windows.sh'; Start-Process 'C:\Program Files\Git\git-bash.exe' -ArgumentList '--login -i', 'C:\Windows\Temp\Installation_of_1~5_nodes_on_windows.sh' -Verb RunAs"
