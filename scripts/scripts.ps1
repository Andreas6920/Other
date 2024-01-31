# Check for admin rights
$admin_permissions_check = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$admin_permissions_check = $admin_permissions_check.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admin_permissions_check) {
do {
    Write-Host "`tScripts:" -f Yellow;"";
    Write-Host "`t[1] - Zerotier"
    Write-Host "`t[2] - Delete traces"
    Write-Host "`t[3] - Action1"
    Write-Host "`t[4] - Download Windows"
    Write-Host "`t[5] - Microsoft Activator"
    Write-Host "`t[6] - Deployment Script"
    Write-Host "`t[7] - Download Microsoft Office 2016 Professional"
    "";
    Write-Host "`t[0] - Exit"
    Write-Host ""; Write-Host "";
    Write-Host "`tOption: " -f Yellow -nonewline; ;
    $option = Read-Host
    Switch ($option) { 
        
        0 {exit}
        1 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/zerotier.ps1'))}
        2 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/delete-traces.ps1'))}
        3 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/action.ps1'))}
        4 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/download-windows.ps1'))}
        5 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/microsoft-activator.ps1'))}
        6 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/deploy-project/main/Deployment.ps1'))}
        7 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/download-office.ps1'))}

        

        Default {} 
    }
        
}
while ($option -ne 100 )}