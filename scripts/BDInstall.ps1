
# Bitdefender Uninstall
Write-Host "`tENDPOINT INSTALLER" -ForegroundColor Yellow
Write-Host "`n"
Write-host "`tIs ScriptExecuter installed:`t" -NoNewline
if(test-path "C:\ProgramData\AM\Execute\ScriptExecuter.ps1"){Write-host "Yes" -ForegroundColor Green} else {Write-host "No" -ForegroundColor Red}
Write-Host "`n"
Write-Host "`t[1]`tInstall Script"
Write-Host "`t[2]`tInstall Bitdefender"
Write-Host "`t[3]`tUninstall Bitdefender"
Write-Host "`n`n"




While($true) {
Write-Host "`tSelect your number" -nonewline;
$Readhost = Read-Host " "
Switch ($ReadHost) {

    1 { $link = "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/resources/Install-ScriptExecuter.ps1"
        $File = Join-path -Path $Env:TMP -Childpath "Install-ScriptExecuter.ps1"
        (New-Object net.webclient).Downloadfile($link, $File)
        . $File; Install-ScriptExecuter
    }

    2 { $link = "https://flow.bitdefender.net/connect/2020/en_us/bitdefender_windows_6cc70ac0-d200-4ee4-a3c7-345f029c4d9d.exe"
        $File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Security.exe"
        Write-Host "`t`t`t - Downloading $File"
        (New-Object net.webclient).Downloadfile($link, $File)
        Write-Host "`t`t`t - Starting $File"
        Start-Process -FilePath $File
    }

    3{  $link = "https://www.googleapis.com/drive/v3/files/1f9SKBw-P7lcFMwqrfbrwKoxfqN3qtItS?alt=media&key=AIzaSyDCXkesTBEsIlxySObsDb2j5-44AsTtqXk"
        $File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Uninstaller.exe"
        Write-Host "`t`t`t - Downloading $File"
        (New-Object net.webclient).Downloadfile($link, $File)
        Write-Host "`t`t`t - Starting $File"
        Start-Process -FilePath $File}
 } }
 