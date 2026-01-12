function Install-WNetWatcher {
# Configuration
$Link = "https://www.nirsoft.net/utils/wnetwatcher-x64.zip"
$FileName = "WNetWatcher.zip"
$BaseTemp = Join-Path $Env:TEMP "WNetWatcher_Temp"
$TempZip = Join-Path $BaseTemp $FileName
$ExtractedFolder = $BaseTemp

# if already exist, remove it first
if (Test-Path $BaseTemp) { Remove-Item -Path $BaseTemp -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $BaseTemp -Force | Out-Null

# Download file
Write-Host "`t- Downloading file..." -ForegroundColor Green
try {
    #Invoke-WebRequest -Uri $Link -OutFile $TempZip -UseBasicParsing
    (New-Object Net.WebClient).DownloadFile($url, $TempZip)} 
catch {
    Write-Host "`t- Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1}

# Extract file
Write-Host "`t- Extracting file..." -ForegroundColor Green
try {
    Expand-Archive -Path $TempZip -DestinationPath $ExtractedFolder -Force
    Write-Host "`t- Extraction successful to: $ExtractedFolder" -ForegroundColor Green} 
catch {
    Write-Host "`t- Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1}

# Find executable in extracted folder
$exe = Get-ChildItem -Path $ExtractedFolder -Filter "WNetWatcher*.exe" -File -Recurse | Select-Object -First 1
if (-not $exe) {
    Write-Host "`t- Could not locate WNetWatcher executable after extraction." -ForegroundColor Red
    Write-Host "`t- Contents of extracted folder:" -ForegroundColor Yellow
    Get-ChildItem -Path $ExtractedFolder -Recurse | Format-List FullName
    exit 1
}

# Execute program
Write-Host "`t- Running extracted content..." -ForegroundColor Green
try {
    Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName
} catch {
    Write-Host "`t- Failed to start process: $($_.Exception.Message)" -ForegroundColor Red
}

# Cleanup
Write-Host "`t- Cleaning up temporary files..." -ForegroundColor Green
Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue

Write-Host "`t- Operation completed successfully!" -ForegroundColor Green
}