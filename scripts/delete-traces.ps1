    
    # Personal folders   
        Write-host "`t    - Deleting personal user files.." -f yellow; start-job -Name "Personal documents files" -ScriptBlock {
        # My Dcouments, Videos, Photos etc..
        Get-Childitem $env:userprofile | % {Get-ChildItem $_.FullName | remove-item -Recurse -Force -ea SilentlyContinue} | ? { ! $_.PSIsContainer }} | Out-Null
    
    # Personal system files
        Write-host "`t    - Deleting personal system files.." -f yellow; start-job -Name "Personal system files" -ScriptBlock {
        # Recent files
        Write-host "`t    - Recent files.." -f yellow
        Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent\*" -File -Force -Exclude "desktop.ini" | Remove-Item -Force -ea SilentlyContinue
        Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*" -File -Force -Exclude "desktop.ini" | Remove-Item -Force -ea SilentlyContinue
        Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*" -File -Force -Exclude "desktop.ini" | Remove-Item -Force -ea SilentlyContinue
        # Temp folders
        $UserCreationDate = get-date ((Get-Item $($env:USERPROFILE)).CreationTime); $UserCreationDate = $UserCreationDate.ToShortDateString()
        (Get-ChildItem "c:\windows\temp\" -Recurse | ? {$UserCreationDate -notcontains $_.CreationTime.ToShortDateString()}).FullName | Remove-Item -Recurse -Force -ea SilentlyContinue
        Remove-Item -path $($env:TMP) -Recurse -Force -ea SilentlyContinue} | Out-Null                            

    # Customized shortcuts, pinned stuff
        Write-host "`t    - Deleting personal shortcuts, pinned stuff.." -f yellow; start-job -Name "Personal system files" -ScriptBlock {
        # Desktop
        $path = [Environment]::GetFolderPath("Desktop")
        Get-Childitem $path | remove-item -Recurse -Force -ea SilentlyContinue | Out-Null
        # Taskbar
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name FavoritesChanges -Value 3 -Type Dword -Force | Out-Null
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name FavoritesRemovedChanges -Value 32 -Type Dword -Force | Out-Null
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name FavoritesVersion -Value 3 -Type Dword -Force | Out-Null
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name Favorites -Value ([byte[]](0xFF)) -Force | Out-Null
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Type DWord -Value 0 | Out-Null
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0 -Type Dword | Out-Null
        set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Type DWord -Value 0 | Out-Null
        Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Recurse -Force | Out-Null
        # Startmenu
        Write-host "`t    - Startmenu.." -f yellow
        $layoutFile = "$env:SystemRoot\StartMenuLayout.xml"
        Remove-Item $layoutFile -Force -ea SilentlyContinue
        Invoke-WebRequest -uri "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/StartMenuLayout.xml" -OutFile $layoutFile
        $regAliases = @("HKLM", "HKCU")
        foreach ($regAlias in $regAliases) {
        $basePath = $regAlias + ":\Software\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        IF (!(Test-Path -Path $keyPath)) {New-Item -Path $basePath -Name "Explorer" | Out-Null}
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile}
        Stop-Process -name explorer
        # Quick access
        remove-item "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\f01b4d95cf55d32a.automaticDestinations-ms" -Force -ea SilentlyContinue} | Out-Null
    
    # Browser cleaning
     Write-host "`t- Deleting Browser data:" -f yellow
        
     function Remove-ChromiumCache {
        param (
            [Parameter(Mandatory=$true)]
            [string]$ProfilesPath,
            [Parameter(Mandatory=$true)]
            [String]$ProcessName)
        $rootfolders = $env:LOCALAPPDATA, $env:APPDATA
        $profilepath = join-path -Path $rootfolders[0] -ChildPath $ProfilesPath
        if ((Test-Path $profilepath)){Write-host "`t    - Cleaning $processname.." -f yellow; 
        if(Get-Process -Name $ProcessName -ErrorAction SilentlyContinue){
            Stop-process -Name $ProcessName -Force; Start-Sleep -s 3}
        foreach ($folder in $rootfolders)
            {$subfolder = Join-path -Path $folder -ChildPath $ProfilesPath
            if(test-path $subfolder){Get-ChildItem $subfolder | Remove-item -Recurse -Force -ErrorAction SilentlyContinue}}}}
    
    function Remove-GeckoCache {
        param (
            [Parameter(Mandatory=$true)]
            [string]$ProfilesPath,
            [Parameter(Mandatory=$true)]
            [String]$ProcessName)
    
        $rootfolders = $env:LOCALAPPDATA, $env:APPDATA
        $profilepath = join-path -Path $rootfolders[1] -ChildPath $ProfilesPath
        If ((Test-Path $profilepath)){Write-host "`t    - Cleaning $processname.." -f yellow; 
        if(Get-Process -Name $ProcessName -ErrorAction SilentlyContinue){
            Stop-process -Name $ProcessName -Force; Start-Sleep -s 3}
        $profiles = $rootfolders | ForEach-Object {Join-Path -Path $_ -ChildPath $profilespath}
        $profiles = (get-childitem $profiles).FullName | ForEach-Object {Get-ChildItem $_ | Remove-item -Recurse -Force -ErrorAction SilentlyContinue }}}
    
        # Internet Explorer
        start-job -Name "Internet Explorer" -ScriptBlock {
        Write-host "`t- Cleaning Internet Explorer.." -f yellow
        Get-Process | ? Name -match OneDrive | Stop-Process  -ErrorAction SilentlyContinue
        Stop-Process -Name "iexplore" -ErrorAction SilentlyContinue
        RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 1
        Remove-Item -path "$($env:USERPROFILE)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue
        Remove-Item -path "$($env:USERPROFILE)\AppData\Local\Microsoft\Windows\INetCache\*" -Recurse -Force -EA SilentlyContinue 
        $IEKeys = @(
        "HKCU:\Software\Microsoft\Internet Explorer\TypedURLs"
        "HKCU:\Software\Microsoft\Internet Explorer\TypedURLsTime"
        "HKCU:\Software\Microsoft\Internet Explorer\TabbedBrowsing\NewTabPage"
        "HKCU:\Software\Microsoft\Internet Explorer\Main\FeatureControl"
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Stats")
        foreach ($Key in $IEKeys) { if((Test-Path $Key)){remove-item $Key -Recurse -force -ea Ignore}}} | Out-Null

        # Microsoft Edge
        Remove-ChromiumCache -ProfilesPath "Microsoft\Edge\User Data\Default" -ProcessName "msedge"
                        
        # Google Chrome
        Remove-ChromiumCache -ProfilesPath "Google\Chrome\User Data" -ProcessName "chrome"
        
        # Firefox
        Remove-GeckoCache -ProfilesPath "Mozilla\Firefox\Profiles" -ProcessName "firefox"
        
        # Librewolf
        Remove-GeckoCache -ProfilesPath "librewolf\Profiles" -ProcessName "librewolf"

        # Vivaldi
        Remove-ChromiumCache -ProfilesPath "Vivaldi\User Data" -ProcessName "vivaldi"
        
        #Opera
        Remove-ChromiumCache -ProfilesPath "Opera Software\Opera Stable" -ProcessName "opera"
       
        # Brave
        Remove-ChromiumCache -ProfilesPath "BraveSoftware\Brave-Browser" -ProcessName "brave"

        # Epic
        Remove-ChromiumCache -ProfilesPath "Epic Privacy Browser\User Data" -ProcessName "epic"

        # Opera GX
        Remove-ChromiumCache -ProfilesPath "Opera Software\Opera GX Stable" -ProcessName "opera"

        # Chromium
        Remove-ChromiumCache -ProfilesPath "Chromium\User Data" -ProcessName "chrome"
                
    # Cleaning traces                 
    Write-host "`tCleaning traces:" -f yellow
    
        # Cleanupdisk
        Write-host "`t    - Clean up disk.." -f yellow
        $path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
        If (!(Test-Path $path)) {New-Item -Path $path -Force | Out-Null}; 
        Set-ItemProperty -Path $path -Name "StateFlags001" -Type DWORD -Value 2 -Force | Out-Null
        Start-Process -FilePath CleanMgr.exe -ArgumentList ‘/sagerun:1’ -Wait
        Get-Process -Name cleanmgr,dismhost -ea SilentlyContinue | Wait-Process -Timeout 900

        # Clear eventlogs
        Write-host "`t    - Event Viewer.." -f yellow
        Get-EventLog -LogName * | % { Clear-EventLog $_.Log }
        Get-WinEvent -ListLog * | Where-Object { $PSItem.IsEnabled -eq $true -and $PSItem.RecordCount -gt 0 } | ForEach-Object -Process {[Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($PSItem.LogName)} 2> $null

        # Delete restore points
        Write-host "`t    - Restore point.." -f yellow
        vssadmin delete shadows /all | Out-Null
        Get-EventLog -LogName * | % { Clear-EventLog $_.Log }
        
        # Delete console history
        Write-host "`t    - Clean up Console History.." -f yellow
        clear-history
        get-childitem "$($env:APPDATA)\Microsoft\Windows\PowerShell\PSReadLine\*history*" | remove-item -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        
        # Make deleted files untraceable
        Write-host "`t    - Make deleted files unretrievable.. (This step will take LONG time)" -f yellow
        cipher /w:c:\