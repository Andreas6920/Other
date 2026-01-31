$link = "https://flow.bitdefender.net/connect/2020/en_us/bitdefender_windows_6cc70ac0-d200-4ee4-a3c7-345f029c4d9d.exe"
$File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "BitdefenderSecurity_Installer.exe"
Write-Host "`t`t`t - Downloading $File"
(New-Object net.webclient).Downloadfile($link, $File)
Write-Host "`t`t`t - Starting $File"
Start-Process -FilePath $File