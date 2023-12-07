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




# functions
Function Restart-Explorer{
    <# When explorer restarts with the regular stop-process function, the active PowerShell loses focus,
     which means you'll have to click on the window in order to enter your input. here's the hotfix. #>
    taskkill /IM explorer.exe /F | Out-Null -ErrorAction SilentlyContinue
    start explorer | Out-Null
    $windowname = $Host.UI.RawUI.WindowTitle
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.Interaction]::AppActivate($windowname)}

Function Start-Menu {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$false)]
        [string]$Rename)

    $path = "C:\ProgramData\winoptimizer\$name.ps1"
    $file = Split-Path $path -Leaf
    $filehash = (Get-FileHash $path).Hash
    $reg_install = "HKLM:\Software\winoptimizer"
    $reghash = (get-ItemProperty -Path $reg_install -Name $file).$file

    
    if($filehash -eq $reghash){$color = "Gray"}
    elseif($filehash -ne $reghash){$color = "White"}
    if($reghash -eq "0"){$color = "White"}
    
    if($rename) {$name = $rename}
    Write-host "`t[$number] - $name" -ForegroundColor $color }

Function Add-Hash {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name)

    $path = "C:\ProgramData\winoptimizer\$name"
    $filehash = (Get-FileHash $path).Hash
    $reg_install = "HKLM:\Software\winoptimizer"
    Set-ItemProperty -Path $reg_install -Name $name -Type String -Value $filehash}

Function Start-Input{
    $code = @"
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
"@
    $userInput = Add-Type -MemberDefinition $code -Name UserInput -Namespace UserInput -PassThru
    $userInput::BlockInput($false)
    }

Function Stop-Input{
    $code = @"
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
"@
    $userInput = Add-Type -MemberDefinition $code -Name UserInput -Namespace UserInput -PassThru
    $userInput::BlockInput($true)
    }

# Create folder
Write-host "Loading" -nonewline
$rootpath = "C:\ProgramData\WinOptimizer"
if(!(test-path $rootpath)){Write-host "."; New-Item -ItemType Directory -Path $rootpath -Force | Out-Null}

# Download scripts
$scripts = @(
"https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_antibloat.ps1"
"https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_security.ps1"
"https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_settings.ps1"
)

Foreach ($script in $scripts) {



# Download missing files
$filename = split-path $script -Leaf
$filedestination = join-path $rootpath -Childpath $filename
(New-Object net.webclient).Downloadfile("$script", "$filedestination")

#Creating missing regpath
$reg_install = "HKLM:\Software\WinOptimizer"
If(!(Test-Path $reg_install)) {
    Write-host ".";
    New-Item -Path $reg_install -Force | Out-Null;}

#Creating missing regkeys
if (!((Get-Item -Path $reg_install).Property -match $filename)){
    Set-ItemProperty -Path $reg_install -Name $filename -Type String -Value 0}}



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