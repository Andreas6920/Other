$possiblePaths = @(
    "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe",
    "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
)

$foundPath = $null

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $foundPath = $path
        break
    }
}

if (-not $foundPath) {
    Write-Host "Brave blev ikke fundet på systemet. Starter installation..."
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Winget fundet. Installerer via Winget..." -ForegroundColor Green
        winget install --id Brave.Brave --exact --accept-package-agreements --accept-source-agreements --silent --force
        Start-Sleep -Seconds 5
    } else {
        Write-Host "Winget ikke fundet. Forsøger Chocolatey..." -ForegroundColor Yellow
        
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "Chocolatey ikke fundet. Installerer Chocolatey først..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        
        Write-Host "Installerer Brave via Chocolatey..."
        choco install brave -y --force
        Start-Sleep -Seconds 5
    }

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $foundPath = $path
            break
        }
    }
} else {
    Write-Host "Brave er installeret: $foundPath"
}

$shortcutPaths = @(
    "$env:PUBLIC\Desktop\Brave.lnk",
    "$env:USERPROFILE\Desktop\Brave.lnk"
)

foreach ($shortcut in $shortcutPaths) {
    if (Test-Path $shortcut) {
        Remove-Item -Path $shortcut -Force
        Write-Host "Slettede genvej: $shortcut"
    }
}

if ($foundPath) {
    Write-Host "Opretter genvej"

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $destinationPath = Join-Path $desktopPath "Brave TOR.lnk"

    $wshShell = New-Object -ComObject WScript.Shell
    $newShortcut = $wshShell.CreateShortcut($destinationPath)

    $newShortcut.TargetPath = $foundPath
    $newShortcut.Arguments = "--tor"
    $newShortcut.WorkingDirectory = Split-Path -Path $foundPath -Parent
    $newShortcut.IconLocation = "$foundPath,0"
    
    $newShortcut.Save()

    Write-Host "Genvej oprettet"
    Write-Host "Target: $($newShortcut.TargetPath)"
    Write-Host "Arguments: $($newShortcut.Arguments)"
    Write-Host "Scriptet er færdigt"
} else {
    Write-Host "Kunne ikke oprette genvej, da installationen tilsyneladende fejlede."
}