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