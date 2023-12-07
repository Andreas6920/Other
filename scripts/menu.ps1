# Setup Requirements
    Write-host "Installing.."
    $Link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/install.ps1"
    $Destination = "$env:TMP\WinOptimizerInstall.ps1"
    Invoke-WebRequest -uri $Link -OutFile $destination  -UseBasicParsing;
    powershell -ep bypass $destination

# Setup Menu Requirements
    $rootpath = [Environment]::GetFolderPath("CommonApplicationData")
    $applicationpath = Join-path -Path $rootpath -Childpath "WinOptimizer"
    

# Start Menu

    Set-Location $applicationpath
    Clear-Host
    Write-host "`n`nWINOPTIMIZER`n" -f yellow
    Write-host "`t[1] - All"
    Start-Menu -Name "win_antibloat" -Number "2" -Rename "Clean Windows"
    Start-Menu -Name "win_security" -Number "3" -Rename "Secure Windows"
    Start-Menu -Name "win_settings" -Number "4" -Rename "Configure Windows"
    Write-Host "`nOption: " -f Yellow -nonewline; ;

        $option = Read-Host
        Switch ($option) { 
            0 { exit }
            1 { }
            2 { .\win_antibloat.ps1; Add-Hash -Name "win_antibloat.ps1"; }
            3 {  }
            4 {  }
            5 {  }
            Default { } 
        }
