# Prepare    
    # Nuget
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
        [Parameter(Mandatory=$false)]
        [string]$Link)

Clear-Host
$name = get-date -f "yyyyMMddHHmmss"
Invoke-RestMethod -UseBasicParsing $link -OutFile "$env:TMP\$name.ps1"; Import-Module "$env:TMP\$name.ps1"}

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

    }



        Default {}     
}
while ($option -ne 20 )