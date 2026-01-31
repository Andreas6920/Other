# Configuration
$Link = "https://www.googleapis.com/drive/v3/files/1f9SKBw-P7lcFMwqrfbrwKoxfqN3qtItS?alt=media&key=AIzaSyDCXkesTBEsIlxySObsDb2j5-44AsTtqXk"
$FileName = "Bitdefender Uninstaller.exe"

# Download and Execute
$FolderPath = Join-path -Path $Env:TMP -ChildPath ($FileName -replace "\..*", "")
$Filepath = Join-Path $FolderPath -ChildPath $FileName
Write-Host "`t`t`t - Creating Folder: $FolderPath"
New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
Write-Host "`t`t`t - Downloading File: $FileName"
(New-Object net.webclient).Downloadfile($link, $Filepath )
Write-Host "`t`t`t - Executing File: $FilePath"
Start-Process -FilePath $FilePath