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
    
    
    write-host $ParentDirectory -ForegroundColor Yellow
    
    if($Link -like "*.ps1"){
        Write-host "This is a PowerShell File"
        $FileName = Split-Path $Link -Leaf
        $FileLocation = Join-path -Path $ParentDirectory -ChildPath $Filename
        Write-host $FileLocation -ForegroundColor Red}
    
    if($Link -like "*zip"){
        Write-host "This is a Zip File"
        $FileName = Split-Path $Link -Leaf
        Write-host $FileName
        $FileLocationTemp = Join-Path -Path $env:TMP -ChildPath $Filename
        Write-host "Step 1: download $Filelocation -ForegroundColor Red"
        Invoke-RestMethod -Uri $Link -OutFile $FileLocationTemp
    
        $FileLocation = Join-path -Path $ParentDirectory -Childpath $FileName.Replace(".zip","")
    
        Expand-Archive -Path $FileLocationTemp -DestinationPath $FileLocation -Force
        
        Script = (Get-ChildItem $FileLocation -Recurse | Where Name -Match $ProgramName ).FullName
    
    }}

# Menu starts
Clear-Host
do {
    Write-Host "`tMENU" -f Yellow;"";
    Write-Host "`t[1] - Module: Windows-Optimizer"
    Write-Host "`t[2] - Module: Windows-Server-Automator"
    Write-Host "`t[3] - Install Microsoft Office 2016 Professional Retail"
    Write-Host "`t[4] - Download Windows"
    Write-Host "`t[5] - Activate Microsoft Office"
    Write-Host "`t[6] - Activate Windows"
    Write-Host "`t[7] - Deployment Script"
    Write-Host "`t[8] - Deployment Script, Project"
    Write-Host "`t[9] - Printer Script, Project"
    Write-Host "`t[10] - Action1, Project"
    Write-Host "`t[11] - Delete digital footprint"
    Write-Host "`t[12] - Install Zero Tier"
    Write-Host "`t[13] - Nirsoft IP Scanner"
    Write-Host "`t[14] - Driver Installer"


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
        
        Default {}}
}
while ($option -ne 14 )