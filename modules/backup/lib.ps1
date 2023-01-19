﻿# Install Librewolf settings
$link = "https://drive.google.com/uc?export=download&confirm=uc-download-link&id=1m8TZD7d9nc-Vkmv1PgyyXwUMuNgFrI3s"
$src = "$env:TMP\librewolfprofile.zip"
write-host "`t`t`t- Downloading to settings" -f Yellow
(New-Object net.webclient).Downloadfile($link, $src); Start-Sleep -s 2

write-host "`t`t`t- Building profile" -f Yellow
Start-Process "C:\Program Files\LibreWolf\librewolf.exe"
Start-Sleep -s 5
Stop-Process -name "librewolf"

$dst = [Environment]::GetFolderPath("ApplicationData")
$dst = Join-path $dst -ChildPath "librewolf\Profiles"
$dst = (gci $dst | ? name -match "-default?$").FullName
Start-Sleep -s 10
write-host "`t`t`t- Importing settings" -f Yellow
Expand-Archive -Path $src -DestinationPath $dst -Force
Start-Sleep -s 5