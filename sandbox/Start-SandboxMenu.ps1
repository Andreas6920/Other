$ErrorActionPreference = 'Stop'

$sandboxUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
if ($sandboxUser -ne 'WDAGUtilityAccount') {
    Write-Warning 'This menu is intended to run inside Windows Sandbox. It does not create an isolated Sandbox session.'
    return
}

$repoRawRoot = 'https://raw.githubusercontent.com/Andreas6920/Other/main'
$repoRoot = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { $null }
$menuHelperPath = if ($repoRoot) { Join-Path $repoRoot 'functions\Show-ArrowMenu.ps1' } else { $null }
if ($menuHelperPath -and (Test-Path -LiteralPath $menuHelperPath)) {
    . $menuHelperPath
} else {
    $menuHelper = Invoke-RestMethod "$repoRawRoot/functions/Show-ArrowMenu.ps1"
    . ([scriptblock]::Create([string]$menuHelper))
}

$appsPath = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'apps' } else { $null }
if ($appsPath -and (Test-Path -LiteralPath $appsPath)) {
    $appScripts = Get-ChildItem -LiteralPath $appsPath -Filter 'Install-*.ps1' -File | Sort-Object Name | ForEach-Object {
        [pscustomobject]@{ Name = $_.Name; ScriptPath = $_.FullName; DownloadUrl = $null }
    }
} else {
    $remoteApps = Invoke-RestMethod -Uri 'https://api.github.com/repos/Andreas6920/Other/contents/sandbox/apps?ref=main' -Headers @{ 'User-Agent' = 'Other-Sandbox-Menu' } -ErrorAction Stop
    $appScripts = @(
        foreach ($remoteApp in $remoteApps) {
            if ($remoteApp.type -eq 'file' -and $remoteApp.name -like 'Install-*.ps1') {
                [pscustomobject]@{
                    Name = [string]$remoteApp.name
                    ScriptPath = $null
                    DownloadUrl = [string]$remoteApp.download_url
                }
            }
        }
    )
}
if (-not $appScripts) { throw 'No Install-*.ps1 scripts were found in the Sandbox apps folder.' }

$menuItems = @(
    foreach ($appScript in $appScripts) {
        $scriptName = $appScript.Name
        $displayName = if ($scriptName -eq 'Install-WindowsStore.ps1') {
            'Install Windows Store'
        } else {
            [IO.Path]::GetFileNameWithoutExtension($scriptName) -creplace '^Install-', '' -creplace '(?<=[a-z0-9])(?=[A-Z])', ' '
        }
        @{
            Name = $displayName
            ScriptPath = $appScript.ScriptPath
            DownloadUrl = $appScript.DownloadUrl
            Executed = $false
        }
    }
    @{ Name = 'Return'; Action = {}; Executed = $false }
)

while ($true) {
    $selectionIndex = Show-ArrowMenu -Title 'Windows Sandbox Tools' -MenuItems $menuItems
    $selectedItem = $menuItems[$selectionIndex]
    if ($selectedItem.Name -eq 'Return') { break }

    Clear-Host
    Write-Host "Running $($selectedItem.Name)" -ForegroundColor DarkGray
    Write-Host '----------------------------------------'
    $tempScript = $null
    try {
        if ($selectedItem.DownloadUrl) {
            $tempScript = Join-Path ([IO.Path]::GetTempPath()) ("{0}-{1}.ps1" -f $selectedItem.Name.Replace(' ', ''), [guid]::NewGuid().ToString('N'))
            Invoke-WebRequest -Uri ([string]$selectedItem.DownloadUrl) -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
            & $tempScript
        } else {
            & $selectedItem.ScriptPath
        }
    }
    catch { Write-Host $_ -ForegroundColor Red }
    finally {
        if ($tempScript) { Remove-Item -LiteralPath $tempScript -Force -ErrorAction SilentlyContinue }
    }
    $selectedItem.Executed = $true

    Write-Host "`nPress any key to return to the menu..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}