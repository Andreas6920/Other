

    $url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
    $outputPath = "C:\ProgramData\Script\Execute\ScriptExecuter.ps1"
    
    # Sikrer, at stien eksisterer
    New-Item -ItemType Directory -Path (Split-Path -Path $outputPath) -Force | Out-Null
    
    # Downloader filen til destinationen med force
    Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
    
    # Setting Scheduled Task
    $Taskname = "Action1 Script Automation 1.0"
    $Taskaction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $outputPath"
    $Tasksettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit '01:30:00' -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
    $Tasktrigger = New-ScheduledTaskTrigger -AtLogOn
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

    
