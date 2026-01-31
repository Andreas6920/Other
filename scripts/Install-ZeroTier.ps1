# Join zerotier ID
    $networkid = Read-Host -Prompt "    Enter Zerotier Network id"

# Test if ZeroTier is installed on this system
    if((!(test-path "C:\Program Files (x86)\ZeroTier")) -and (!(test-path "C:\Program Files\ZeroTier"))){ 

        # If winget is installed on the system - use winget to install Zerotier
            if (Get-Command Winget -ErrorAction SilentlyContinue) {
                    winget install --id ZeroTier.ZeroTierOne --source winget -e --force
                    Clear-Host}

        # If winget is NOT installed on the system - use chocolatey to install Zerotier
            else {
                # Install Chocolatey
                    Set-ExecutionPolicy Bypass -Scope Process -Force
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
                # Install zerotier
                    choco install zerotier-one -y}}

# Join ZeroTier network 
    $client = (Get-ChildItem -Path "C:\Program Files\ZeroTier", "C:\Program Files (x86)\ZeroTier" -Recurse -Filter "zerotier-cli.bat" -ErrorAction SilentlyContinue).FullName
    Start-Process -WindowStyle Hidden -FilePath $client -ArgumentList "join $networkid && exit" -Wait

# Copy to startup
    $shortcut = (Get-ChildItem -Path "C:\Program Files\ZeroTier", "C:\Program Files (x86)\ZeroTier" -Recurse -Filter "zerotier_desktop_ui.exe" -ErrorAction SilentlyContinue).FullName
    $startup = [Environment]::GetFolderPath("Startup")
    $startup = Join-Path -Path $startup -ChildPath (Split-Path $shortcut -Leaf)
    Copy-Item $shortcut $startup