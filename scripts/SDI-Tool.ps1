# Timestamps for actions
Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# URL til download-siden
$url = "https://sdi-tool.org/download/"

# Angiv sti til skrivebordet
$desktopPath = [System.IO.Path]::Combine([environment]::GetFolderPath("Desktop"), "SDI_Tool")

# Opret mappen, hvis den ikke allerede eksisterer
if (!(Test-Path -Path $desktopPath)) {
    New-Item -ItemType Directory -Path $desktopPath | Out-Null
}

# Hent HTML-indholdet med Invoke-RestMethod
$response = Invoke-RestMethod -Uri $url -Method Get

# Konverter HTML-indholdet til tekst
$content = $response | Out-String

# Find linket til zip-filen ved hjælp af Regex
$linkPattern = "https:\/\/sdi-tool\.org\/releases\/SDI_R\d{4}\.zip"
$match = [regex]::Match($content, $linkPattern)

if ($match.Success) {
    $zipUrl = $match.Value
    Write-Output "Fundet download-link: $zipUrl"

    # Definer stien hvor ZIP-filen skal downloades
    $zipFilePath = "$desktopPath\SDI_Tool.zip"

    # Download ZIP-filen
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
    Write-Output "Filen blev downloadet til: $zipFilePath"

    # Ekstraher ZIP-filen til skrivebordsmappen
    Expand-Archive -Path $zipFilePath -DestinationPath $desktopPath -Force
    Write-Output "Filen er blevet udpakket til: $desktopPath"

    # Slet ZIP-filen efter udpakning
    Remove-Item -Path $zipFilePath
    Write-Output "ZIP-filen er blevet slettet efter udpakning."

    # Angiv sti til SDI_auto.bat filen
    $batFilePath = [System.IO.Path]::Combine($desktopPath, "SDI_auto.bat")

    # Tjek om SDI_auto.bat filen eksisterer
    if (Test-Path -Path $batFilePath) {
        Write-Output "Starter SDI_auto.bat filen..."

        # Kør .bat filen
        Start-Process -FilePath $batFilePath -NoNewWindow -Wait
        Write-Output "SDI_auto.bat filen er blevet kørt."
    }
    else {
        Write-Output "Filen SDI_auto.bat blev ikke fundet i mappen: $desktopPath"
    }}

# Hvis der ikke findes et gyldig link, skriv en besked
else { Write-Output "Ingen gyldig link blev fundet på siden." }
