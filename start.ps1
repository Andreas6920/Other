
# Ensure admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""
    exit
}

# Execution policy
    Set-ExecutionPolicy -Scope Process Unrestricted -Force

# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Menu starts
function Show-ArrowMenu {
    param(
        [string]$Title = "Select an option:",
        [array]$MenuItems
    )

    $selectedIndex = 0
    try { [Console]::CursorVisible = $false } catch {}

    while ($true) {
        Clear-Host
        Write-Host $Title -ForegroundColor Gray
        Write-Host "Use Up/Down Arrow keys to navigate, Enter to select.`n" -ForegroundColor DarkGray

        for ($index = 0; $index -lt $MenuItems.Count; $index++) {
            $itemText = $MenuItems[$index].Name
            if ($index -eq $selectedIndex) {
                $label = ("> {0} " -f $itemText).PadRight(58)
                Write-Host $label -ForegroundColor Black -BackgroundColor Green
            } elseif ($MenuItems[$index].Executed) {
                Write-Host "  $itemText" -ForegroundColor DarkGray
            } else {
                Write-Host "  $itemText"
            }
        }

        $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($keyInfo.VirtualKeyCode) {
            38 { if ($selectedIndex -gt 0) { $selectedIndex-- } }
            40 { if ($selectedIndex -lt $MenuItems.Count - 1) { $selectedIndex++ } }
            13 { break }
        }

        if ($keyInfo.VirtualKeyCode -eq 13) { break }
    }

    try { [Console]::CursorVisible = $true } catch {}
    return $selectedIndex
}

$ScriptRoot = $PSScriptRoot
$menuItems = @(
    @{ Name = "Module: Windows-Optimizer"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Module: Windows-Server-Automator"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Install Microsoft Office 2016 Professional Retail"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression; Install-App -Name Office }; Executed = $false }
    @{ Name = "Download Windows"; Action = { & (Join-Path $ScriptRoot "scripts\Get-WindowsISO.ps1") }; Executed = $false }
    @{ Name = "Activate Microsoft Office"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-ActivatedOffice.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Activate Windows"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-ActivatedWindows.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Deployment Script"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-general.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Deployment Script, Project"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-project.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Printer Script, Project"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1" | Invoke-Expression; Install-Printer -Alle -NavisionPrinter }; Executed = $false }
    @{ Name = "Action1, Project"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Install-ActionOne.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Delete digital footprint"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Remove-Traces.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Install Zero Tier"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Install-ZeroTier.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Nirsoft IP Scanner"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Install-WNetWatcher.ps1" | Invoke-Expression; Install-WNetWatcher }; Executed = $false }
    @{ Name = "Driver Installer"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/SDI-Tool.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "WizTree"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Install-WizTree.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "PC info"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-PCInfo.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Install SpotX"; Action = { iex "& { $(iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify" }; Executed = $false }
    @{ Name = "Tron Script"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/TronScript.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Exit"; Action = {}; Executed = $false }
)

while ($true) {
    $selectionIndex = Show-ArrowMenu -Title "PowerShell Toolkit Runner" -MenuItems $menuItems
    $selectedItem = $menuItems[$selectionIndex]

    if ($selectedItem.Name -eq "Exit") { break }

    Clear-Host
    Write-Host "Executing selection: $($selectedItem.Name)" -ForegroundColor DarkGray
    Write-Host "----------------------------------------"
    & $selectedItem.Action
    $selectedItem.Executed = $true

    Write-Host "`nPress any key to return to the menu..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}