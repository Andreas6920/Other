# Prepare
    # Nuget
    $packageProviders = Get-PackageProvider | Select-Object name
    if(!($packageProviders.name -contains "nuget")){Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser}
    if($packageProviders -contains "nuget"){Import-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force -Scope CurrentUser}

# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Disable Explorer first run
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

# install modules
    $modulepath = $env:PSmodulepath.split(";")[1].Replace("\","/")

    $modules = @(
    "https://raw.githubusercontent.com/Andreas6920/Other/main/modules/upload.psm1";

                )   
    foreach ($module in $modules) {
    $name = (split-path $module -Leaf).Replace(".psm1","").Replace(".ps1","").Replace(".psd","")
    $dir = $modulepath+"/"+$name+"/"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $module
    $dir
    (New-Object net.webclient).Downloadfile("$module", "$dir")
    

    }

       
       (New-Object net.webclient).Downloadfile("https://raw.githubusercontent.com/Andreas6920/Other/main/modules/upload.psm1", "C:/temp")
        

        