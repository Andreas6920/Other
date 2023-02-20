do {
    Write-Host "`tScripts:" -f Yellow;"";
    Write-Host "`t[1] - Zerotier"
    Write-Host "`t[2] - IP"
    "";
    Write-Host "`t[0] - Exit"
    Write-Host ""; Write-Host "";
    Write-Host "`tOption: " -f Yellow -nonewline; ;
    $option = Read-Host
    Switch ($option) { 
        0 {exit}
        1 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/zerotier.ps1'))}
        2 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/ip.ps1'))}
        Default {} 
    }
        
}
while ($option -ne 2 )