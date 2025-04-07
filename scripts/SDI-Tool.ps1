# Author: Andreas Mouritsen
# Description: Script til at hente og downloade SDI-Tool-fil fra sdi-tool.org

# Timestampfunktionen
Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# URL til download-siden
$url = "https://sdi-tool.org/download/"

# Angiv sti til skrivebordet
$desktopPath = [System.IO.Path]::Combine([environment]::GetFolderPath("Desktop"), "SDI_Tool")

# Opret mappen, hvis den ikke allerede eksisterer
if (!(Test-Path -Path $desktopPath)) {New-Item -ItemType Directory -Path $desktopPath | Out-Null}
Write-Host "$(Get-LogDate)`t    Opretter mappe til download på skrivebordet..." -ForegroundColor Green

# Hent HTML-indholdet med Invoke-RestMethod
$response = Invoke-RestMethod -Uri $url -Method Get
Write-Host "$(Get-LogDate)`t    Henter HTML-indhold fra: $url" -ForegroundColor Green

# Konverter HTML-indholdet til tekst
$content = $response | Out-String

# Find linket til zip-filen ved hjælp af Regex
$linkPattern = "https:\/\/sdi-tool\.org\/releases\/SDI_R\d{4}\.zip"
$match = [regex]::Match($content, $linkPattern)

if ($match.Success) {
    $zipUrl = $match.Value
    Write-Host "$(Get-LogDate)`t    Fundet download-link: $zipUrl" -ForegroundColor Green

    # Definer stien hvor ZIP-filen skal downloades
    $zipFilePath = "$desktopPath\SDI_Tool.zip"

    # Download ZIP-filen
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
    Write-Host "$(Get-LogDate)`t    Filen blev downloadet til: $zipFilePath" -ForegroundColor Green

    # Ekstraher ZIP-filen til skrivebordsmappen
    Expand-Archive -Path $zipFilePath -DestinationPath $desktopPath -Force
    Write-Host "$(Get-LogDate)`t    Filen er blevet udpakket til: $desktopPath" -ForegroundColor Green

    # Slet ZIP-filen efter udpakning
    Remove-Item -Path $zipFilePath
    Write-Host "$(Get-LogDate)`t    ZIP-filen er blevet slettet efter udpakning." -ForegroundColor Green

    # Angiv sti til SDI_auto.bat filen
    $batFilePath = [System.IO.Path]::Combine($desktopPath, "SDI_auto.bat")

    # Tjek om SDI_auto.bat filen eksisterer
    if (Test-Path -Path $batFilePath) {
        Write-Host "$(Get-LogDate)`t    Starter SDI_auto.bat filen..." -ForegroundColor Green

        # Kør .bat filen
        Start-Process -FilePath $batFilePath -NoNewWindow -Wait
        Write-Host "$(Get-LogDate)`t    SDI_auto.bat filen er blevet kørt." -ForegroundColor Green}
    else {
        Write-Host "$(Get-LogDate)`t    Filen SDI_auto.bat blev ikke fundet i mappen: $desktopPath" -ForegroundColor Green}} 

else { Write-Host "$(Get-LogDate)`t    Ingen gyldig link blev fundet på siden." -ForegroundColor Green }
