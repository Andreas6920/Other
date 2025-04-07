# Prepare    

<#
# Nuget
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    $ProgressPreference = "SilentlyContinue" # hide progressbar
    $packageProviders = Get-PackageProvider | Select-Object name
    if(!($packageProviders.name -contains "nuget")){Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
    if($packageProviders -contains "nuget"){Import-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
    $ProgressPreference = "Continue" #unhide progressbar
#>

# Ensure admin rights
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {# Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Disable Explorer first run
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

    function Start-Script {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Link,
            [Parameter(Mandatory=$false)]
            [ValidateSet("Desktop", "Temp", "ProgramData", "Documents")]
            [string]$Location,
            [Parameter(Mandatory=$false)]
            [ValidateSet("PowerShell", "Zip", "Bat", "vbs")]
            [string]$FileType,
            [Parameter(Mandatory=$false)]
            [switch]$zip,
            [Parameter(Mandatory=$false)]
            [String]$ProgramName
            
            )
    
    Clear-Host
    
    $ParentDirectory = [Environment]::GetFolderPath("CommonApplicationData")
        if($Location){
            if($Location -eq "Desktop"){$ParentDirectory = [Environment]::GetFolderPath("Desktop")}
            if($Location -eq "Temp"){$ParentDirectory = $env:TMP}
            if($Location -eq "ProgramData"){$ParentDirectory = [Environment]::GetFolderPath("CommonApplicationData")}
            if($Location -eq "Documents"){$ParentDirectory = [Environment]::GetFolderPath("MyDocuments")} }
    
    if($Link -like "*.ps1"){
        $FileName = Split-Path $Link -Leaf
        $Script = Join-path -Path $ParentDirectory -ChildPath $FileName
        Invoke-RestMethod -Uri $Link -OutFile $Script
        & $Script
        
        }
    
    if($Link -like "*zip"){
        $FileName = Split-Path $Link -Leaf
        $FileLocationTemp = Join-Path -Path $env:TMP -ChildPath $FileName
        Invoke-RestMethod -Uri $Link -OutFile $FileLocationTemp
    
        $FileLocation = Join-path -Path $ParentDirectory -Childpath $FileName.Replace(".zip","")
        Expand-Archive -Path $FileLocationTemp -DestinationPath $FileLocation -Force
        
        $Script = (Get-ChildItem $FileLocation -Recurse | Where Name -Match $ProgramName ).FullName
        Start $script


    
    }}

# Menu starts
Clear-Host
do {
    Write-Host "`tMENU" -f Yellow;"";
    Write-Host "`t[1] `tModule: Windows-Optimizer"
    Write-Host "`t[2] `tModule: Windows-Server-Automator"
    Write-Host "`t[3] `tInstall Microsoft Office 2016 Professional Retail"
    Write-Host "`t[4] `tDownload Windows"
    Write-Host "`t[5] `tActivate Microsoft Office"
    Write-Host "`t[6] `tActivate Windows"
    Write-Host "`t[7] `tDeployment Script"
    Write-Host "`t[8] `tDeployment Script, Project"
    Write-Host "`t[9] `tPrinter Script, Project"
    Write-Host "`t[10] `tAction1, Project"
    Write-Host "`t[11] `tDelete digital footprint"
    Write-Host "`t[12] `tInstall Zero Tier"
    Write-Host "`t[13] `tNirsoft IP Scanner"
    Write-Host "`t[14] `tDriver Installer"
    Write-Host "`t[15] `tDump Chrome Passwords"
    Write-Host "`t[16] `tDump Wifi Passwords"
    Write-Host "`t[17] `tBitdefender Remover Tool"
    Write-Host "`t[18] `tPC info"
    Write-Host "`t[19] `tInstall SpotX"

    "";
    Write-Host "`t[0] - Exit"
    Write-Host ""; Write-Host "";
    Write-Host "`tOption: " -f Yellow -nonewline; ;
    $option = Read-Host
    Switch ($option) { 
        0 {exit}
        1 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression}
        2 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1" | Invoke-Expression}
        3 {<# Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/office-template.txt" | Invoke-Expression #>}
        4 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/download-windows.ps1" | Invoke-Expression}
        5 {& ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook}
        6 {& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID}
        7 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-general.ps1" | Invoke-Expression}
        8 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deploy-project-part1.ps1 | Invoke-Expression"}
        9 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/print_project/main/print-script.ps1" | Invoke-Expression}
        10 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/action.ps1" | Invoke-Expression}
        11 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/delete-traces.ps1" | Invoke-Expression}
        12 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/zerotier.ps1" | Invoke-Expression}
        13 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/WNetWatcher.ps1" | Invoke-Expression}
        14 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/SDI-Tool.ps1" | Invoke-Expression}
        15 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/ChromeDecrypter.ps1"}
        16 {netsh wlan show profiles * key=clear | select-string -pattern "SSID name|Key content"}
        17 {irm "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/bitremove.ps1" | iex}
        18 {irm "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/pcinfo.ps1" | iex}
        19 {iex "& { $(iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"}
        
        Default {}}
}
while ($option -ne 19 )