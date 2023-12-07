# Setup Requirements
    $Link = "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1"
    $Destination = "$env:TMP\WinOptimizerInstall.ps1"
    Invoke-WebRequest -uri $Link -OutFile $destination  -UseBasicParsing;
    Clear-Host
    powershell -ep bypass $destination

# Setup Menu Requirements

    # Create Folder
        Write-host "Loading" -nonewline
        $rootpath = [Environment]::GetFolderPath("CommonApplicationData")
        $applicationpath = Join-path -Path $rootpath -Childpath "WinOptimizer"

        if(!(Test-Path $applicationpath)){Write-host "."; New-Item -ItemType Directory -Path $applicationpath -Force | Out-Null}

    # Download Scripts
        $scripts = @(
        "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_antibloat.ps1"
        "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_security.ps1"
        "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/win_settings.ps1")

        Foreach ($script in $scripts) {

        # Download Missing Files
            $filename = split-path $script -Leaf
            $filedestination = join-path $rootpath -Childpath $filename
            (New-Object net.webclient).Downloadfile("$script", "$filedestination")

    #Creating Missing Regpath
        $reg_install = "HKLM:\Software\WinOptimizer"
        If(!(Test-Path $reg_install)) {
            Write-host ".";
            New-Item -Path $reg_install -Force | Out-Null;}

    #Creating Missing Regkeys
        if (!((Get-Item -Path $reg_install).Property -match $filename)){
            Set-ItemProperty -Path $reg_install -Name $filename -Type String -Value 0}}


Set-Location $rootpath
Write-host "`n`nWINOPTIMIZER`n" -f yellow
Start-Menu -Name "win_antibloat" -Number "1" -Rename "Clean Windows"
Start-Menu -Name "win_security" -Number "2" -Rename "Secure Windows"
Start-Menu -Name "win_settings" -Number "3" -Rename "Configure Windows"
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
    

