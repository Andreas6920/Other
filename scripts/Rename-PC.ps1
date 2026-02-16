function Rename-PC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    function Normalize-NamePart {
        param(
            [Parameter(Mandatory)]
            [string]$Value
        )

        $v = $Value.Trim()

        # Remove spaces and common separators
        $v = $v -replace "[\s\-]+", ""

        # Replace Danish letters
        $v = $v.Replace('æ','a').Replace('ø','o').Replace('å','a')
        $v = $v.Replace('Æ','A').Replace('Ø','O').Replace('Å','A')

        return $v
    }

    # Strategy 3: Use first 3 chars if available, otherwise use the whole value (no padding)
    function Get-NamePrefix {
        param(
            [Parameter(Mandatory)]
            [string]$Value
        )

        $v = $Value.ToUpper()

        if ($v.Length -ge 3) { return $v.Substring(0,3) }
        return $v
    }

    Write-Host "`tNavngiver PC." -ForegroundColor Green

    # Collect forename/lastname
    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "`t    - Indtast Fornavn: " -NoNewline -ForegroundColor Yellow
        $Forename = Read-Host

        Write-Host "`t    - Indtast Efternavn: " -NoNewline -ForegroundColor Yellow
        $Lastname = Read-Host
    }
    else {
        $parts = $Name.Trim() -split "\s+"

        if ($parts.Count -lt 2) {
            throw "Rename-PC: -Name skal indeholde mindst fornavn og efternavn, fx 'Johanne Severinsen'."
        }

        $Forename = $parts[0]
        $Lastname = $parts[-1]
    }

    $ForenameNorm = Normalize-NamePart -Value $Forename
    $LastnameNorm = Normalize-NamePart -Value $Lastname

    if ([string]::IsNullOrWhiteSpace($ForenameNorm) -or [string]::IsNullOrWhiteSpace($LastnameNorm)) {
        throw "Rename-PC: Fornavn og efternavn må ikke være tomme efter normalisering."
    }

    # COMPUTER NAME
    $PCName = "PC-" + (Get-NamePrefix -Value $ForenameNorm) + (Get-NamePrefix -Value $LastnameNorm)

    # COMPUTER DESCRIPTION
    $ti = (Get-Culture).TextInfo

    $ForenameDisplay = $ti.ToTitleCase($ForenameNorm.ToLower())

    $LastnameDisplay = $LastnameNorm
    if ($LastnameDisplay -notlike "*s") { $LastnameDisplay = $LastnameDisplay + "'s" }
    else { $LastnameDisplay = $LastnameDisplay + "'" }

    $LastnameDisplay = $ti.ToTitleCase($LastnameDisplay.ToLower())

    $PCDescription = "$ForenameDisplay $LastnameDisplay PC"

    # Apply changes
    $WarningPreference = "SilentlyContinue"

    Write-Host "`t`t- COMPUTERNAVN:`t`t$PCName" -ForegroundColor Yellow
    if ($PCName -ne $env:COMPUTERNAME) {
        Rename-Computer -NewName $PCName -Force
    }
    else {
        Write-Host "`t`t- Navn er allerede sat til $PCName" -ForegroundColor Green
    }

    Write-Host "`t`t- BESKRIVELSE:`t`t$PCDescription" -ForegroundColor Yellow
    $ThisPCDescription = Get-WmiObject -Class Win32_OperatingSystem
    $ThisPCDescription.Description = $PCDescription
    $null = $ThisPCDescription.Put()

    Write-Host "`tComputeren navngives ved genstart." -ForegroundColor Green
}
