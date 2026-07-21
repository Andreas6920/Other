
# Full context right click menuu
$registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (-not (Test-Path $registryPath)) {
    Write-Host "Creating key for classic context menu..." -ForegroundColor Yellow
    New-Item -Path $registryPath -Force | Out-Null
    Set-ItemProperty -Path $registryPath -Name "(Default)" -Value "" -Type String -Force | Out-Null
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2} 

# Checks if notepad is already installed
$nppBasePath = "$env:ProgramFiles\Notepad++"
$nppExePath = Join-Path $nppBasePath "notepad++.exe"

        # If not installed - install it
        if (-not (Test-Path $nppBasePath)) {
            Write-Host "Notepad++ Not found. Installing:" -ForegroundColor Yellow

            if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                Write-Host "    - Installing Chocolatey..." -ForegroundColor Yellow
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            }

            Write-Host "    - Installing Notepad++ wit Chocolatey..." -ForegroundColor Yellow
            choco install notepadplusplus -y
            Start-Sleep -Seconds 5} 
        
        # If installed - continue
        else { Write-Host "Notepad++ already exists on this system"}

# Create Shortcut on Desktop
if (Test-Path $nppExePath) {
    
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutDestination = Join-Path $desktopPath "Notepad++.lnk"

    $wshShell = New-Object -ComObject WScript.Shell
    $newShortcut = $wshShell.CreateShortcut($shortcutDestination)
    $newShortcut.TargetPath = $nppExePath
    $newShortcut.WorkingDirectory = $nppBasePath
    $newShortcut.IconLocation = "$nppExePath,0"
    $newShortcut.Save()}

# Set Notepad file association
    cmd /c assoc .txt=txtfile | Out-Null
    
    if (-not (Test-Path 'HKLM:\SOFTWARE\Classes\txtfile\shell\open\command')) {New-Item -Path 'HKLM:\SOFTWARE\Classes\txtfile\shell\open\command' -Force | Out-Null}
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Classes\txtfile\shell\open\command' -Name '(Default)' -Value ("`"{0}`" `"%1`"" -f $nppExePath) -Type ExpandString -Force