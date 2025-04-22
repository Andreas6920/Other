# Author: Andreas Mouritsen
# Description: Script til at hente og downloade SDI-Tool-fil fra sdi-tool.org

# Timestampfunktionen
Function Get-LogDate { return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]") }

$url = "https://sdi-tool.org/download/"
$FolderPath = [System.IO.Path]::Combine([environment]::GetFolderPath("CommonApplicationData"), "SDI Tool")
$ZipFilePath = "$FolderPath\SDI_Tool.zip"

# Hent HTML-indholdet med Invoke-WebRequest
$response = Invoke-WebRequest -Uri $url -UseBasicParsing
Write-Host "$(Get-LogDate)`t    Søger efter nyeste version af SDI-Tool:" -ForegroundColor Green

# Find linket til zip-filen ved hjælp af Regex
$linkPattern = "https:\/\/sdi-tool\.org\/releases\/SDI_R\d{4}\.zip"
$match = [regex]::Match($response.Content, $linkPattern)

if ($match.Success) {
    $zipUrl = $match.Value
    # Udtræk versionen fra filnavnet
    $versionMatch = [regex]::Match($zipUrl, "SDI_R(\d{4})\.zip")
    if ($versionMatch.Success) {
        $versionNumber = $versionMatch.Groups[1].Value
        # Formater versionen som x.xx.x
        $major = $versionNumber.Substring(0,1)
        $minor = $versionNumber.Substring(1,2)
        $patch = $versionNumber.Substring(3,1)
        $formattedVersion = "$major.$minor.$patch"
    } else {
        $formattedVersion = "Ukendt"
    }

    Write-Host "$(Get-LogDate)`t        - Version fundet:" -ForegroundColor Yellow
    Write-Host "$(Get-LogDate)`t            - Version: $formattedVersion" -ForegroundColor Yellow
    Write-Host "$(Get-LogDate)`t            - Link: $zipUrl" -ForegroundColor Yellow

    # Opret mappen, hvis den ikke allerede eksisterer
    if (!(Test-Path -Path $FolderPath)) {
        New-Item -ItemType Directory -Path $FolderPath | Out-Null
        Write-Host "$(Get-LogDate)`t        - Opretter mappe.." -ForegroundColor Yellow}
    else{
        Get-Process | Where-Object {$_.Name -like "SDI_x64*"} | Stop-Process -ErrorAction SilentlyContinue
        Write-Host "$(Get-LogDate)`t        - Sletter gamle filer.." -ForegroundColor Yellow
        Remove-item -Path $FolderPath\* -Recurse -force}

    # Download ZIP-filen
    Write-Host "$(Get-LogDate)`t        - Downloader.." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $zipUrl -OutFile $ZipFilePath

    # Udpakker ZIP-filen til skrivebordsmappen
    Write-Host "$(Get-LogDate)`t        - Udpakker.." -ForegroundColor Yellow
    Expand-Archive -Path $ZipFilePath -DestinationPath $FolderPath -Force

    # Slet ZIP-filen efter udpakning
    Write-Host "$(Get-LogDate)`t        - Rydder midlertidige filer op.." -ForegroundColor Yellow
    Remove-Item -Path $ZipFilePath -ErrorAction SilentlyContinue | Out-Null

    # Angiv sti til SDI_auto.bat filen
    $ExeFilePath = (Get-ChildItem $FolderPath | Where-Object {$_.Name -match 64}).FullName

    # Tjek om filen eksisterer
    if (Test-Path -Path $ExeFilePath) {
        Write-Host "$(Get-LogDate)`t    Starter Programmet..." -ForegroundColor Green
        Start-Process -FilePath $ExeFilePath -WindowStyle Minimized
    } else {
        Write-Host "$(Get-LogDate)`t    Filen blev ikke fundet i mappen: $FolderPath" -ForegroundColor Red
        Start-Sleep -Seconds 3
        Write-Host "$(Get-LogDate)`t    Åbner mappen" -ForegroundColor Red
        Start-Process $FolderPath
    }
} 

else {
    Write-Host "$(Get-LogDate)`t    Intet gyldigt link blev fundet på siden." -ForegroundColor Red
    Start-Sleep -Seconds 3}


