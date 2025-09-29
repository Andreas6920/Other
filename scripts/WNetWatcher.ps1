# Konfiguration
$Link = "https://www.nirsoft.net/utils/wnetwatcher-x64.zip"
$FileName = "TemporaryZipFile.zip"
$TempFolder = Join-Path -Path "$Env:TMP\TemporaryFolder" -ChildPath $FileName
$ExtractedFolder = Split-Path $TempFolder -Parent

# Ryd op hvis eksisterende mappe findes
if (Test-Path $ExtractedFolder) { Remove-Item -Path $ExtractedFolder -Recurse -Force | Out-Null }
New-Item -ItemType Directory -Path $ExtractedFolder | Out-Null

# Download af filen
Write-Host "`t- Downloading file..." -ForegroundColor Green
Invoke-RestMethod -Uri $Link -OutFile $TempFolder

# Ekstraktion af filen
Write-Host "`t- Extracting file..." -ForegroundColor Green
try {
    Expand-Archive -Path $TempFolder -DestinationPath $ExtractedFolder -Force
    Write-Host "`t- Extraction successful to: $ExtractedFolder" -ForegroundColor Green
}
catch { Write-Host "`t-Udpakningen fejlede: $_" -ForegroundColor Red; Exit }

# Ryd op efter sig selv
Write-Host "`t- Cleaning up temporary files..." -ForegroundColor Green
Remove-Item -Path $TempFolder -Force
Write-Host "`t- Operation completed successfully!" -ForegroundColor Green

# Kørsel af det ønskede program/script
Write-Host "`t- Running extracted content..." -ForegroundColor Green
Start-Process  &.\WNetWatcher.exe

# Åben af udpakket mappe
# Start $ExtractedFolder