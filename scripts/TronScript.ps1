# Folder creation

$folder = "C:\exclude"
$ZipFile = Join-path $folder "Tron Script.zip"
New-Item -Path $folder -ItemType Directory -Force | Out-Null
Write-host "`t - Create folder"
Add-MpPreference -ExclusionPath $folder
Write-host "`t`t -Exclude folder"

# Downloading encrypted .zip file

$link = "https://drive.usercontent.google.com/download?id=1UeZJNeWSClUR940R0aw2b9mYrfyqKV3p&export=download&confirm=t&uuid=80f7f3b1-5f69-4c94-8219-02e9a7226e7b"
Write-host "`t - Downloading.."
(New-Object net.webclient).Downloadfile($link, $ZipFile )

# Install 7zip if not already installed

if((!(test-path "C:\Program Files (x86)\7-Zip\")) -and (!(test-path "C:\Program Files\7-Zip"))){ 
    Write-host "`t - 7-Zip not found" -f red
    $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
    $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
    Invoke-WebRequest $dlurl -OutFile $installerPath
    Write-host "`t`t - Installing 7-Zip"
    Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
    Remove-Item $installerPath}

# Extracting File with 7zip

Write-host "`t - Extracting Tron Script"

# Find the applicable version of your OS
    $path1 = "C:\Program Files (x86)\7-Zip\"
    if(test-path $path1 ){$SevenZip = join-path $path1 -ChildPath 7z.exe}
    $path2 = "C:\Program Files\7-Zip\"
    if(test-path $path2 ){$SevenZip = join-path $path2 -ChildPath 7z.exe}

# Extract with 7-Zip
    & "$SevenZip" x "`"$ZipFile`"" -o"`"$folder`"" -p"Pa55w.rd" -y | Out-Null
    Write-Host "`t`t - Zip file extracted"

# Copying files to desktop

Write-host "`t - Copying files to desktop"
$resourcesPath = Join-Path $folder -Childpath "resources"
$desktopPath = Join-Path $env:USERPROFILE "Desktop"
Copy-Item -Path $resourcesPath -Destination $desktopPath -Recurse -Force | Out-Null

$batchFilePath = Join-Path $folder -Childpath "tron.bat"
Copy-Item -Path $batchFilePath -Destination $desktopPath -Force | Out-Null

# Executing the batch file with parameters

Write-Host "`t - Executing Tron Script.."
$tronBatchFile = Join-Path $desktopPath "tron.bat"
Start-Sleep -Seconds 5
Start-Process -FilePath $tronBatchFile -ArgumentList "-a -e -sdb -r" -Wait
