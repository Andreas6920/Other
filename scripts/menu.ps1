$rootpath = [Environment]::GetFolderPath("CommonApplicationData")
$applicationpath = Join-path -Path $path -Childpath "winoptimizer"
if(!(test-path $applicationpath)){
        New-Item -ItemType Directory -Path $rootpath -Force | Out-Null
        $link = "https://transfer.sh/HhwU0mirj6/install.ps1"
        $path = join-path -Path $rootpath -ChildPath (split-path $link -Leaf)
        (New-Object net.webclient).Downloadfile("$link", "$path");
        Powershell -ep bypass $path
        }



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
    

