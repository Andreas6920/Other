
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
    
$ScriptRoot = $PSScriptRoot
$RepoRawRoot = "https://raw.githubusercontent.com/Andreas6920/Other/main"
$MenuHelperPath = if ($ScriptRoot) { Join-Path $ScriptRoot "functions\Show-ArrowMenu.ps1" } else { $null }
if ($MenuHelperPath -and (Test-Path -LiteralPath $MenuHelperPath)) {
    . $MenuHelperPath
} else {
    $MenuHelper = Invoke-RestMethod "$RepoRawRoot/functions/Show-ArrowMenu.ps1"
    . ([scriptblock]::Create([string]$MenuHelper))
}
$menuItems = @(
    @{ Name = "Windows Sandbox tools"; Action = {
        $sandboxMenuPath = if ($ScriptRoot) { Join-Path $ScriptRoot "sandbox\Start-SandboxMenu.ps1" } else { $null }
        if ($sandboxMenuPath -and (Test-Path -LiteralPath $sandboxMenuPath)) {
            & $sandboxMenuPath
        } else {
            $tempMenuScript = Join-Path ([IO.Path]::GetTempPath()) ("Start-SandboxMenu-{0}.ps1" -f [guid]::NewGuid().ToString('N'))
            try {
                Invoke-WebRequest -Uri "$RepoRawRoot/sandbox/Start-SandboxMenu.ps1" -OutFile $tempMenuScript -UseBasicParsing -ErrorAction Stop
                & $tempMenuScript
            } finally {
                Remove-Item -LiteralPath $tempMenuScript -Force -ErrorAction SilentlyContinue
            }
        }
    }; Executed = $false; SkipPause = $true }
    @{ Name = "Module: Windows-Optimizer"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Module: Windows-Server-Automator"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Install Microsoft Office 2016 Professional Retail"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression; Install-App -Name Office }; Executed = $false }
    @{ Name = "Download Windows"; Action = {
        $isoScriptPath = if ($ScriptRoot) { Join-Path $ScriptRoot "scripts\Get-WindowsISO.ps1" } else { $null }
        if ($isoScriptPath -and (Test-Path -LiteralPath $isoScriptPath)) {
            & $isoScriptPath
        } else {
            Invoke-Expression (Invoke-RestMethod "$RepoRawRoot/scripts/Get-WindowsISO.ps1")
        }
    }; Executed = $false }
    @{ Name = "Activate Microsoft Office"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-ActivatedOffice.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Activate Windows"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-ActivatedWindows.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Deployment Script"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-general.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Deployment Script, Project"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deployment-project.ps1" | Invoke-Expression }; Executed = $false }
    @{ Name = "Printer Script, Project"; Action = { Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1" | Invoke-Expression; Install-Printer -Alle -NavisionPrinter }; Executed = $false }
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

    if (-not $selectedItem.SkipPause) {
        Write-Host "`nPress any key to return to the menu..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}