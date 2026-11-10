$installScriptUrl = 'https://raw.githubusercontent.com/ThioJoe/Windows-Sandbox-Tools/refs/heads/main/Installer%20Scripts/Install-Winget.ps1'
$tempScript = Join-Path ([IO.Path]::GetTempPath()) ("Install-Winget-{0}.ps1" -f [guid]::NewGuid().ToString('N'))

try {
    Invoke-WebRequest -Uri $installScriptUrl -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
    & $tempScript
} finally {
    Remove-Item -LiteralPath $tempScript -Force -ErrorAction SilentlyContinue
}
