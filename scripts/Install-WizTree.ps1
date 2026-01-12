function Install-WizTree {

$ErrorActionPreference = 'Stop'

# Konfiguration
    $DownloadPage = 'https://diskanalyzer.com/download'
    $TempPath     = [System.IO.Path]::GetTempPath()
    $DesktopPath  = [Environment]::GetFolderPath('Desktop')

# Grab link from official website that includes portable.zip
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Html = Invoke-WebRequest -Uri $DownloadPage -UseBasicParsing
    $FileUrl = ($Html.Links | Where-Object { $_.href -match 'portable\.zip$' }).href

# Format URL
    if ($FileUrl -notmatch '^http') { $FileUrl = "https://diskanalyzer.com/$FileUrl" }

# Download to temp
    $zipFile = Join-Path $TempPath ([System.IO.Path]::GetFileName($FileUrl))
    Invoke-WebRequest -Uri $FileUrl -OutFile $zipFile

# Extract folder to desktop
    $extractFolder = Join-Path $DesktopPath ([System.IO.Path]::GetFileNameWithoutExtension($zipFile))
    Expand-Archive -LiteralPath $zipFile -DestinationPath $extractFolder -Force

# Find and execute rekursivt og eksekver
    $exe = Get-ChildItem -Path $extractFolder -Filter 'WizTree64.exe' -Recurse | Select-Object -First 1
    if ($exe) {Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName}
    else {
        $exe32 = Get-ChildItem -Path $extractFolder -Filter 'WizTree.exe' -Recurse | Select-Object -First 1
        if ($exe32) {Start-Process -FilePath $exe32.FullName -WorkingDirectory $exe32.DirectoryName}}

# Clean up
    Remove-Item $zipFile -Force -ErrorAction SilentlyContinue | Out-Null


}