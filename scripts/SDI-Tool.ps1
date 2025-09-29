# Find URL on the newest version of SDI-Tool
$Url = "https://sdi-tool.org/download/"
$DownloadLink = (Invoke-WebRequest -Uri $url -UseBasicParsing).Links | Select-Object -ExpandProperty href | Where-Object { $_ -match "driveroff\.net" -and $_ -match "/drv/" } | Sort-Object -Unique[0]
$Version = (Split-Path $DownloadLink -Leaf).Replace("SDI_","Version: ").Replace(".7z","")
Write-Host "`t-  Searching for newest update:" -ForegroundColor Green; Start-Sleep -S 2
Write-Host "`t`t - `t$Version" -ForegroundColor Green

# Create folder
Write-Host "`t-  Creating folder.." -ForegroundColor Green;
$FileName = "TemporaryZipFile.7z"
$TempFolder = Join-Path -Path "$Env:ProgramData\SDI-Tool" -ChildPath $FileName
$ExtractedFolder = Split-Path $TempFolder -Parent
    # Ryd op hvis eksisterende mappe findes
    if (Test-Path $ExtractedFolder) {Write-Host "`t`t-  Folder already exists, removing old files:" -ForegroundColor Red;Remove-Item -Path $ExtractedFolder -Recurse -Force | Out-Null}
New-Item -ItemType Directory -Path $ExtractedFolder | Out-Null

# Downloading
Write-Host "`t-  Downloading file..." -ForegroundColor Green
(New-Object net.webclient).Downloadfile("$DownloadLink", "$TempFolder"); 

# File Extraction
    
    # Reliant on 7zip
    $process = "$env:ProgramFiles\7-Zip\7z.exe"

    # Requires 7zip - makes sure it's on the system
    if(-not(test-path $process)){
    $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
    $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
    Invoke-WebRequest $dlurl -OutFile $installerPath
    Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
    Remove-Item $installerPath} 

Write-Host "`t-  Extracting file" -ForegroundColor Green;
Start-Process $process -ArgumentList "x $TempFolder -o$ExtractedFolder" -Verb RunAs -Wait; Start-Sleep -S 3

# Execute program
    Write-Host "`t-  Copying shortcut to your desktop.." -ForegroundColor Green;
    $location = (Get-ChildItem $ExtractedFolder | Where-Object {$_.Name -match 64})
    $shortcut = join-path ([Environment]::GetFolderPath("Desktop")) -ChildPath $location.basename
    Copy-Item -Path $location.FullName -Destination ([Environment]::GetFolderPath("Desktop"))
Start-Process $shortcut

