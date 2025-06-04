
$folder = "C:\Security"
$File = Join-path $folder "Bitdefender Security.exe"
$link = "https://flow.bitdefender.net/connect/2020/en_us/bitdefender_windows_b92395d4-8743-4c00-83a9-af1365f7fbb4.exe"
Write-host "`t - Downloading.."
(New-Object net.webclient).Downloadfile($link, $File )


Start-Process -FilePath $File -ArgumentList "/S" -Wait





$folder = "C:\Security"
$File = Join-path $folder "Bitdefender Security.exe"
$link = "https://download.bitdefender.com/windows/desktop/connect/cl/2023/all/bitdefender_ts_27_64b.exe"
Write-host "`t - Downloading.."
(New-Object net.webclient).Downloadfile($link, $File )
 Start-Process -FilePath $File -ArgumentList "/bdparams /silent silent" -Wait



$folder = "C:\Security"
$File = Join-path $folder "Bitdefender Security.exe"
$link = "https://download.bitdefender.com/windows/desktop/connect/cl/2023/all/bitdefender_ts_27_64b.exe"
Write-host "`t - Downloading.."
(New-Object net.webclient).Downloadfile($link, $File )
 Start-Process -FilePath $File -ArgumentList "/S" -Wait