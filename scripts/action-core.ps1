﻿# Timestamps for actions
Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# Install Action1
if(!(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)){

Write-Host "$(Get-LogDate)`t- Opsætter Opdateringer:" -ForegroundColor Green
    
    # Download
    Write-Host "$(Get-LogDate)`t        - Henter ned" -ForegroundColor Yellow
    $link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
    $path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
    (New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null
    
    # Install
    Write-Host "$(Get-LogDate)`t        - Opsætter" -ForegroundColor Yellow -NoNewline
    msiexec /i $path /quiet
    
    # Confirming installation
    do{Start-Sleep -S 1; Write-Host "." -NoNewline -ForegroundColor Yellow}until(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)

Write-Host "$(Get-LogDate)`t- Opsætning gennemført. Genstart din PC snarest." -ForegroundColor Green}

# Verificér at servicen kører hvis den er allerede er eksisterende
$service = Get-Service -Name "Action1 Agent" -ErrorAction SilentlyContinue

if ($service) {
    if ($service.Status -ne 'Running') {
        Write-Host "$(Get-LogDate)`t        - Starter Action1 Agent service." -ForegroundColor Yellow
        Start-Service -Name "Action1 Agent"
        Write-Host "$(Get-LogDate)`t        - Action1 Agent service er nu startet." -ForegroundColor Green
    } else {
        Write-Host "$(Get-LogDate)`t        - Action1 Agent service kører allerede." -ForegroundColor Green
    }
}