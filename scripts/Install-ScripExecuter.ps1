Function Install-ScripExecuter {
    [CmdletBinding()]
    param (
        [switch]$Verify
    )

    # Variables
        $Url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
        $ScriptPath = "C:\ProgramData\AM\Execute\ScriptExecuter.ps1"

    # Does path exists
        Write-Host "`t - Creating path." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path (Split-Path -Path $ScriptPath) -Force | Out-Null

    # Downloading file
        Write-Host "`t - Downloading script." -ForegroundColor Yellow
        Invoke-RestMethod -Uri $Url -OutFile $ScriptPath -UseBasicParsing

    # Scheduleding Task
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

        Write-Host "`t - Setting task." -ForegroundColor Yellow
        Register-ScheduledTask `
            -TaskName $Taskname `
            -Action $Taskaction `
            -Settings $Tasksettings `
            -Trigger $Tasktrigger `
            -User $User `
            -RunLevel Highest `
            -Force | Out-Null

        Write-Host "`t`t- Taskname: $Taskname" -ForegroundColor Yellow
        Write-Host "`t`t`t- Completed." -ForegroundColor Yellow

    # Verifikation
        if ($Verify) {
            Write-Host "`t - Starting verification." -ForegroundColor Yellow

            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            $TestScript = "C:\ProgramData\AM\RandomScript$timestamp.ps1"

            Set-Content -Value "msg * $timestamp" -Path $TestScript -Encoding UTF8

            Write-Host "`t - Starting scheduled task." -ForegroundColor Yellow
            Start-ScheduledTask -TaskName $Taskname

            Write-Host "`t - Awaiting popup." -ForegroundColor Yellow
            while ($true) {
                $window = Get-Process | Where-Object { $_.MainWindowTitle -like "Message from*" }
                if ($window) { break }
                Start-Sleep -Seconds 1
            }

            Write-Host "`t - Verifikation gennemført." -ForegroundColor Yellow
        }
    }
