# Version 1.0

# Klargør systemet

    # Konfiguration
    $basepath = "C:/Script"
    $executepath = "$basepath/Execute"
    $executefile = "$executepath/ScriptExecuter.ps1"
    $archivepath = "$basepath/Archive"
    $logpath = "$basepath/Logs"
    $logfile = "$logpath/ScriptLog.txt"
    $scripturl = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/scriptexecuter.ps1"

    # Funktion til formateret dato
    function get-logdate {return (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")}

    # Kontrollere at mapperne eksistere
    $folders = @($archivepath, $logpath)
    foreach ($folder in $folders) {if (!(Test-Path $folder)) {New-Item -ItemType Directory -Path $folder -Force | Out-Null}}

# ScriptExecuter opdatering

    # Hent online scriptets første linje (Tager højde for æ, ø, å)
        try     {   $onlinescript = irm -Uri $scripturl; $onlinefirstline = $script.Split("`n")[0]}
        catch   { "[$(get-logdate)] Fejl ved hentning af script fra $scripturl - $_" | Add-Content -Path $logfile;}

    # Hent lokal scriptets første linje
        if (Test-Path $executefile) { $localfirstline = (Get-Content $executefile -First 1 -Encoding UTF8)}
        else { $localfirstline = ""}

    # Opdater scriptet, hvis online versionen er anderledes
        if ($onlinefirstline -ne $localfirstline) { 
            "[$(get-logdate)] Opdatering fundet:" | Add-Content -Path $logfile
            "[$(get-logdate)]`t`tOnline version: $onlinefirstline" | Add-Content -Path $logfile
            "[$(get-logdate)]`t`tLokal version: $localfirstline" | Add-Content -Path $logfile
            $onlinescript | Set-Content -Path $executefile -Encoding UTF8
            "[$(get-logdate)] Script opdateret fra online kilde" | Add-Content -Path $logfile}

# Kør Script

    # Tjek for nye scripts i C:/script
    $scripts = Get-ChildItem -Path $basepath -Filter "*.ps1" -File

    # Kør scriptet
    if ($scripts.Count -gt 0) {
        $timestamp = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
        $archivesubpath = "$archivepath/$timestamp"
        New-Item -ItemType Directory -Path $archivesubpath -Force | Out-Null
        
        foreach ($script in $scripts) {
            try {   $starttime = get-logdate
                    "[$starttime] Kører script: $($script.Name)" | Add-Content -Path $logfile
                    
                    # Start scriptet i separat proces med timeout
                    $proc = Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$($script.FullName)`"" -PassThru -NoNewWindow
                    $timeout = 3600  # Timeout i sekunder (60 minutter)
                    
                    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                    while ($proc.HasExited -eq $false -and $stopwatch.Elapsed.TotalSeconds -lt $timeout) {
                        Start-Sleep -Seconds 1
                    }
                    
                    if ($proc.HasExited -eq $false) {
                        Stop-Process -Id $proc.Id -Force
                        "[$(get-logdate)] Script timeout: $($script.Name) blev tvunget til at stoppe" | Add-Content -Path $logfile
                        Remove-Item -Path $script.FullName -Force
                        "[$(get-logdate)] Script slettet: $($script.Name)" | Add-Content -Path $logfile
                    } else {
                        $endtime = get-logdate
                        "[$endtime] Færdig med at køre script: $($script.Name)" | Add-Content -Path $logfile
                        
                        Move-Item -Path $script.FullName -Destination "$archivesubpath/$($script.Name)" -Force
                        "[$(get-logdate)] Script flyttet til: $(Resolve-Path $archivesubpath)" | Add-Content -Path $logfile
                    }
            }
            catch { "[$(get-logdate)] Fejl ved kørsel af script: $($script.Name) - $_" | Add-Content -Path $logfile}}
    } 
    else { "[$(get-logdate)] Ingen scripts fundet i $(Resolve-Path $basepath)" | Add-Content -Path $logfile }
