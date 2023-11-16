$link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
$path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
(New-Object net.webclient).Downloadfile("$link", "$path")
msiexec /i $path /quiet