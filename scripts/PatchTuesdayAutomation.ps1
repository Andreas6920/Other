# Prepare system
    Set-executionpolicy -ExecutionPolicy Bypass -Scope Process -Force
    Function Get-PatchTuesday {
          [CmdletBinding()]
          Param
          (
            [Parameter(position = 0)]
            [ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")]
            [String]$weekDay = 'Tuesday',
            [ValidateRange(0, 5)]
            [Parameter(position = 1)]
            [int]$findNthDay = 2
          )
          # Get the date and find the first day of the month
          # Find the first instance of the given weekday
          [datetime]$today = [datetime]::NOW
          $todayM = $today.Month.ToString()
          $todayY = $today.Year.ToString()
          [datetime]$strtMonth = $todayM + '/1/' + $todayY
          while ($strtMonth.DayofWeek -ine $weekDay ) { $strtMonth = $StrtMonth.AddDays(1) }
          $firstWeekDay = $strtMonth

          # Identify and calculate the day offset
          if ($findNthDay -eq 1) {
            $dayOffset = 0
          }
          else {
            $dayOffset = ($findNthDay - 1) * 7
          }
  
          # Return date of the day/instance specified
          $patchTuesday = $firstWeekDay.AddDays($dayOffset) 
          return $patchTuesday
        }
    Function Get-NextPatchTuesday {
          [CmdletBinding()]
          Param
          (
            [Parameter(position = 0)]
            [ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")]
            [String]$weekDay = 'Tuesday',
            [ValidateRange(0, 5)]
            [Parameter(position = 1)]
            [int]$findNthDay = 2
          )
          # Get the date and find the first day of the month
          # Find the first instance of the given weekday
          $today = (get-date).AddMonths(1)
          $todayM = $today.Month.ToString()
          $todayY = $today.Year.ToString()
          [datetime]$strtMonth = $todayM + '/1/' + $todayY
          while ($strtMonth.DayofWeek -ine $weekDay ) { $strtMonth = $StrtMonth.AddDays(1) }
          $firstWeekDay = $strtMonth

          # Identify and calculate the day offset
          if ($findNthDay -eq 1) {
            $dayOffset = 0
          }
          else {
            $dayOffset = ($findNthDay - 1) * 7
          }
  
          # Return date of the day/instance specified
          $patchTuesday = $firstWeekDay.AddDays($dayOffset) 
          return $patchTuesday
        }
    $ProgressPreference = "SilentlyContinue"
    Clear-Host
    Write-host "`Patch Tuesday Automation:" -F Yellow
    Write-host "`t- Installing dependicies.." -F DarkYellow
    if(!(test-path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208")){Write-host "`t`t- NuGet" -F DarkYellow; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null}
    if(!(Get-module -ListAvailable -name BurntToast)){Write-host "`t`t- BurntToast" -F DarkYellow; Install-Module -Name BurntToast -Force | Out-Null}
    $Logo = "$($env:TMP)\Coffee.gif"
    if(!(test-path $logo)){$Logolink = "https://tinyurl.com/asdsad11111"; (New-Object net.webclient).Downloadfile($logolink, $logo)}

    

# IF patchtuesday was yesterday, update system
    $patchday = Get-Date (Get-PatchTuesday).AddDays(1) -Format "yyyy/MM/dd"
    $today = Get-Date -Format "yyyy/MM/dd"
    Write-host "`t`- Cheking dates:" -F DarkYellow; Start-Sleep -S 1
    Write-host "`t`t- Patchday:`t`t$patchday" -F DarkYellow; Start-Sleep -S 1
    Write-host "`t`t- Date today:`t$today" -F DarkYellow; Start-Sleep -S 1
        
    if($today -eq $patchday){ 
        Write-host "`t- It's patchday!" -f Green

        # Windows Notification
        New-BurntToastNotification -Applogo $logo -Text "PatchTuesday", ".. was yesterday!`nSearching for new patches.."
        
        # Updating system
        if(!(Get-module -name PSWindowsUpdate)){Write-host "`t-Installing PSWindowsUpdate";Install-Module PSWindowsUpdate -Force}
        Import-module PSWindowsUpdate
        if((get-windowsupdate) -eq $null){New-BurntToastNotification -Applogo $logo -Text "PatchTuesday", "All new updates allready installed."}
        else{Write-host "`t-Installing Updating Windows (This may take a while"; Install-WindowsUpdate -Confirm:$False}

        # Windows Notification
        New-BurntToastNotification -Applogo $logo -Text "PatchTuesday", "Patching complete."}
    else{Write-host "`t- It's Not patchday." -f DarkYellow}

# Schedule patching for next Patchtuesday..

    # Downloading this script to PC
    $link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/PatchTuesdayAutomation.ps1"
    $path = join-path -Path "$($env:ProgramData)\PatchTuesdayAutomation" -ChildPath (split-path $link -Leaf)
        if(!(test-path $path)){mkdir (split-path $path) -Force | Out-Null -ErrorAction SilentlyContinue}
        (New-Object net.webclient).Downloadfile("$link", "$path")
        do{sleep -s 1}until((Test-Path $path) -eq $true)
    
    # Find next upcomming PatchTuesday
    Write-host "`t- Scheduling next PatchTuesday:" -F DarkYellow
    if($today -lt $patchday){$day = Get-Date $patchday -Hour 09}
    else{$day = Get-Date (Get-NextPatchTuesday).AddDays(1) -Hour 09}
        
    # Create a scheduled task called "Update - PatchTuesday Check"
    $npd = Get-Date $day -Format "yyyy/MM/dd"
    Write-host "`t`t- Next patchday:`t$npd (1 day AFTER PatchTuesday)" -F DarkYellow
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -w hidden -file $path"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 5)
    $Date = New-ScheduledTaskTrigger -Once -At $day
    $User = If ($Args[0]) {$Args[0]} Else {[Environment]::UserName}
    Register-ScheduledTask -TaskName "Update - PatchTuesday Check" -Action $Action -Settings $Settings -Trigger $Date -User $User -RunLevel Highest -Force | Out-Null
    Write-host "`t`t- Job Scheduled" -F DarkYellow
    Write-host "`t- Automation complete" -f Yellow