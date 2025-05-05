# Version 1.0

$ScriptRoot = Join-Path $Env:ProgramData "Script"
$ExecutePath = Join-Path $ScriptRoot "Execute"
$ExecuteFile = Join-Path $ExecutePath "ScriptExecuter.ps1"
$ExecuteUrl = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
$ArchivePath = Join-Path $ScriptRoot "Archive"
$LogPath = Join-Path $ScriptRoot "Logs"
$LogFile = Join-Path $LogPath "ScriptLog.txt"
Function Get-LogDate { return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]") }

# Ensure folder structure exists and check if ScriptExecuter.ps1 exists
foreach ($path in @($ExecutePath, $ArchivePath, $LogPath)) {
  if (!(Test-Path $path)) {New-Item -ItemType Directory -Path $path | Out-Null}}

# Check if ScriptExecuter.ps1 is missing and download it
if (!(Test-Path $ExecuteFile)) {(New-Object net.webclient).Downloadfile($ExecuteUrl, $ExecuteFile)}

# Check for self-update from online source
$OnlineVersion = (Invoke-WebRequest -Uri $ExecuteUrl -UseBasicParsing).Content.Split("`n")[0]
$LocalVersion = Get-Content $ExecuteFile -TotalCount 1
if ($OnlineVersion -ne $LocalVersion) {
    Add-Content $LogFile "$(Get-LogDate)`tNew update detected!"
    Add-Content $LogFile "$(Get-LogDate)`t    - Local version: $($LocalVersion)"
    Add-Content $LogFile "$(Get-LogDate)`t    - Online version: $($OnlineVersion)"
    (New-Object net.webclient).Downloadfile($ExecuteUrl, $ExecuteFile) | Out-Null
    Add-Content $LogFile "$(Get-LogDate)`tScript updated"

    # Restart the updated script and exit current one
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$ExecuteFile`"" -WindowStyle Hidden
    Add-Content $LogFile "$(Get-LogDate)`t    - Relaunching updated script and exiting current instance."
    exit}

# Check for scripts in root folder
$ScriptFiles = Get-ChildItem -Path $ScriptRoot -Filter "*.ps1" -File

if ($ScriptFiles.Count -eq 0) { return }

foreach ($Script in $ScriptFiles) {
    $ScriptHash = (Get-FileHash -Path $Script.FullName -Algorithm SHA256).Hash
    $LogEntry = Get-Content $LogFile -ErrorAction SilentlyContinue | Select-String -Pattern $ScriptHash

    if (-not $LogEntry) {
        # Timestamp for archiving before script starts
        $timestamp = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
        $ArchiveFolder = Join-Path $ArchivePath $timestamp

        # Logs
        Add-Content $LogFile "$(Get-LogDate)`tNew script detected!"
        Add-Content $LogFile "$(Get-LogDate)`t    - Information:"
        Add-Content $LogFile "$(Get-LogDate)`t        - Name: $($Script.Name)"
        Add-Content $LogFile "$(Get-LogDate)`t        - Hash: $ScriptHash"

        # Execution
        Add-Content $LogFile "$(Get-LogDate)`t    - Script execution initiated"
        $ExecutionTimestamp = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"

        # Start the script as a job with timeout protection
      $ScriptPath
        } -ArgumentList $Script.FullName

        $JobCompleted = $Job | Wait-Job -Timeout (90 * 60)  # 1.5 hours in seconds

        if (-not $JobCompleted) {
            Stop-Job $Job -Force
            Remove-Job $Job
            Add-Content $LogFile "$(Get-LogDate)`t    - Script exceeded max execution time and was terminated."
            Remove-Item $Script.FullName -Force
            Add-Content $LogFile "$(Get-LogDate)`t    - Script deleted due to timeout protection."
            continue} 
        else {
            Receive-Job $Job | Out-Null
            Remove-Job $Job
            Add-Content $LogFile "$(Get-LogDate)`t    - Script execution finished"}

        # Archive script
        $ArchiveFolder = Join-Path $ArchivePath $ExecutionTimestamp
        if (!(Test-Path $ArchiveFolder)) { New-Item -ItemType Directory -Path $ArchiveFolder | Out-Null }
        Move-Item -Path $Script.FullName -Destination $ArchiveFolder
        Add-Content $LogFile "$(Get-LogDate)`t    - Script moved to $ArchiveFolder"
        Add-Content $LogFile "################################################################################"
    }
} 

# End of script


<# Version 1.0

# Klargør systemet

    # Konfiguration
    $ScriptRoot = "C:\Script"
    $ArchivePath = Join-Path $ScriptRoot "Archive"
    $ExecutePath = Join-Path $ScriptRoot "Execute"
    $ExecuteFile = Join-Path $executepath "ScriptExecuter.ps1"
    $ExecuteUrl = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/scriptexecuter.ps1"
    $LogPath = Join-path $ScriptRoot "Logs"
    $LogFile = Join-Path $LogPath "ScriptLog.txt"
    Function Get-LogDate { return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]") }

    # Kontrollere at mapperne eksistere
    $folders = @($ArchivePath, $LogPath)
    foreach ($folder in $folders) {if (!(Test-Path $folder)) {New-Item -ItemType Directory -Path $folder -Force | Out-Null}}

# Executer searching for update
    $OnlineVersion = (Invoke-WebRequest -Uri $ExecuteUrl -UseBasicParsing).Content.Split("`n")[0]
    $LocalVersion = Get-Content $ExecuteFile -TotalCount 1
    if ($OnlineVersion -ne $LocalVersion) { 
        Add-Content $LogFile "$(Get-LogDate)`tNew update detected!"
        Add-Content $LogFile "$(Get-LogDate)`t    - Local version: $($LocalVersion)"
        Add-Content $LogFile "$(Get-LogDate)`t    - Online version: $($OnlineVersion)"
        (New-Object net.webclient).Downloadfile("$ExecuteUrl", "$ExecutePath") | Out-Null
        Add-Content $LogFile "$(Get-LogDate)`t    - Script updated"}
        



    # Hent online scriptets første linje (Tager højde for æ, ø, å)
        try     {   $onlinescript = irm -Uri $ExecuteUrl; $onlinefirstline = $script.Split("`n")[0]}
        catch   { "[$(get-logdate)] Fejl ved hentning af script fra $ExecuteUrl - $_" | Add-Content -Path $LogFile;}

    # Hent lokal scriptets første linje
        if (Test-Path $ExecuteFile) { $localfirstline = (Get-Content $ExecuteFile -First 1 -Encoding UTF8)}
        else { $localfirstline = ""}

    # Opdater scriptet, hvis online versionen er anderledes
        if ($onlinefirstline -ne $localfirstline) { 
            "[$(get-logdate)] Opdatering fundet:" | Add-Content -Path $LogFile
            "[$(get-logdate)]`t`tOnline version: $onlinefirstline" | Add-Content -Path $LogFile
            "[$(get-logdate)]`t`tLokal version: $localfirstline" | Add-Content -Path $LogFile
            $onlinescript | Set-Content -Path $ExecuteFile -Encoding UTF8
            "[$(get-logdate)] Script opdateret fra online kilde" | Add-Content -Path $LogFile}


# Kør Script

    # Tjek for nye scripts i C:/script
    $scripts = Get-ChildItem -Path $basepath -Filter "*.ps1" -File

    # Kør scriptet
    if ($scripts.Count -gt 0) {
        $timestamp = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
        $archivesubpath = "$ArchivePath/$timestamp"
        New-Item -ItemType Directory -Path $archivesubpath -Force | Out-Null
        
        foreach ($script in $scripts) {
            try {   $starttime = get-logdate
                    "[$starttime] Kører script: $($script.Name)" | Add-Content -Path $LogFile
                    
                    # Start scriptet i separat proces med timeout
                    $proc = Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$($script.FullName)`"" -PassThru -NoNewWindow
                    $timeout = 3600  # Timeout i sekunder (60 minutter)
                    
                    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                    while ($proc.HasExited -eq $false -and $stopwatch.Elapsed.TotalSeconds -lt $timeout) {
                        Start-Sleep -Seconds 1
                    }
                    
                    if ($proc.HasExited -eq $false) {
                        Stop-Process -Id $proc.Id -Force
                        "[$(get-logdate)] Script timeout: $($script.Name) blev tvunget til at stoppe" | Add-Content -Path $LogFile
                        Remove-Item -Path $script.FullName -Force
                        "[$(get-logdate)] Script slettet: $($script.Name)" | Add-Content -Path $LogFile
                    } else {
                        $endtime = get-logdate
                        "[$endtime] Færdig med at køre script: $($script.Name)" | Add-Content -Path $LogFile
                        
                        Move-Item -Path $script.FullName -Destination "$archivesubpath/$($script.Name)" -Force
                        "[$(get-logdate)] Script flyttet til: $(Resolve-Path $archivesubpath)" | Add-Content -Path $LogFile
                    }
            }
            catch { "[$(get-logdate)] Fejl ved kørsel af script: $($script.Name) - $_" | Add-Content -Path $LogFile}}
    } 
    else { "[$(get-logdate)] Ingen scripts fundet i $(Resolve-Path $basepath)" | Add-Content -Path $LogFile }
#>