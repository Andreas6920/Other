# Konfiguration
$Link = "https://www.nirsoft.net/utils/wnetwatcher-x64.zip"
$FileName = "wnetwatcher-x64.zip"
$TempPath = [System.IO.Path]::Combine($env:TEMP, "WNetWatcher")
$ZipPath = [System.IO.Path]::Combine($TempPath, $FileName)
$ExtractedFolder = $TempPath

# Ryd op hvis eksisterende mappe findes
if (Test-Path $ExtractedFolder) {Remove-Item -Path $ExtractedFolder -Recurse -Force | Out-Null}
New-Item -ItemType Directory -Path $ExtractedFolder | Out-Null

# Download af filen
Write-Host "`t- Downloading file..." -ForegroundColor Green
Invoke-RestMethod -Uri $Link -OutFile $ZipPath

# Ekstraktion af filen
Write-Host "`t- Extracting file using Expand-Archive..." -ForegroundColor Green
try {
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractedFolder -Force
    Write-Host "`t- Extraction successful to: $ExtractedFolder" -ForegroundColor Green} 
catch {
    Write-Host "`t- Extraction failed: $_" -ForegroundColor Red
    Exit}

# Find og kør WNetWatcher.exe
$ExePath = Join-Path -Path $ExtractedFolder -ChildPath "WNetWatcher.exe"
if (Test-Path $ExePath) {
    Write-Host "`t- Running WNetWatcher.exe..." -ForegroundColor Green
    Start-Process -FilePath $ExePath -NoNewWindow}
else {    Write-Host "`t- WNetWatcher.exe could not be found in $ExtractedFolder" -ForegroundColor Red  }

# Ryd op efter sig selv (Valgfrit - fjern # for at aktivere)
# Write-Host "`t- Cleaning up temporary files..." -ForegroundColor Green
# Remove-Item -Path $ZipPath -Force
