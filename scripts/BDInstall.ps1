
# Bitdefender Install
    $link = https://flow.bitdefender.net/connect/2020/en_us/bitdefender_windows_6cc70ac0-d200-4ee4-a3c7-345f029c4d9d.exe
    $File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Security.exe"
    (New-Object net.webclient).Downloadfile($link, $File)
    Start-Process -FilePath $File

# Bitdefender Uninstall


    
Write-Host "`t[1]`tCreate Folder"
Write-Host "`t[2]`tInstall Script"
Write-Host "`t[3]`tInstall Bitdefender"
Write-Host "`t[4]`tUinstall Bitdefender"

While($true) {
Write-Host "Menu:" -nonewline;
$Readhost = Read-Host " "
Switch ($ReadHost) {
    1 {mkdir "C:\ProgramData\am" -force}
    2 {Invoke-RestMethod "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuterInstall.ps1" | Invoke-Expression}
    3 { $link = https://flow.bitdefender.net/connect/2020/en_us/bitdefender_windows_6cc70ac0-d200-4ee4-a3c7-345f029c4d9d.exe
        $File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Security.exe"
        (New-Object net.webclient).Downloadfile($link, $File)
        Start-Process -FilePath $File}
    4{  $link = "https://www.bitdefender.com/files/KnowledgeBase/file/Bitdefender_2023_Uninstall_Tool.exe"
        $File = Join-path -Path ([Environment]::GetFolderPath("Desktop")) -Childpath "Bitdefender Uninstaller.exe"
        (New-Object net.webclient).Downloadfile($link, $File)
        Start-Process -FilePath $File}
 } }



 