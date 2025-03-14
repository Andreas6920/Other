# Start
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

#reinsure admin rights
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {$Script = $MyInvocation.MyCommand.Path
     Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

# Funktion til at få det aktuelle tidspunkt
    function Get-LogDate {return (Get-Date -f "yyyy/MM/dd HH:mm:ss")}

# Opgrader TLS
    Write-Host "[$(Get-LogDate)]`t- Opgradere forbindelse." -ForegroundColor Green
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)

# Rename PC
    # Klargøring
    Write-Host "[$(Get-LogDate)]`t- Navngiver PC:" -ForegroundColor Green
        
        # Modtager brugertastning
        Write-Host "`t- Indtast Fornavn: " -NoNewline -f yellow;
        $Forename = Read-Host
        $Forename = $Forename.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
        Write-Host "`t- Indtast Efternavn: " -NoNewline -f yellow;
        $Lastname = Read-Host
        $Lastname = $Lastname.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
        
        # COMPUTER NAVN
        $PCName = "PC-"+$Forename.Substring(0,3).ToUpper()+$Lastname.Substring(0,3).ToUpper()
        
        # COMPUTER BESKRIVELSE
        if ($Lastname -notlike "*s"){$Lastname = $Lastname + "'s"}
        else{$Lastname = $Lastname + "'"}
        $Lastname = (Get-Culture).TextInfo.ToTitleCase($Lastname)
        $Forename = (Get-Culture).TextInfo.ToTitleCase($Forename)
        $PCDescription = $Forename+" "+$Lastname + " PC"
    
    # Navngiv PC
        # Omdøb PC
        $WarningPreference = "SilentlyContinue"
        Write-Host "`t`t- COMPUTERNAVN:`t`t$PCName" -f Yellow;
        if($PCName -ne $env:COMPUTERNAME){Rename-computer -newname $PCName}
        # Omdøb PC Beskrivelse
        $WarningPreference = "SilentlyContinue"
        Write-Host "`t`t- BESKRIVELSE:`t`t$PCDescription" -f Yellow;
        $ThisPCDescription = Get-WmiObject -class Win32_OperatingSystem
        $ThisPCDescription.Description = $PCDescription
        $ThisPCDescription.put() | out-null
        Write-Host "[$(Get-LogDate)]`t- Computeren navngives ved genstart." -ForegroundColor Green

# Install Action1
Write-Host "[$(Get-LogDate)]`t- Opsætter Opdateringer:" -ForegroundColor Green
    
    # Download
    Write-Host "[$(Get-LogDate)]`t        - Henter ned" -ForegroundColor Yellow
    $link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
    $path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
    (New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null
    
    # Install
    Write-Host "[$(Get-LogDate)]`t        - Opsætter" -ForegroundColor Yellow -NoNewline
    msiexec /i $path /quiet
    
    # Confirming installation
    do{Start-Sleep -S 1; Write-Host "." -NoNewline -ForegroundColor Yellow}until(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)

Write-Host "[$(Get-LogDate)]`t- Opsætning gennemført. Genstart din PC snarest." -ForegroundColor Green