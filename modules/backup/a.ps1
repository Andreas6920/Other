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
    Install-Application -Name "7-Zip" -App "7zip"
    Install-Application -Name "VLC" -App "vlc"
    Install-Application -Name "ShareX" -App "sharex"
        Stop-Process -Name sharex
        iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/modules/sha.ps1'))
    Install-Application -Name "Libre Wolf" -App "librewolf"
        iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/modules/lib.ps1'))
    Install-Application -Name "Brave" -App "brave"
    Install-Application -Name "Google Chrome" -App "googlechrome" -ignorehash
    Install-Application -Name "Notepad++" -App "notepadplusplus"
    Install-Application -Name "PuTTY" -App "putty"
    Install-Application -Name "Visual Studio Code" -App "vscode"
    Install-Application -Name "Gimp" -App "gimp"
    Install-Application -Name "Spotify" -App "spotify"
    Install-Application -Name "Github Desktop" -App "github-desktop"


