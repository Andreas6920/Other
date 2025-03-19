
    # Opsætning
    $basepath = "C:/Script"
    $executepath = "$basepath/Execute"
    $executefile = "$executepath/ScriptExecuter.ps1"
    $archivepath = "$basepath/Archive"
    $logpath = "$basepath/Logs"
    $scripturl = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
    
    # Kontrollere at mapperne eksistere
    $folders = @($basepath, $executepath, $archivepath, $logpath)
    foreach ($folder in $folders) {if (!(Test-Path $folder)) {New-Item -ItemType Directory -Path $folder -Force | Out-Null; Write-Host "- Opretter: $folder" -f Yellow}}

    # Download Script
    Write-Host "- Downloading Script" -f Yellow;
    irm $scripturl -OutFile $executefile

    # Setting Scheduled Task
    $Taskname = "Action1 Script Automation 1.0"
    $Taskaction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -w hidden -file $executefile"
    $Tasksettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit '03:00:00' -AllowStartIfOnBatteries -RunOnlyIfNetworkAvailable -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
    $Tasktrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek 'Monday','Tuesday','Wednesday','Thursday','Friday' -At 11:50
    $User = [Environment]::UserName
    Write-Host "- Planlæg opgave." -f Yellow;
    Register-ScheduledTask -TaskName $Taskname -Action $Taskaction -Settings $Tasksettings -Trigger $Tasktrigger -User $User -RunLevel Highest -Force | Out-Null

    Write-Host "- Opgavenavn: $Taskname" -f Yellow;
    Write-Host "- Fuldført." -f Yellow;

    Do {
    Write-Host "Skal scriptet testes? (y/n)" -nonewline;
    $Readhost = Read-Host " "
    Switch ($ReadHost) {
        Y {Write-host "- Yes" -f Yellow; Write-host "- Afvent popup" -f Yellow; Set-Content -value "msg * test" -Path "$basepath/test.ps1"; Start-ScheduledTask -TaskName "Action1 Script Automation 1.0"}
        N {Write-Host "- NO" -f Yellow;}
     } } While($Readhost -notin "y", "n")

    
