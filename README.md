

---

# Titan Edge Auto-Installer (Windows)  

## 1️⃣ Download the Installation File  

Download the installation batch file manually using the following link:  

🔗 **[Titan Edge Installer](https://github.com/psychead6969/Auto-install-Titan-L2-Edge-on-windows-/blob/main/installation%20of%20Titan%20L2%20Edge%20node%20on%20windows%20using%20command%20prompt.bat)**  

Save the file as `install.bat` in a convenient location.  

---

## 2️⃣ Install Chocolatey and Curl (If Not Installed)  

If Chocolatey and Curl are not installed, follow these steps:  

### Install Chocolatey:  
Run the following command in **Command Prompt (Run as Administrator)**:  
```cmd
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
```

### Install Curl:  
After installing Chocolatey, install Curl by running:  
```cmd
choco install curl -y
```

---

## ⚠️ Notes  

- **Run the batch file as Administrator** to ensure smooth installation.  
- If Chocolatey installation shows an error, **restart Command Prompt** and continue with Curl installation.  

---

