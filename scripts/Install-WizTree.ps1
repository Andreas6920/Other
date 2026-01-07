# Konfiguration
$PageUrl  = "https://diskanalyzer.com/download"
$BaseUri  = [Uri]"https://diskanalyzer.com/"
$TempPath = Join-Path $env:TEMP "WizTreePortable"
$ZipPath  = Join-Path $TempPath "wiztree.zip"

# Ryd op hvis mappen findes
if (Test-Path $TempPath) { Remove-Item $TempPath -Recurse -Force | Out-Null }
New-Item -ItemType Directory -Path $TempPath | Out-Null

# Hent HTML fra download-siden
Write-Host "`t- Henter download-side..." -ForegroundColor Green
# UseBasicParsing er ignoreret i PowerShell 7+, men skader ikke i Windows PowerShell 5.1
$html = Invoke-WebRequest -Uri $PageUrl -UseBasicParsing

# Forsøg først via .Links, fald tilbage til regex på .Content hvis nødvendigt
$relative = ($html.Links | Where-Object { $_.href -match "_portable\.zip$" } | Select-Object -First 1).href
if (-not $relative) {
    # Fald tilbage til regex på HTML-indhold
    $match = [regex]::Match($html.Content, 'href="(?<u>[^"]*_portable\.zip)"', 'IgnoreCase')
    if ($match.Success) { $relative = $match.Groups['u'].Value }
}

if (-not $relative) {
    Write-Error "Kunne ikke finde et link der slutter på _portable.zip på $PageUrl"
    exit 1
}

# Kombinér base og relativ URL korrekt, uanset om der er leading slash eller ej
$downloadUri = [Uri]::new($BaseUri, $relative)

Write-Host "`t- Downloader: $downloadUri" -ForegroundColor Green

# Download ZIP-filen
# Brug Invoke-WebRequest her, da den har stabil -OutFile på tværs af PS-versioner
Invoke-WebRequest -Uri $downloadUri -OutFile $ZipPath -UseBasicParsing

# Udpak
Write-Host "`t- Udpakker filen..." -ForegroundColor Green
try {
    Expand-Archive -Path $ZipPath -DestinationPath $TempPath -Force
    Write-Host "`t- Ekstraktion lykkedes: $TempPath" -ForegroundColor Green
} catch {
    Write-Host "`t- Fejl under udpakning: $_" -ForegroundColor Red
    exit 1
}

# Find og start WizTree.exe
$ExePath = Get-ChildItem -Path $TempPath -Filter "WizTree*.exe" -Recurse |
           Where-Object { $_.Name -match "^WizTree.*\.exe$" } |
           Select-Object -First 1

if ($ExePath) {
    Write-Host "`t- Starter $($ExePath.Name)..." -ForegroundColor Green
    Start-Process -FilePath $ExePath.FullName
} else {
    Write-Host "`t- WizTree EXE ikke fundet." -ForegroundColor Red
}
