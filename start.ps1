# Prepare    
    # Nuget
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    $ProgressPreference = "SilentlyContinue" # hide progressbar
    $packageProviders = Get-PackageProvider | Select-Object name
    if(!($packageProviders.name -contains "nuget")){Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
    if($packageProviders -contains "nuget"){Import-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser | Out-Null}
    $ProgressPreference = "Continue" #unhide progressbar

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
    Write-Host "`t[17] `tRemove Bitdefender"

    "";
    Write-Host "`t[0] - Exit"
    Write-Host ""; Write-Host "";
    Write-Host "`tOption: " -f Yellow -nonewline; ;
    $option = Read-Host
    Switch ($option) { 
        0 {exit}
        1 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1"}
        2 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1"}
        3 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/office-template.txt"}
        4 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/download-windows.ps1"}
        5 {& ([ScriptBlock]::Create((Invoke-RestMethod https://massgrave.dev/get))) /Ohook }
        6 {& ([ScriptBlock]::Create((Invoke-RestMethod https://massgrave.dev/get))) /HWID}
        7 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/deploy-project/main/Deployment.ps1"}
        8 {Write-host "Upcomming..."}
        9 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/print_project/main/print-script.ps1"}
        10 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/action.ps1"}
        11 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/delete-traces.ps1"}
        12 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/zerotier.ps1"}
        13 {Start-Script -Link "https://www.nirsoft.net/utils/wnetwatcher-x64.zip" -ProgramName "WNetWatcher.exe"}
        14 {Start-Script -Link "https://sdi-tool.org/releases/SDI_R2309.zip" -ProgramName "SDI_x64_R2309.exe" -Location "Desktop"}
        15 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/ChromeDecrypter.ps1"}
        16 {netsh wlan show profiles * key=clear | select-string -pattern "SSID name|Key content"}
        12 {Start-Script -Link "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/bitremove.ps1"}

        
        Default {}}
}
while ($option -ne 15 )