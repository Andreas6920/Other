# Download, extract, and launch NirSoft's Wireless Network Watcher.
$link = 'https://www.nirsoft.net/utils/wnetwatcher-x64.zip'
$baseTemp = Join-Path $env:TEMP 'WNetWatcher_Temp'
$tempZip = Join-Path $baseTemp 'WNetWatcher.zip'

if (Test-Path $baseTemp) {
    Remove-Item -Path $baseTemp -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $baseTemp -Force | Out-Null

Write-Host "`t- Downloading file..." -ForegroundColor Green
try {
    (New-Object Net.WebClient).DownloadFile($link, $tempZip)
} catch {
    throw "Download failed: $($_.Exception.Message)"
}

Write-Host "`t- Extracting file..." -ForegroundColor Green
try {
    Expand-Archive -Path $tempZip -DestinationPath $baseTemp -Force
} catch {
    throw "Extraction failed: $($_.Exception.Message)"
}

$executable = Get-ChildItem -Path $baseTemp -Filter 'WNetWatcher*.exe' -File -Recurse | Select-Object -First 1
if (-not $executable) {
    throw 'Could not locate the WNetWatcher executable after extraction.'
}

Write-Host "`t- Starting NirSoft Wireless Network Watcher..." -ForegroundColor Green
Start-Process -FilePath $executable.FullName -WorkingDirectory $executable.DirectoryName

Write-Host "`t- Cleaning up temporary archive..." -ForegroundColor Green
Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
