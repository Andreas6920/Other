    # Variabler
    $Url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
    $ScriptPath = "C:\ProgramData\Script\Execute\ScriptExecuter.ps1"
    
    # Sikrer, at stien eksisterer
    New-Item -ItemType Directory -Path (Split-Path -Path $ScriptPath) -Force | Out-Null
    
    # Downloader filen til destinationen med force
    Invoke-WebRequest -Uri $Url -OutFile $ScriptPath -UseBasicParsing
    
    # Setting Scheduled Task
    $Taskname = "Device Maintenance"
    $Taskaction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $ScriptPath"
    $Tasksettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit '01:30:00' -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -RunOnlyIfNetworkAvailable -StartWhenAvailable
    $Tasktrigger = New-ScheduledTaskTrigger -Daily -At 08:00 -RandomDelay (New-TimeSpan -Minutes 5)
    $User = [Environment]::UserName
    Write-Host "- Planlæg opgave." -f Yellow;
    Register-ScheduledTask -TaskName $Taskname -Action $Taskaction -Settings $Tasksettings -Trigger $Tasktrigger -User $User -RunLevel Highest -Force | Out-Null

    Write-Host "- Opgavenavn: $Taskname" -f Yellow;
    Write-Host "- Fuldført." -f Yellow;

    Start C:\ProgramData\Script 

    While($True) {
    Do {
    Write-Host "Skal scriptet testes? (y/n)" -nonewline;
    $Readhost = Read-Host " "
    Switch ($ReadHost) {
        Y { 
            $text = Get-Date -f "yyyyMMddHHmmss"
            
            Write-host "- Yes" -f Yellow; Write-host "- Afvent popup" -f Yellow;
            Set-Content -value "msg * $text" -Path "C:\ProgramData\Script\RandomScript$text.ps1"; 
            Start-ScheduledTask -TaskName $Taskname}
        N {Write-Host "- NO" -f Yellow;}
     } } While($Readhost -notin "y", "n")}

    
