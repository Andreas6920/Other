﻿function Invoke-Huha {
            <#param ( [Parameter(Mandatory=$true)]
                    [string]$Name,
                    [Parameter(Mandatory=$true)]
                    [string]$App),
                    [Parameter(Mandatory=$false)]
                    [switch]$IncludeOffice)#>

                param (
                    [Parameter(Mandatory=$true)]
                    [string]$Name,
                    [Parameter(Mandatory=$true)]
                    [string]$App,
                    [Parameter(Mandatory=$false)]
                    [switch]$IncludeOffice)

        
            If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
            Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1
            
            $code = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
            $App-Script = "$($env:ProgramData)\Winoptimizer\Invoke-AppInstall.ps1"
        
            if(!(test-path $App-Script)){new-item -ItemType Directory ($App-Script | Split-Path) -ea ignore | out-null; New-item $App-Script -ea ignore | out-null;}
            if(!((get-content $App-Script) -notmatch "https://community.chocolatey.org/install.ps1")){Set-content -Encoding UTF8 -Value $code -Path $App-Script}
        
            Add-content -Encoding UTF8 -Value (invoke-webrequest "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/app-template.ps1").Content.replace('REPLACE-ME-NAME', $Name).replace('REPLACE-ME-APP', $App) -Path $App-Script}

            if($IncludeOffice){
            
                Write-Host "`tWould you like to Install Microsoft Office? (y/n)" -f Green -nonewline;
                
              
                        # Choose version
                            "";
                            Write-Host "`t`tVersion Menu:" -f Green
                            "";
                            Write-Host "`t`t`t - Microsoft 365" -f Yellow
                            Write-Host "`t`t`t - Microsoft Office 2019 Business Retail" -f Yellow
                            Write-Host "`t`t`t - Microsoft Office 2016 Business Retail" -f Yellow
                            "";
                            DO {                     
                                Write-Host "`t`tWhich version would you prefer?" -f Green -nonewline;
                                $answer2 = Read-host " "
                                if("$answer2" -eq "Cancel"){Write-Host "`tSkipping this section.."}                         
                                elseif("$answer2" -match "365")       {$ver = "O365BusinessRetail"; $name = "Microsoft 365";}
                                elseif("$answer2" -match "2019")      {$ver = "HomeBusiness2019Retail"; $name = "Microsoft Office 2019";}
                                elseif("$answer2" -match "2016")      {$ver = "HomeBusinessRetail"; $name = "Microsoft Office 2016"}}
                            While($ver -notin "O365BusinessRetail", "HomeBusiness2019Retail","HomeBusinessRetail")     
                      
                        # Choose Language
                              "";
                              Write-Host "`t`tLanguage Menu:" -f Green
                              "";
                              Write-Host "`t`t`t- English (United States)" -f Yellow
                              Write-Host "`t`t`t- German" -f Yellow
                              Write-Host "`t`t`t- Spanish" -f Yellow
                              Write-Host "`t`t`t- Danish" -f Yellow
                              Write-Host "`t`t`t- France" -f Yellow
                              Write-Host "`t`t`t- Japanese" -f Yellow
                              Write-Host "`t`t`t- Norwegian" -f Yellow
                              Write-Host "`t`t`t- Russia" -f Yellow
                              Write-Host "`t`t`t- Sweden" -f Yellow
                              "";
                              DO {       
                                Write-Host "`t`tEnter your language from above" -f Green -nonewline;
                                $answer3 = Read-host " "              
                                if("$answer3" -eq "Cancel"){Write-Host "`tSkipping this section.."}                         
                                elseif("$answer3" -match "^Eng")   {$lang = "en-us"}
                                elseif("$answer3" -match "^Ger")   {$lang = "de-de"}
                                elseif("$answer3" -match "^Spa")   {$lang = "es-es"}
                                elseif("$answer3" -match "^Dan")   {$lang = "da-dk"}
                                elseif("$answer3" -match "^Fra")   {$lang = "fr-fr"}
                                elseif("$answer3" -match "^Jap")   {$lang = "ja-jp"}
                                elseif("$answer3" -match "^Nor")   {$lang = "nb-no"}
                                elseif("$answer3" -match "^Rus")   {$lang = "ru-ru"}
                                elseif("$answer3" -match "^Swe")   {$lang = "sv-se"}}
                              While($lang -notin "en-us", "de-de","es-es","da-dk","fr-fr","ja-jp","nb-no","ru-ru","sv-se")
                          
                        #Installation
                            # Modify install script
                                # Download
                                    $link = "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/install-office.ps1"
                                    $App-Script = "$($env:ProgramData)\Winoptimizer\Invoke-AppInstall.ps1"
                                    if(!(test-path $App-Script)){new-item -ItemType Directory ($App-Script | Split-Path) -ea ignore | out-null; New-item $App-Script -ea ignore | out-null;}
                                    Add-content -Encoding UTF8 -Value (invoke-webrequest $link).Content.replace('REPLACE-ME-FULLNAME', $Name).replace('REPLACE-ME-VERSION', $ver).replace('REPLACE-ME-LANGUAGE', $lang) -Path $App-Script}
                         
        # Start app installation              
            Start-Process Powershell -argument "-Ep bypass -Windowstyle hidden -file `"""$($env:ProgramData)\Winoptimizer\Invoke-AppInstall.ps1""`""

                            #create update file
                            Write-Host "`t`t- Downloading updating script." -f Yellow
                            $filepath = "$env:ProgramData\chocolatey\app-updater.ps1"
                            Invoke-WebRequest -uri "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/app-updater/app-updater.ps1" -OutFile $filepath -UseBasicParsing
                            
                            # Create scheduled job
                            Write-Host "`t`t- scheduling update routine." -f Yellow
                            $name = 'winoptimizer-app-Updater'
                            $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-nop -W hidden -noni -ep bypass -file $filepath"
                            $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM"-LogonType ServiceAccount -RunLevel Highest
                            $trigger= New-ScheduledTaskTrigger -At 12:05 -Daily
                            $settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -DontStopIfGoingOnBatteries -RunOnlyIfIdle -DontStopOnIdleEnd -IdleDuration 00:05:00 -IdleWaitTimeout 03:00:00

                            Register-ScheduledTask -TaskName $Name -Taskpath "\Microsoft\Windows\Winoptimizer\" -Settings $settings -Principal $principal -Action $action -Trigger $trigger -Force | Out-Null
                                                                                
            
 
    #End of function
    Write-Host "`tApp installer completed. Enjoy your freshly installed applications." -f Green
    Start-Sleep 10




}