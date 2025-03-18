#Install apps
function Install-Application {
    param (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [string]$App,
    [Parameter(Mandatory=$false)]
    [switch]$Ignorehash)

    # Check for Chocolatey
    $chocodir = [Environment]::GetFolderPath("CommonApplicationData")
    $chocodir = Join-Path $chocodir -ChildPath "Chocolatey"
    If (!(Test-Path $chocodir)) {
    Clear-Host; Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
    Clear-Host; Write-host "`tInstalling apps:" -f green;}
    
    # Windows notification
    Add-Type -AssemblyName System.Windows.Forms
    $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balmsg.BalloonTipText = 'Installing ' + $Name 
    $balmsg.BalloonTipTitle = "Winoptimizer"
    $balmsg.Visible = $true
    $balmsg.ShowBalloonTip(20000)

    # Install
    if ($Ignorehash){$app = $app + "--ignore checksum"}
    Write-host "`t    - Installing: $Name" -f Yellow
    
    choco install $App -y | Out-Null}
        
    Write-host "`tInstalling apps:" -f green
    Install-Application -Name "PowerShell Core" -App "powershell-core"
    Install-Application -Name "Windows Terminal" -App "microsoft-windows-terminal"
    Install-Application -Name "Libre Wolf" -App "librewolf"
    write-host "`t`t`t- Downloading to settings" -f Yellow
    $link = "https://drive.google.com/uc?export=download&confirm=uc-download-link&id=1m8TZD7d9nc-Vkmv1PgyyXwUMuNgFrI3s"
    $src = "$env:TMP\librewolfprofile.zip"
    (New-Object net.webclient).Downloadfile($link, $src); Start-Sleep -s 2
    write-host "`t`t`t- Building profile" -f Yellow
    Start-Process "C:\Program Files\LibreWolf\librewolf.exe"
    Start-Sleep -s 5
    Stop-Process -name "librewolf"; Start-Sleep -s 3
    $dst = (Get-ChildItem -Directory -Depth 0 -path "C:\Users\Username\AppData\Roaming\librewolf\Profiles" | Where name -like "*-default").FullName
    Expand-Archive -Path $src -DestinationPath $dst -Force
    Install-Application -Name "ShareX" -App "sharex"
    Stop-Process -Name sharex
    write-host "`t`t`t- Importing settings" -f Yellow
    $link = "https://drive.google.com/uc?export=download&confirm=uc-download-link&id=13xOvgOXgOkdLuGG-JqQiVQla6Gz6Sria"
    $src = "$env:TMP\sharexprofile.zip"
    write-host "`t`t`t- Downloading to settings" -f Yellow
    (New-Object net.webclient).Downloadfile($link, $src);
    $dst = [Environment]::GetFolderPath("MyDocuments")
    $dst = Join-path $dst -ChildPath "Sharex"
    Expand-Archive -Path $src -DestinationPath $dst -Force
    $sys = [Environment]::GetFolderPath("ProgramFilesX86"), [Environment]::GetFolderPath("ProgramFiles")
    Start-Process (Get-ChildItem $sys -Depth 2 | Where {$_.name -eq "ShareX.exe"}).FullName
    Install-Application -Name "Brave" -App "brave"
    Install-Application -Name "Google Chrome" -App "googlechrome" -ignorehash
    Install-Application -Name "7-Zip" -App "7zip"
    Install-Application -Name "Notepad++" -App "notepadplusplus"
    Install-Application -Name "PuTTY" -App "putty"
    Install-Application -Name "VLC" -App "vlc"
    Install-Application -Name "Visual Studio Code" -App "vscode"
    Install-Application -Name "Gimp" -App "gimp"
    Install-Application -Name "Spotify" -App "spotify"
    Install-Application -Name "Github Desktop" -App "github-desktop"
    
#>