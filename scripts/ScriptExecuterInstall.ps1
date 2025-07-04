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

Do {
    Write-Host "`t - Skal scriptet testes? (y/n)" -NoNewline
    $Readhost = Read-Host " "
    
    switch ($ReadHost.ToLower()) {
        'y' {
            # Lav midlertidig script, eksekvere job
            $text = Get-Date -f "yyyyMMddHHmmss"         
            Write-Host "- Yes" -f Yellow
            Write-Host "- Afventer popup.." -f Yellow
            Set-Content -Value "msg * $text" -Path "C:\ProgramData\AM\RandomScript$text.ps1"
            Start-ScheduledTask -TaskName $Taskname
                
                # Afvent vindue
                while ($true) {
                $window = Get-Process | Where-Object { $_.MainWindowTitle -like "Message from*" }
                if ($window) {break}
                Start-Sleep -Seconds 1}
        }
        'n' {
            Write-Host "- No" -f Yellow
            break
        }
    }
} while ($ReadHost.ToLower() -notin @("y", "n"))

