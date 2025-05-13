# Ensure admin rights
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {# Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

# Execution policy
    Set-ExecutionPolicy -Scope Process Unrestricted -Force

# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Disable Explorer first run
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

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
    Write-Host "`t[20] `tTron Script"

    "";
    Write-Host "`t[0] - Exit"
    Write-Host ""; Write-Host "";
    Write-Host "`tOption: " -f Yellow -nonewline; ;
    $option = Read-Host
    Switch ($option) { 
        0 {exit}
        1 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression}
        2 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1" | Invoke-Expression}
        3 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression; Install-App -Name Office}
        4 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/download-windows.ps1" | Invoke-Expression}
        5 {& ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook}
        6 {& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID}
        7 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-general.ps1" | Invoke-Expression}
        8 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-project.ps1" | Invoke-Expression}
        9 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/print_project/main/print-script.ps1" | Invoke-Expression}
        10 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/InstallActionOne.ps1" | Invoke-Expression}
        11 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/delete-traces.ps1" | Invoke-Expression}
        12 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/zerotier.ps1" | Invoke-Expression}
        13 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/WNetWatcher.ps1" | Invoke-Expression}
        14 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/SDI-Tool.ps1" | Invoke-Expression}
        15 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/ChromeDecrypter.ps1"  | Invoke-Expression}
        16 {netsh wlan show profiles * key=clear | select-string -pattern "SSID name|Key content"}
        17 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/bitremove.ps1" | Invoke-Expression}
        18 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/pcinfo.ps1" | Invoke-Expression}
        19 {iex "& { $(iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"}
        20 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/TronScript.ps1" | Invoke-Expression}       
        Default {}}
}
while ($option -ne 20 )