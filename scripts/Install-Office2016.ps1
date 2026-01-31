Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
"Microsoft.MicrosoftOfficeHub","Microsoft.Office.OneNote" | ForEach-Object { if (Get-AppxPackage | Where-Object Name -Like $_){Get-AppxPackage | Where-Object Name -Like $_ | Remove-AppxPackage; Start-Sleep -S 5}}
choco install microsoft-office-deployment --params="'/Product:ProfessionalRetail /64bit /ProofingToolLanguage:da-dk,en-us'"
