If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

$link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
$path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
(New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null

#msiexec /i $path /quiet
msiexec /i $path

do{Start-Sleep -S 1}until(get-service -Name "Action1 Agent") msg * "Agenten kører!"