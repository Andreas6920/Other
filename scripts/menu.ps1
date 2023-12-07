# Setup Requirements
    Write-host "Installing.."
    $Link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/install.ps1"
    $Destination = "$env:TMP\WinOptimizerInstall.ps1"
    Invoke-WebRequest -uri $Link -OutFile $destination  -UseBasicParsing;
    powershell -ep bypass $destination

# Setup Menu Requirements

    # Create Folder
        Write-host "Installing menu.."
        $rootpath = [Environment]::GetFolderPath("CommonApplicationData")
        $applicationpath = Join-path -Path $rootpath -Childpath "WinOptimizer"

        if(!(Test-Path $applicationpath)){Write-host "`t- Creating folder.."; New-Item -ItemType Directory -Path $applicationpath -Force | Out-Null}

    # Download Scripts
        $scripts = @(
        "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_antibloat.ps1"
        "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_security.ps1"
        "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_settings.ps1")
        Write-host "`t- Loading system.."
        Foreach ($script in $scripts) {

        # Download Scripts
            $filename = split-path $script -Leaf
            $filedestination = join-path $applicationpath -Childpath $filename
            (New-Object net.webclient).Downloadfile("$script", "$filedestination")
            
        #Creating Missing Regpath
            $reg_install = "HKLM:\Software\WinOptimizer"
            If(!(Test-Path $reg_install)) {New-Item -Path $reg_install -Force | Out-Null;}

        #Creating Missing Regkeys
            if (!((Get-Item -Path $reg_install).Property -match $filename)){Set-ItemProperty -Path $reg_install -Name $filename -Type String -Value 0}}

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
