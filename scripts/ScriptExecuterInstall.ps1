    # Variabler
    $Url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
    $ScriptPath = "C:\ProgramData\AM\Execute\ScriptExecuter.ps1"
    
    # Sikrer, at stien eksisterer
    Write-Host "`t - Opretter sti." -f Yellow;
    New-Item -ItemType Directory -Path (Split-Path -Path $ScriptPath) -Force | Out-Null
    
    # Downloader filen til destinationen med force
    Write-Host "`t - Downloader script." -f Yellow;
    Invoke-RestMethod -Uri $Url -OutFile $ScriptPath -UseBasicParsing
    
    # Setting Scheduled Task
    $Taskname = "Device Maintenance"
    $Taskaction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $ScriptPath"
    $Tasksettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit '02:00:00' -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -RunOnlyIfNetworkAvailable -StartWhenAvailable
    $Tasktrigger = New-ScheduledTaskTrigger -Daily -At 11:50
    $User = [Environment]::UserName
    Write-Host "`t - Planlæg opgave." -f Yellow;
    Register-ScheduledTask -TaskName $Taskname -Action $Taskaction -Settings $Tasksettings -Trigger $Tasktrigger -User $User -RunLevel Highest -Force | Out-Null

    Write-Host "`t`t- Opgavenavn: $Taskname" -f Yellow
    Write-Host "`t`t`t- Fuldført." -f Yellow

    While($True) {
    Do {
    Write-Host "`t -Skal scriptet testes? (y/n)" -nonewline;
    $Readhost = Read-Host " "
    Switch ($ReadHost) {
        Y { 
            $text = Get-Date -f "yyyyMMddHHmmss"         
            Write-host "- Yes" -f Yellow; Write-host "- Afvent popup" -f Yellow;
            Set-Content -value "msg * $text" -Path "C:\ProgramData\AM\RandomScript$text.ps1"; 
            Start-ScheduledTask -TaskName $Taskname}
        N {Write-Host "- NO" -f Yellow;}
     } } While($Readhost -notin "y", "n")}

    
