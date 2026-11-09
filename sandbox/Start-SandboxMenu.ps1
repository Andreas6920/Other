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
    $appScripts = Invoke-RestMethod -Uri 'https://api.github.com/repos/Andreas6920/Other/contents/sandbox/apps?ref=main' -Headers @{ 'User-Agent' = 'Other-Sandbox-Menu' } |
        Where-Object { $_.type -eq 'file' -and $_.name -like 'Install-*.ps1' } |
        Sort-Object name |
        ForEach-Object { [pscustomobject]@{ Name = $_.name; ScriptPath = $null; DownloadUrl = $_.download_url } }
}
if (-not $appScripts) { throw 'No Install-*.ps1 scripts were found in the Sandbox apps folder.' }

$menuItems = @(
    foreach ($appScript in $appScripts) {
        $scriptPath = $appScript.ScriptPath
        $downloadUrl = $appScript.DownloadUrl
        $scriptName = $appScript.Name
        $displayName = [IO.Path]::GetFileNameWithoutExtension($scriptName) -replace '^Install-', '' -replace '([a-z0-9])([A-Z])', '$1 $2'
        if ($downloadUrl) {
            $action = {
                $tempScript = Join-Path ([IO.Path]::GetTempPath()) ("{0}-{1}.ps1" -f [IO.Path]::GetFileNameWithoutExtension($scriptName), [guid]::NewGuid().ToString('N'))
                try {
                    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
                    & $tempScript
                } finally {
                    Remove-Item -LiteralPath $tempScript -Force -ErrorAction SilentlyContinue
                }
            }.GetNewClosure()
        } else {
            $action = { & $scriptPath }.GetNewClosure()
        }
        @{
            Name = $displayName
            Action = $action
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
    try { & $selectedItem.Action }
    catch { Write-Host $_ -ForegroundColor Red }
    $selectedItem.Executed = $true

    Write-Host "`nPress any key to return to the menu..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}