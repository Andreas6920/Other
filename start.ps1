# Prepare

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

    $dst = $env:PSmodulepath.split(";")[1]

$modules = @(
    "https://raw.githubusercontent.com/Andreas6920/Other/main/modules/upload.psm1";


	)
foreach ($module in $modules) {
    Write-host "Downloading module:"(split-path $module -Leaf)
    $dst = join-path $dst -ChildPath  (split-path $module -Leaf)
    (New-Object net.webclient).Downloadfile("$module", "$dst")
    Install-Module $dst -Force

    }
