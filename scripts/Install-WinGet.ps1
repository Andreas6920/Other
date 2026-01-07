function Install-WinGet {

if (-not (Get-Command Winget -ErrorAction SilentlyContinue)) {
    # Setup Script
        $script ="Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Install-Script -Name winget-install -Force; winget-install"
        $scriptPath = Join-Path $env:TEMP "Install-Winget.ps1"
        Set-Content -Path $scriptPath -Encoding UTF8 -Value $script
    # Setup Execution
        $argList = "-NoProfile -ExecutionPolicy RemoteSigned -WindowStyle Minimized -File `"$scriptPath`""
    # Execute
        # If not admin - prompt for admin rights - then execute
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $argList -Wait; return}
        # If admin - execute
        Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Wait}

}
