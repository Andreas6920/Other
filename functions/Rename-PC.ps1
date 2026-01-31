# Reinsure admin rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass", "-File `"$Script`""}



# Definer navn
            # Klargøring
                Write-Host "`t    Navngiver PC." -ForegroundColor Green
            # Modtager brugertastning
                Write-Host "`t- Indtast Fornavn: " -nonewline -f yellow;
                $Forename = Read-Host
                $Forename = $Forename.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
                Write-Host "`t- Indtast Efternavn: " -nonewline -f yellow;
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
        Write-Host "`t    Computeren navngives ved genstart." -ForegroundColor Green
