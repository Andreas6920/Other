<#
.SYNOPSIS
Downloads an online archive and extracts it into a folder named after the archive.

.DESCRIPTION
Get-ZipOnline downloads a container file from a given URL using
System.Net.WebClient.DownloadFile and extracts its contents into a folder
named after the archive file (without extension).

The extraction method is determined automatically:
- Native Expand-Archive is used for standard .zip files without a password.
- 7Zip4PowerShell is used if the archive is not a .zip file or if a password is provided.

7Zip4PowerShell and its NuGet provider are installed silently for the current user
when needed.

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
- Temp ($TMP - if not exists - $TEMP)
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
Get-ZipOnline -Link "https://example.com/tools.zip" -ZipName "tools.zip"

Downloads tools.zip to the Temp folder and extracts it.

.EXAMPLE
Get-ZipOnline -Link "https://example.com/package.7z" -ZipName "package.7z" -OpenZipFolder

Downloads and extracts a 7z archive using 7-Zip and opens the extracted folder.

.EXAMPLE
Get-ZipOnline -Link "https://example.com/secure.zip" -ZipName "secure.zip" -Password "Secret123" -OpenExtractedFile "setup.exe"

Downloads an encrypted archive, extracts it using 7-Zip, recursively searches
for setup.exe, and opens it.

.NOTES
- Uses System.Net.WebClient for download to maintain compatibility with legacy scripts and environments.
- 7Zip4PowerShell is installed automatically if required.
- Recursive file search opens the first matching result found.

#>


function Import-7Zip4PowerShell {
    if (Get-Module -Name 7Zip4PowerShell) { return }

    if (-not (Get-Module -ListAvailable -Name 7Zip4PowerShell)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

        if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force -Confirm:$false -ErrorAction Stop | Out-Null
        }

        Install-Module -Name 7Zip4PowerShell -Repository PSGallery -Scope CurrentUser -Force -Confirm:$false -ErrorAction Stop | Out-Null
    }

    Import-Module -Name 7Zip4PowerShell -ErrorAction Stop
}

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
    $BasePath = switch ($Location) {
        "Temp"      { if ($env:TMP) { $env:TMP } elseif ($env:TEMP) { $env:TEMP } else { [IO.Path]::GetTempPath() } }
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

    if (Test-Path -LiteralPath $ExtractFolder) {
        $ExtractFolder = Join-Path $BasePath ("{0}_{1}" -f [IO.Path]::GetFileNameWithoutExtension($ZipName), [guid]::NewGuid().ToString('N'))
    }
    New-Item -ItemType Directory -Path $ExtractFolder -Force | Out-Null

    # Download file from link
    $wc = New-Object net.webclient
    try { $wc.DownloadFile($Link, $ZipPath) }
    finally { $wc.Dispose() }

    # if not plain and simple operation, use 7zip
    $IsZip  = $ZipName -match '\.zip$'
    $Use7Zip = (-not $IsZip) -or -not [string]::IsNullOrEmpty($Password)

    if ($Use7Zip) {
        Import-7Zip4PowerShell
        $ExpandParameters = @{
            ArchiveFileName = $ZipPath
            TargetPath = $ExtractFolder
            ErrorAction = 'Stop'
        }
        if ($Password) { $ExpandParameters.Password = $Password }
        Expand-7Zip @ExpandParameters
    }
        
    else { Expand-Archive -Path $ZipPath -DestinationPath $ExtractFolder -ErrorAction Stop }

    # Post actions

        # Open folder
        if ($OpenZipFolder) { invoke-item $ExtractFolder}

        # Open file within folder
        if ($OpenExtractedFile) {
            $Target = Get-ChildItem -Path $ExtractFolder -Recurse -Filter $OpenExtractedFile -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($Target) { Start-Process $Target.FullName }
        else { Write-Warning "File '$OpenExtractedFile' not found in extracted content."}}

    # Output
    [PSCustomObject]@{
        ZipFile     = $ZipPath
        ExtractedTo = $ExtractFolder
        Used7Zip    = $Use7Zip
    } | Format-List
}
