Set-Executionpolicy -ExecutionPolicy Bypass -Scope Process -Force

$url = "https://www.bitdefender.com/files/KnowledgeBase/file/Bitdefender_2023_Uninstall_Tool.exe"
$path = Join-Path $env:TMP -ChildPath "Bitdefender Uninstall Tool"
    if(!(test-path $path)){New-Item -Path $path -ItemType Directory -ErrorAction SilentlyContinue -Force | Out-Null}
$filepath = Join-path -Path $path -Childpath (Split-path $url -Leaf)
(New-Object System.Net.WebClient).DownloadFile($url, $filepath)

Start-Process $path -WindowStyle Maximized
Start-Process $filepath
