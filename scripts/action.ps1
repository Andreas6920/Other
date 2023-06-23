$link = "https://app.action1.com/agent/6a1ea6b4-c507-11ed-bb7e-33120ead7e2e/Windows/agent(My_Organization).msi"
$path = join-path -Path $env:TMP -ChildPath “action1_agent(My_Organization).msi”
(New-Object net.webclient).Downloadfile("$link", "$path")
msiexec /i $path /quiet