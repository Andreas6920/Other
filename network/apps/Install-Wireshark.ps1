$ErrorActionPreference = 'Stop'

$possiblePaths = @(
    (Join-Path $env:ProgramFiles 'Wireshark\Wireshark.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Wireshark\Wireshark.exe')
)
$wiresharkPath = $possiblePaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $wiresharkPath) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host 'Installing Wireshark with Winget...' -ForegroundColor Green
        winget install --id WiresharkFoundation.Wireshark --exact --accept-package-agreements --accept-source-agreements --silent
        if ($LASTEXITCODE -ne 0) {
            throw "Winget failed to install Wireshark (exit code $LASTEXITCODE)."
        }
    } else {
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host 'Winget and Chocolatey were not found. Installing Chocolatey...' -ForegroundColor Yellow
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }

        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            throw 'Chocolatey installation completed, but the choco command is still unavailable.'
        }

        Write-Host 'Installing Wireshark with Chocolatey...' -ForegroundColor Green
        choco install wireshark -y
        if ($LASTEXITCODE -ne 0) {
            throw "Chocolatey failed to install Wireshark (exit code $LASTEXITCODE)."
        }
    }

    $wiresharkPath = $possiblePaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

if (-not $wiresharkPath) {
    throw 'Wireshark installation completed, but Wireshark.exe could not be found in the standard installation folders.'
}

$desktopPath = [Environment]::GetFolderPath('Desktop')
$desktopShortcut = Join-Path $desktopPath 'Wireshark.lnk'
if (-not (Test-Path -LiteralPath $desktopShortcut)) {
    $startMenuRoots = @(
        [Environment]::GetFolderPath('Programs'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique
    $existingShortcut = Get-ChildItem -LiteralPath $startMenuRoots -Filter '*Wireshark*.lnk' -File -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($existingShortcut) {
        Copy-Item -LiteralPath $existingShortcut.FullName -Destination $desktopShortcut
    } else {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($desktopShortcut)
        $shortcut.TargetPath = $wiresharkPath
        $shortcut.WorkingDirectory = Split-Path -Path $wiresharkPath -Parent
        $shortcut.IconLocation = "$wiresharkPath,0"
        $shortcut.Save()
    }

    Write-Host 'Created the Wireshark desktop shortcut.' -ForegroundColor Green
}

Write-Host 'Starting Wireshark...' -ForegroundColor Green
Start-Process -FilePath $wiresharkPath -WorkingDirectory (Split-Path -Path $wiresharkPath -Parent)
