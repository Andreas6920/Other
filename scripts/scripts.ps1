# Check for admin rights
$admin_permissions_check = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$admin_permissions_check = $admin_permissions_check.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admin_permissions_check) {
do {
    Write-Host "`tScripts:" -f Yellow;"";
    Write-Host "`t[1] - Zerotier"
    "";
    Write-Host "`t[0] - Exit"
    Write-Host ""; Write-Host "";
    Write-Host "`tOption: " -f Yellow -nonewline; ;
    $option = Read-Host
    Switch ($option) { 
        0 {exit}
        1 {Clear-Host; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/zerotier.ps1'))}
        Default {} 
    }
        
}
while ($option -ne 100 )}