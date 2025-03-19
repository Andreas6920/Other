# Version 1.0

# Definer sti til mappen og logfilen
$scriptDirectory = "C:/script"
$logDirectory = "$scriptDirectory/Logs"
$archiveDirectory = "$scriptDirectory/Archive"
$logFile = "$logDirectory/ScriptLog.txt"
$scriptFilePath = "$scriptDirectory/Execute/ScriptExecuter.ps1"

# GitHub URL til scriptet (skal være den rå URL til .ps1 filen på GitHub)
$githubScriptUrl = "https://raw.githubusercontent.com/ditbrugernavn/repositorynavn/main/ScriptExecuter.ps1"

# Tjek og opret mappen 'Logs', hvis den ikke findes
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory
    Write-Host "Oprettet logmappe: $logDirectory"
}

# Tjek og opret logfilen, hvis den ikke findes
if (-not (Test-Path -Path $logFile)) {
    New-Item -Path $logFile -ItemType File
    Write-Host "Oprettet logfil: $logFile"
}

# Tjek og opret mappen 'Archive', hvis den ikke findes
if (-not (Test-Path -Path $archiveDirectory)) {
    New-Item -Path $archiveDirectory -ItemType Directory
    Write-Host "Oprettet arkivmappe: $archiveDirectory"
}

# Tjek version i den lokale version af scriptet
function Get-LocalVersion {
    $firstLine = Get-Content $scriptFilePath -First 1
    if ($firstLine -match "# Version (\d+\.\d+)") {
        return $matches[1]
    }
    return $null
}

# Tjek version på GitHub
function Get-GitHubVersion {
    try {
        $githubContent = Invoke-WebRequest -Uri $githubScriptUrl -UseBasicParsing | Select-Object -ExpandProperty Content
        $firstLine = $githubContent.Split([Environment]::NewLine)[0]
        if ($firstLine -match "# Version (\d+\.\d+)") {
            return $matches[1]
        }
    } catch {
        Write-Host "Fejl ved hentning af version fra GitHub: $_"
    }
    return $null
}

# Opdater scriptet
function Update-Script {
    $githubContent = Invoke-WebRequest -Uri $githubScriptUrl -UseBasicPaddling | Select-Object -ExpandProperty Content
    Set-Content -Path $scriptFilePath -Value $githubContent
    $updateTime = Get-FormattedDate
    $logEntry = "[$updateTime] Script opdateret til den nyeste version fra GitHub."
    Add-Content -Path $logFile -Value $logEntry
    Write-Host "Scriptet er blevet opdateret."
}

# Funktion til at få tidspunkt i ønsket format
function Get-FormattedDate {
    return (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
}

# Sammenlign versioner og opdater hvis nødvendigt
$localVersion = Get-LocalVersion
$githubVersion = Get-GitHubVersion

if ($localVersion -ne $githubVersion) {
    $updateTime = Get-FormattedDate
    $logEntry = "[$updateTime] Ny version fundet på GitHub ($githubVersion). Opdatering af script."
    Add-Content -Path $logFile -Value $logEntry

    # Opdater scriptet
    Update-Script
}


# Tjek om der findes scripts i C:/script (men ikke i undermapper)
$scriptFiles = Get-ChildItem -Path $scriptDirectory -File | Where-Object { $_.Extension -eq '.ps1' }

# Funktion til at få tidspunkt i ønsket format
function Get-FormattedDate {
    return (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
}

# Hvis der er scripts, kør det
if ($scriptFiles.Count -gt 0) {
    foreach ($scriptFile in $scriptFiles) {
        try {
            # Log starttidspunkt
            $startTime = Get-FormattedDate
            $logEntry = "[$startTime] Kører script: $($scriptFile.FullName)"
            Add-Content -Path $logFile -Value $logEntry

            # Kør scriptet
            . $scriptFile.FullName

            # Log afslutningstidspunkt
            $endTime = Get-FormattedDate
            $logEntry = "[$endTime] Færdig med at køre script: $($scriptFile.FullName)"
            Add-Content -Path $logFile -Value $logEntry

            # Opret en undermappe i Archive med tidsstempel
            $timestamp = (Get-Date).ToString("yyyy.MM.dd-HH.mm.ss")
            $archiveSubDirectory = "$archiveDirectory\$timestamp"

            # Tjek og opret undermappen, hvis den ikke findes
            if (-not (Test-Path -Path $archiveSubDirectory)) {
                New-Item -Path $archiveSubDirectory -ItemType Directory
                Write-Host "Oprettet undermappe i arkiv: $archiveSubDirectory"
            }

            # Flyt scriptet til undermappen
            Move-Item -Path $scriptFile.FullName -Destination $archiveSubDirectory

            # Log flytning af script (brug backslash i stien)
            $logEntry = "[$endTime] Flyttede script til: $($archiveSubDirectory.Replace('/', '\'))"
            Add-Content -Path $logFile -Value $logEntry
        }
        catch {
            # Hvis der opstår en fejl, log fejlbesked
            $errorTime = Get-FormattedDate
            $errorLogEntry = "[$errorTime] FEJL: Kunne ikke køre eller flytte script: $($scriptFile.FullName) - $_"
            Add-Content -Path $logFile -Value $errorLogEntry
        }
    }
} else {
    # Hvis der ikke er nogen scripts, log besked om at der ikke blev fundet noget
    $noScriptLogEntry = "[$(Get-FormattedDate)] Ingen scripts fundet til at køre i $scriptDirectory"
    Add-Content -Path $logFile -Value $noScriptLogEntry
}