# Configuration
    $script ="Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Install-Script -Name winget-install -Force; winget-install"
    $scriptPath = Join-Path $env:TEMP "Install-Winget.ps1"
    $argList = "-NoProfile -ExecutionPolicy RemoteSigned -WindowStyle Minimized -File `"$scriptPath`""
# Setup Execution
    Set-Content -Path $scriptPath -Encoding UTF8 -Value $script
# Execute
    # If not admin - prompt for admin rights - then execute
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $argList -Wait; return}
    # If admin - execute
    Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Wait