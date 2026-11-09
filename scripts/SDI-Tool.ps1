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

# Install and load 7Zip4PowerShell without interactive NuGet prompts
if (-not (Get-Module -Name 7Zip4PowerShell)) {
    if (-not (Get-Module -ListAvailable -Name 7Zip4PowerShell)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

        if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force -Confirm:$false -ErrorAction Stop | Out-Null
        }

        Install-Module -Name 7Zip4PowerShell -Repository PSGallery -Scope CurrentUser -Force -Confirm:$false -ErrorAction Stop | Out-Null
    }

    Import-Module -Name 7Zip4PowerShell -ErrorAction Stop
}

Write-Host "`t-  Extracting file" -ForegroundColor Green;
Expand-7Zip -ArchiveFileName $TempFolder -TargetPath $ExtractedFolder -ErrorAction Stop

# Execute program
    Write-Host "`t-  Copying shortcut to your desktop.." -ForegroundColor Green;
    $location = (Get-ChildItem $ExtractedFolder | Where-Object {$_.Name -match 64})
    $shortcut = join-path ([Environment]::GetFolderPath("Desktop")) -ChildPath $location.basename
    Copy-Item -Path $location.FullName -Destination ([Environment]::GetFolderPath("Desktop"))
Start-Process $shortcut

