# Prepare
    # Nuget
    $packageProviders = Get-PackageProvider | Select-Object name
    if(!($packageProviders.name -contains "nuget")){Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
    if($packageProviders -contains "nuget"){Import-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}

# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Disable Explorer first run
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

# install modules
    $modulepath = $env:PSmodulepath.split(";")[1]

    $modules = @(
    "https://raw.githubusercontent.com/Andreas6920/Other/main/modules/upload.psm1";
    "https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Invoke-AntihacK.psm1";
    "https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Invoke-Antibloat.psm1";
    #"https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Invoke-AppInstall.psm1";
    #"https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Add-Reg.ps1";
    #"https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Restart-Explorer.ps1";
    #"https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Start-Input.ps1";
    #"https://raw.githubusercontent.com/Andreas6920/Other/main/modules/Stop-Input.ps1";

                    )   
    
    foreach ($module in $modules) {
    $file = (split-path $module -Leaf)
    $filename = $file.Replace(".psm1","").Replace(".ps1","").Replace(".psd","")
    $filedestination = "$modulepath/$filename/$file"
    $filesubfolder = split-path $filedestination -Parent
    
    # Create folder, Download module
    If (!(Test-Path $filesubfolder )) {New-Item -ItemType Directory -Path $filesubfolder -Force | Out-Null}
    (New-Object net.webclient).Downloadfile($module, $filedestination)
    
    # Install module
    Import-module -name $filename

    }
    
    Invoke-Antibloat

    Invoke-Antibloat

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


