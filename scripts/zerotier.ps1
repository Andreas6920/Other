﻿# Set-ExecutionPolicy    
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    $sys = [Environment]::GetFolderPath("ProgramFilesX86"), [Environment]::GetFolderPath("ProgramFiles")
    $check = Get-ChildItem $sys -Directory -Depth 0 | Where {$_.name -eq "ZeroTier"}

# if not installed, install ZeroTier
    if(!($check)){
        write-host "Installing ZeroTier.."
        Start-job -Name "Installation" -ScriptBlock {
        $link = "https://chocolatey.org/install.ps1"
        iex ((New-Object System.Net.WebClient).DownloadString($link))
        # Install Zerotier
        choco install zerotier-one -y} | Out-Null}
        Wait-Job -Name "Installation" | Out-Null

# Join network 
    $networkid = Read-Host -Prompt "    Enter Zerotier Network id"
    $client = "C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat";
    Start-Process -WindowStyle Hidden -FilePath $client -ArgumentList "join $networkid && exit" -Wait

# Copy to startup
    $shortcut = (Get-ChildItem $sys -Depth 2 | Where {$_.name -like "zerotier_desktop_ui.exe"}).FullName
    $startup = [Environment]::GetFolderPath("Startup")
    $startup = Join-Path -Path $startup -ChildPath (Split-Path $shortcut -Leaf)
    
    Copy-Item $shortcut $startup