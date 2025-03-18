# Set-ExecutionPolicy    
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    $sys = [Environment]::GetFolderPath("ProgramFilesX86"), [Environment]::GetFolderPath("ProgramFiles")
    $check = Get-ChildItem $sys -Directory -Depth 0 | Where-Object {$_.name -eq "ZeroTier"}

# if not installed, Start Install
    
    # Install Chocolatey
        if(!($check)){
            if (!(Test-Path "$env:ProgramData\Chocolatey")) {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))}
    # Install ZeroTier
        choco install zerotier-one -y}

# Join ZeroTier network 
    $networkid = Read-Host -Prompt "    Enter Zerotier Network id"
    $client = "C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat";
    Start-Process -WindowStyle Hidden -FilePath $client -ArgumentList "join $networkid && exit" -Wait

# Copy to startup
    $shortcut = (Get-ChildItem $sys -Depth 2 | Where-Object {$_.name -like "zerotier_desktop_ui.exe"}).FullName
    $startup = [Environment]::GetFolderPath("Startup")
    $startup = Join-Path -Path $startup -ChildPath (Split-Path $shortcut -Leaf)
    
    Copy-Item $shortcut $startup