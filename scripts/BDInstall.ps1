
# Bitdefender Uninstall
Write-Host "`tENDPOINT INSTALLER:" -ForegroundColor Yellow
Write-Host "`n`n"
Write-Host "`t[1]`tInstall Script"
Write-Host "`t[2]`tInstall Bitdefender"
Write-Host "`t[3]`tUinstall Bitdefender"
Write-Host "`n`n"

While($true) {
Write-Host "`tSelect your number" -nonewline;
$Readhost = Read-Host " "
Switch ($ReadHost) {

    1 { 
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

    3{ $link = "https://www.bitdefender.com/files/KnowledgeBase/file/Bitdefender_2023_Uninstall_Tool.exe"
       $File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Uninstaller.exe"
       Write-Host "`t`t`t - Downloading $File"
       (New-Object net.webclient).Downloadfile($link, $File)
       Write-Host "`t`t`t - Starting $File"
       Start-Process -FilePath $File}
 } }


