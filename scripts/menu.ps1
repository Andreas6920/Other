# Setup Requirements
    
    
    
    # Create folder
    $Destination = Join-path -Path ([Environment]::GetFolderPath("CommonApplicationData")) -Childpath "WinOptimizer"
        if(!(test-path $Destination)){mkdir $Destination -ErrorAction SilentlyContinue | Out-Null }

    # Download Scripts
    $Links = @( "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/install.ps1"
                "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/menu.ps1")
    foreach ($Link in $Links) {Invoke-WebRequest -uri $Link -OutFile  (join-path -Path $Destination -ChildPath (split-path $link -Leaf))}
    
    # Install requirements
    Import-Module $Destination\install.ps1

# Banner, just to show off

Start-WinOptimizerUI
<#

Clear-Host
$intro = 
"
 _       ___       ____        __  _           _                
| |     / (_)___  / __ \____  / /_(_)___ ___  (_)___  ___  _____
| | /| / / / __ \/ / / / __ \/ __/ / __ `__  \/ /_  / / _ \/ ___/
| |/ |/ / / / / / /_/ / /_/ / /_/ / / / / / / / / /_/  __/ /    
|__/|__/_/_/ /_/\____/ .___/\__/_/_/ /_/ /_/_/ /___/\___/_/     
                    /_/                                         
Version 3.0
Creator: Andreas6920 | https://github.com/Andreas6920/
                                                                                                                                                    
 "


# Start Menu

    Set-Location (Split-Path $Destination)
    #Clear-Host
    Write-Host $intro -f Yellow 
    Write-Host "`t[1] - All"
    Start-Menu -Name "win_antibloat" -Number "2" -Rename "Clean Windows"
    Start-Menu -Name "win_security" -Number "3" -Rename "Secure Windows"
    Start-Menu -Name "win_settings" -Number "4" -Rename "Configure Windows"
    Write-Host ""
    Write-Host "`t[0] - Quit"
    Write-Host ""
    Write-Host "`nOption: " -f Yellow -nonewline; ;

        $option = Read-Host
        Switch ($option) { 
            0 { exit }
            1 { }
            2 { .\win_antibloat.ps1; Add-Hash -Name "win_antibloat.ps1"; .\menu.ps1; }
            3 { .\win_security.ps1; Add-Hash -Name "win_security.ps1"; .\menu.ps1; }
            4 { .\win_settings.ps1; Add-Hash -Name "win_settings.ps1"; .\menu.ps1; }
            5 {  }
            Default { } 
        }
#>