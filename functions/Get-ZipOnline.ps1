<#
.SYNOPSIS
Downloads an online archive and extracts it into a folder named after the archive.

.DESCRIPTION
Get-ZipOnline downloads a container file from a given URL using
System.Net.WebClient.DownloadFile and extracts its contents into a folder
named after the archive file (without extension).

The extraction method is determined automatically:
- Native Expand-Archive is used for standard .zip files without a password.
- 7-Zip is used if the archive is not a .zip file or if a password is provided.

If 7-Zip is not installed, the function will download and install it silently
using the official installer.

The function also supports opening the extracted folder or locating and opening
a specific file inside the extracted content using a recursive search.

.PARAMETER Link
The direct URL to the archive file that should be downloaded.

.PARAMETER ZipName
The name of the archive file as it should be saved locally.
This parameter is mandatory and is not derived from the URL.

.PARAMETER Location
Specifies the base destination folder.
Valid values are:
- Temp
- Downloads
- Desktop
- Custom

Default is Temp.

.PARAMETER CustomPath
Custom destination path.
Required when Location is set to Custom.

.PARAMETER Password
Password used to extract encrypted archives.
When specified, extraction is always handled by 7-Zip.

.PARAMETER OpenZipFolder
Opens the extracted folder in File Explorer after extraction.

.PARAMETER OpenExtractedFile
Specifies a file name to locate inside the extracted folder.
The function performs a recursive search and opens the first match found.

.EXAMPLE
Get-ZipOnline `
    -Link "https://example.com/tools.zip" `
    -ZipName "tools.zip"

Downloads tools.zip to the Temp folder and extracts it.

.EXAMPLE
Get-ZipOnline `
    -Link "https://example.com/package.7z" `
    -ZipName "package.7z" `
    -OpenZipFolder

Downloads and extracts a 7z archive using 7-Zip and opens the extracted folder.

.EXAMPLE
Get-ZipOnline `
    -Link "https://example.com/secure.zip" `
    -ZipName "secure.zip" `
    -Password "Secret123" `
    -OpenExtractedFile "setup.exe"

Downloads an encrypted archive, extracts it using 7-Zip, recursively searches
for setup.exe, and opens it.

.NOTES
- Uses System.Net.WebClient for download to maintain compatibility with
  legacy scripts and environments.
- 7-Zip is installed automatically if required.
- Recursive file search opens the first matching result found.

#>


function Get-ZipOnline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Link,

        [Parameter(Mandatory)]
        [string]$ZipName,

        [ValidateSet("Temp","Downloads","Desktop","Custom")]
        [string]$Location = "Temp",

        [string]$CustomPath,

        [string]$Password,

        [switch]$OpenZipFolder,

        [string]$OpenExtractedFile
    )

    # Resolve base path
    switch ($Location) {
        "Temp"      { if ($env:TMP) { $env:TMP } else { $env:TEMP } }
        "Downloads" { $BasePath = [Environment]::GetFolderPath("Downloads") }
        "Desktop"   { $BasePath = [Environment]::GetFolderPath("Desktop") }
        "Custom"    {
                        if (-not $CustomPath) {
                        throw "CustomPath must be specified when Location is Custom."}
                        $BasePath = $CustomPath}
    }

    $ZipName       = $ZipName -replace '[\\/:*?"<>|]', '_'
    $ZipPath       = Join-Path $BasePath $ZipName
    $ExtractFolder = Join-Path $BasePath ([IO.Path]::GetFileNameWithoutExtension($ZipName))

    # Create folder for extraction
    if (-not (Test-Path $ExtractFolder)) { New-Item -ItemType Directory -Path $ExtractFolder -Force | Out-Null}

    # Download file from link
    try {(New-Object net.webclient).Downloadfile($link, $ZipPath)}
    finally {if ($wc) { $wc.Dispose() }}

    # if not plain and simple operation, use 7zip
    $IsZip  = $ZipName -match '\.zip$'
    $Use7Zip = (-not $IsZip) -or $Password

        # Determined to use 7zip
        if ($Use7Zip) {

            # Locate or install 7-Zip (your method)
            $7zip = (Get-ChildItem -Path "C:\Program Files\7-Zip\", "C:\Program Files (x86)\7-Zip\" `
                    -Recurse -Filter "7z.exe" -ErrorAction SilentlyContinue).FullName

            # If 7zip is not installed - install it
            if (-not $7zip) {
                $dlurl = 'https://7-zip.org/' + (
                    Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' |
                    Select-Object -ExpandProperty Links |
                    Where-Object {
                        ($_.outerHTML -match 'Download') -and
                        ($_.href -like "a/*") -and
                        ($_.href -like "*-x64.exe")
                    } |
                    Select-Object -First 1 -ExpandProperty href
                )

                $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
                (New-Object System.Net.WebClient).DownloadFile($dlurl, $installerPath)
                Start-Process -FilePath $installerPath -ArgumentList "/S" -Verb RunAs -Wait
                Remove-Item $installerPath -Force
            }

            $7zip = (Get-ChildItem -Path "C:\Program Files\7-Zip\", "C:\Program Files (x86)\7-Zip\" `
                    -Recurse -Filter "7z.exe" -ErrorAction SilentlyContinue).FullName

            if (-not $7zip) { throw "7-Zip could not be located."}

            $Arguments = @(
                "x"
                "`"$ZipPath`""
                "-o`"$ExtractFolder`""
                "-y"
            )

            if ($Password) { $Arguments += "-p$Password"}

            Start-Process -FilePath $7zip -ArgumentList $Arguments -Wait -NoNewWindow}
        
        # Determined to use standard Microsoft function
        else { Expand-Archive -Path $ZipPath -DestinationPath $ExtractFolder -Force }

    # Post actions

        # Open folder
        if ($OpenZipFolder) { invoke-item $ExtractFolder}

        # Open file within folder
        if ($OpenExtractedFile) {
            $Target = Get-ChildItem -Path $ExtractFolder -Recurse -Filter $OpenExtractedFile -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($Target) { Start-Process $Target.FullName }
        else { Write-Warning "File '$OpenExtractedFile' not found in extracted content."}
    }

    # Output
    [PSCustomObject]@{
        ZipFile     = $ZipPath
        ExtractedTo = $ExtractFolder
        Used7Zip    = $Use7Zip
    } | Format-List
}
