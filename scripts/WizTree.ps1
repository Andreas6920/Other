# Konfiguration
    $PageUrl = "https://diskanalyzer.com/download"
    $TempPath = Join-Path $Env:TMP "WizTreePortable"
    $ZipPath = Join-Path $Env:TMP "wiztree.zip"

# Ryd op hvis mappen findes
    if (Test-Path $TempPath) { Remove-Item $TempPath -Recurse -Force | Out-Null }
    New-Item -ItemType Directory -Path $TempPath | Out-Null

# Hent HTML fra download-siden
    Write-Host "`t- Henter download-side..." -ForegroundColor Green
    $html = Invoke-WebRequest -Uri $PageUrl -UseBasicParsing

# Find downloadlink som slutter på _portable.zip
    $downloadLink = ($html.Links | Where-Object { $_.href -match "_portable\.zip$" }).href

# Hvis det er et relativt link, tilføj base URL
    if ($downloadLink -notmatch "^https?://") {
        $downloadLink = "https://diskanalyzer.com/$downloadLink"}

# Download ZIP-filen
    Write-Host "`t- Downloader: $downloadLink" -ForegroundColor Green
    (New-Object net.webclient).Downloadfile($downloadLink, $ZipPath )


# Udpak
    Write-Host "`t- Udpakker filen..." -ForegroundColor Green
    try {
        Expand-Archive -Path $ZipPath -DestinationPath $TempPath -Force
        Write-Host "`t- Ekstraktion lykkedes: $TempPath" -ForegroundColor Green
    } catch {
        Write-Host "`t- Fejl under udpakning: $_" -ForegroundColor Red
        exit
    }

# Find og start WizTree
    $ExePath = Get-ChildItem -Path $TempPath -Filter "WizTree64.exe"

    if ($ExePath) {
        Write-Host "`t- Starter $($ExePath.Name)..." -ForegroundColor Green
        Start-Process -FilePath $ExePath.FullName -NoNewWindow} 
    else {
        Write-Host "`t- WizTree EXE ikke fundet." -ForegroundColor Red
        Start-Process $TempPath}
