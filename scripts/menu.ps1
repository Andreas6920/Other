# Setup Requirements
    #Clear-Host
    $Link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/install.ps1"
    $Destination = "$env:TMP\WinOptimizerInstall.ps1"
    Invoke-WebRequest -uri $Link -OutFile $destination -UseBasicParsing;
    powershell -ep bypass $destination

# Setup Menu Requirements
    $rootpath = [Environment]::GetFolderPath("CommonApplicationData")
    $applicationpath = Join-path -Path $rootpath -Childpath "WinOptimizer"
    $Link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/menu.ps1"
    $Destination = join-path -Path $applicationpath -ChildPath (split-path $link -Leaf)
    Invoke-WebRequest -uri $Link -OutFile $destination -UseBasicParsing;


# Banner, just to show off
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

    Set-Location $applicationpath
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
