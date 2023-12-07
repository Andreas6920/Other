#Install
    # Initialize installation
        Clear-Host
        Write-host "Installing.."
    # TLS upgrade
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # Disable Explorer first run
        $RegistryKey = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main"
        If (!(Test-Path $RegistryKey)) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
        $RegistryKey = Join-path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -ChildPath "DisableFirstRunCustomize"
        If (!(Test-Path $RegistryKey)) {Write-host "`t- Disable First Run Internet Explorer.."; Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 1}
    # Nuget
        #$ProgressPreference = "SilentlyContinue" # hide progressbar
        #$packageProviders = Get-PackageProvider | Select-Object name
        #if(!($packageProviders.name -contains "nuget")){Write-host "`t- Installing Nuget.."; Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
        #if($packageProviders -contains "nuget"){Write-host "`t- Importing Nuget..";Import-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
        #$ProgressPreference = "Continue" #unhide progressbar
    # Install functions
        $modulepath = $env:PSmodulepath.split(";")[1]
        $module = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/functions.psm1"
        $file = (split-path $module -Leaf)
        $filename = $file.Replace(".psm1","").Replace(".ps1","").Replace(".psd","")
        $filedestination = "$modulepath/$filename/$file"
        $filesubfolder = split-path $filedestination -Parent
        If (!(Test-Path $filesubfolder )) {New-Item -ItemType Directory -Path $filesubfolder -Force | Out-Null; Start-Sleep -S 1}
        # Download module
            (New-Object net.webclient).Downloadfile($module, $filedestination)
        # Install module
            if (Get-Module -ListAvailable -Name $filename){ Import-module -name $filename; Write-host "`t- Loading functions..";}
    # End
        Clear-Host





<#
#install applications

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

$config = 
'<?xml version="1.0" encoding="utf-8"?>
<packages>
<package id="googlechrome" />
<package id="vlc" />
<package id="7zip.install" />
<package id="adobereader" />
</packages>'

set-content $config -Path c:\packages.config

choco install c:\packages.config --yes --ignore-checksums -r

$regpath = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist"
$regData = 'cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx'
New-Item -Path $regpath -Force
New-ItemProperty -Path $regpath -Name 1 -Value $regData -PropertyType STRING -Force

#>