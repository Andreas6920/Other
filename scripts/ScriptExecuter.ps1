# Version 1.0

$ScriptRoot = Join-Path $Env:ProgramData "AM"
$ExecutePath = Join-Path $ScriptRoot "Execute"
$ExecuteFile = Join-Path $ExecutePath "ScriptExecuter.ps1"
$ExecuteUrl = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ScriptExecuter.ps1"
$ArchivePath = Join-Path $ScriptRoot "Archive"
$LogPath = Join-Path $ScriptRoot "Logs"
$LogFile = Join-Path $LogPath "ScriptLog.txt"
Function Get-LogDate { return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]") }

# Ensure folder structure exists and check if ScriptExecuter.ps1 exists
  foreach ($path in @($ExecutePath, $ArchivePath, $LogPath)) {
    if (!(Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }}

# Check if ScriptExecuter.ps1 is missing and download it
  if (!(Test-Path $ExecuteFile)) {
    (New-Object net.webclient).Downloadfile($ExecuteUrl, $ExecuteFile)}

# Check for self-update from online source
  $OnlineVersion = (Invoke-WebRequest -Uri $ExecuteUrl -UseBasicParsing).Content.Split("`n")[0]
  $LocalVersion = Get-Content $ExecuteFile -TotalCount 1
  
  if ($OnlineVersion -ne $LocalVersion) {
      Add-Content $LogFile "$(Get-LogDate)`tNEW UPDATE DETECTED!"
      Add-Content $LogFile "$(Get-LogDate)`t    Local version: $($LocalVersion)"
      Add-Content $LogFile "$(Get-LogDate)`t    Online version: $($OnlineVersion)"
      (New-Object net.webclient).Downloadfile($ExecuteUrl, $ExecuteFile) | Out-Null
      Add-Content $LogFile "$(Get-LogDate)`t    Script updated."

    # Restart the updated script and exit current one
      Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$ExecuteFile`"" -WindowStyle Hidden
      Add-Content $LogFile "$(Get-LogDate)`t    - Relaunching updated script and exiting current instance."
      exit}

# Check for scripts in root folder
  $Scripts = Get-ChildItem -Path $ScriptRoot -Filter "*.ps1" -File | Where-Object { $_.Name -ne "ScriptExecuter.ps1" }

  if ($Scripts.Count -eq 0) { return }
  foreach ($Script in $Scripts) {
      $ScriptHash = (Get-FileHash -Path $Script.FullName -Algorithm SHA256).Hash
      $Timestamp = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
      $ArchiveFolder = Join-Path $ArchivePath $Timestamp

      # Logs
      Add-Content $LogFile "$(Get-LogDate)`tNEW SCRIPT DETECTED!"
      Add-Content $LogFile "$(Get-LogDate)`t    Information: $($Script.Name)"
      Add-Content $LogFile "$(Get-LogDate)`t        - Name: $($Script.Name)"
      Add-Content $LogFile "$(Get-LogDate)`t        - Hash: $ScriptHash"
      Add-Content $LogFile "$(Get-LogDate)`t    Script execution initiated."

      # Execute the script using dot-sourcing
      & $Script.FullName
      Add-Content $LogFile "$(Get-LogDate)`t    Script execution finished."

      # Archive script
      if (!(Test-Path $ArchiveFolder)) { New-Item -ItemType Directory -Path $ArchiveFolder | Out-Null }
      Move-Item -Path $Script.FullName -Destination $ArchiveFolder
      Add-Content $LogFile "$(Get-LogDate)`t    Script moved to $ArchiveFolder"
      Add-Content $LogFile "#######################################################################################################"
  } 
