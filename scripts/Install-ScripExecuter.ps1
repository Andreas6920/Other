Function Install-ScripExecuter {

Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

    # Variables
        $Url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
        $ScriptPath = "C:\ProgramData\AM\Execute\ScriptExecuter.ps1"

    # Does path exists
        Write-Host "$(Get-LogDate)`t        - Creating path." -f Yellow;
        New-Item -ItemType Directory -Path (Split-Path -Path $ScriptPath) -Force | Out-Null

    # Downloading file
        Write-Host "$(Get-LogDate)`t        - Downloading Script." -f Yellow;
        Invoke-RestMethod -Uri $Url -OutFile $ScriptPath -UseBasicParsing

    # Scheduleding Task
        Write-Host "$(Get-LogDate)`t        - Setting Execution Task." -f Yellow;
        $Taskname   = "Device Maintenance"
        $Taskaction = New-ScheduledTaskAction `
            -Execute "PowerShell.exe" `
            -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

        $Tasksettings = New-ScheduledTaskSettingsSet `
            -ExecutionTimeLimit '02:00:00' `
            -DontStopIfGoingOnBatteries `
            -DontStopOnIdleEnd `
            -RunOnlyIfNetworkAvailable `
            -StartWhenAvailable

        $Tasktrigger = New-ScheduledTaskTrigger -Daily -At 11:50
        $User = [Environment]::UserName

        
        Register-ScheduledTask `
            -TaskName $Taskname `
            -Action $Taskaction `
            -Settings $Tasksettings `
            -Trigger $Tasktrigger `
            -User $User `
            -RunLevel Highest `
            -Force | Out-Null
        
    # Verifikation
            Write-Host "$(Get-LogDate)`t        - Starting task." -f Yellow;
            $TestScript = "C:\ProgramData\AM\ScriptExecuterInstallationVerification.ps1"
            Set-Content -Value "msg * 'ScripExecuter Works!'" -Path $TestScript -Encoding UTF8
            Start-ScheduledTask -TaskName $Taskname

            Write-Host "$(Get-LogDate)`t        - Awaiting apporval." -f Yellow;
            while ($true) {
                $window = Get-Process | Where-Object { $_.MainWindowTitle -like "Message from*" }
                if ($window) { break }
                Start-Sleep -Seconds 1
            }
            Write-Host "$(Get-LogDate)`t        - Verification succeeded." -f Yellow;
        
    }
