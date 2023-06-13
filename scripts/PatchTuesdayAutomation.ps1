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


# IF patchtuesday was yesterday, update system
    $patchday = Get-Date (Get-PatchTuesday).AddDays(1) -Format "yyyy/MM/dd"
    $today = Get-Date -Format "yyyy/MM/dd"    
    if($today -eq $patchday){

        # Windows Notification
        if(!(test-path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208")){Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force}
        if(!(Get-module -name BurntToast)){Install-Module -Name BurntToast -Force}
        $Logo = "$($env:TMP)\Coffee.gif"
        if(!(test-path $logo)){$Logolink = "https://tinyurl.com/asdsad11111"; (New-Object net.webclient).Downloadfile($logolink, $logo)}
        New-BurntToastNotification -Applogo $logo -Text "PatchTuesday", ".. was yesterday!`nPatching system now.."

        # Updating system
        if(!(Get-module -name PSWindowsUpdate)){Install-Module PSWindowsUpdate -Force}
        Import-module PSWindowsUpdate
        Install-WindowsUpdate -Confirm:$False

        # Windows Notification
        New-BurntToastNotification -Applogo $logo -Text "PatchTuesday", "Patching complete."}

# Schedule patching for next Patchtuesday..

    # Downloading this script to PC
    $link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/PatchTuesdayAutomation.ps1"
    $path = join-path -Path "$($env:ProgramData)\PatchTuesdayAutomation" -ChildPath (split-path $link -Leaf)
        if(!(test-path $path)){mkdir (split-path $path) -Force | Out-Null -ErrorAction SilentlyContinue}
        (New-Object net.webclient).Downloadfile("$link", "$path")
        do{sleep -s 1}until((Test-Path $path) -eq $true)
    $day = Get-Date (Get-NextPatchTuesday).AddDays(1) -Hour 09
    
    # Create a scheduled task called "Update - PatchTuesday Check"
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -w hidden -file $path"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 5)
    $Date = New-ScheduledTaskTrigger -Once -At $day
    $User = If ($Args[0]) {$Args[0]} Else {[Environment]::UserName}

    Register-ScheduledTask -TaskName "Update - PatchTuesday Check" -Action $Action -Settings $Settings -Trigger $Date -User $User -RunLevel Highest -Force



    
