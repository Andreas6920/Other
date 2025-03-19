# Version 1.0

# Konfiguration
    $basePath = "C:/script"
    $executePath = "$basePath/Execute/ScriptExecuter.ps1"
    $archivePath = "$basePath/Archive"
    $logPath = "$basePath/Logs/ScriptLog.txt"
    $scriptURL = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"

# Funktion til formateret dato
    function Get-FormattedDate {return (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")}

# Tjek om nødvendige mapper findes
    $folders = @($archivePath, "$basePath/Logs")
    foreach ($folder in $folders) {if (!(Test-Path $folder)) {New-Item -ItemType Directory -Path $folder -Force | Out-Null}}

# Tjek om Executer skal opdateres

    # Hent online scripts første linje (tag højde for æ, ø, å)
        try {$onlineScript = [System.Text.Encoding]::UTF8.GetString((New-Object System.Net.WebClient).DownloadData($scriptURL))
            $onlineFirstLine = ($onlineScript -split "`r?`n")[0]} 
        catch {"[$(Get-FormattedDate)] Fejl ved hentning af script fra $scriptURL - $_" | Add-Content -Path $logPath; exit 1}

    # Hent lokal scriptets første linje
        if (Test-Path $executePath) {$localFirstLine = (Get-Content $executePath -First 1 -Encoding UTF8)}
        else {$localFirstLine = ""}

    # Opdater scriptet, hvis online versionen er anderledes
    if ($onlineFirstLine -ne $localFirstLine){
        $onlineScript | Set-Content -Path $executePath -Encoding UTF8
        "[$(Get-FormattedDate)] Executer Opdatering fundet:" | Add-Content -Path $logPath
        "[$(Get-FormattedDate)] Online Version: $onlinescript" | Add-Content -Path $logPath
        "[$(Get-FormattedDate)] Lokal Version: $localFirstLine" | Add-Content -Path $logPath
        "[$(Get-FormattedDate)] Script opdateret fra Github" | Add-Content -Path $logPath}

# Tjek for scripts i C:/script
    $scripts = Get-ChildItem -Path $basePath -Filter "*.ps1" -File | Where-Object { $_.FullName -ne $executePath }

    # Kør script hvis der ligger nogle nye i rodmappen
    if ($scripts.Count -gt 0) {
        $timestamp = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
        $archiveSubPath = "$archivePath/$timestamp"
        New-Item -ItemType Directory -Path $archiveSubPath -Force | Out-Null
        
        foreach ($script in $scripts) {
            try {$startTime = Get-FormattedDate
                "[$startTime] Kører script: $($script.Name)" | Add-Content -Path $logPath
                
                & $script.FullName
                
                $endTime = Get-FormattedDate
                "[$endTime] Færdig med at køre script: $($script.Name)" | Add-Content -Path $logPath
                Move-Item -Path $script.FullName -Destination "$archiveSubPath/$($script.Name)" -Force}
            catch {"[$(Get-FormattedDate)] Fejl ved kørsel af script: $($script.Name) - $_" | Add-Content -Path $logPath}
        }
    } 
    
    else {"[$(Get-FormattedDate)] Ingen scripts fundet i $basePath" | Add-Content -Path $logPath}