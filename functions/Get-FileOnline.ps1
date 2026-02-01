<#

.SYNOPSIS
Downloads a file from a specified link into a structured folder and can optionally open the folder or file after download.

.DESCRIPTION
Get-FileOnline downloads a file from an URL and stores it in a folder, created for the file.
The folder is created in a specified location such as Desktop, Temp, or ProgramData.
!! NOTE: FileName must include the file extension, like: "Installer.msi", "Program.exe", "windows.iso" etc. !!

The function supports multiple download methods including WebClient, Invoke-RestMethod,
BITS, and curl so you're able to adjust according to your systems age and support.
It always validates the link before starting the download to avoid timewaste and weird errors.

After the download completes, the function can optionally open the download folder
and or execute the downloaded file. PowerShell scripts (.ps1) are executed using
dot-sourcing, while other file types are started as standard processes.

.EXAMPLE
Get-FileOnline -Link "https://winamp.com/Winamp-latest.exe" -FileName "Winamp.exe" -OpenFileAfterDownload
- Downloads installation file and runs it.

.EXAMPLE
Get-FileOnline -Link "https://Microsoft.com/Windows11.iso" -FileName "Windows 11.exe" -OpenFolderAfterDownload
- Downloads iso file and opens the download folder created for the file.

.NOTES
Author: Andreas6920
PowerShell version: Windows PowerShell 5.1 and newer
This function is intended for interactive use and simple automation scenarios.
Link validation requires the endpoint to respond with an HTTP status code in the 200-299 range.

#>
function Get-FileOnline {
 


    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Link,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,

        [Parameter(Position = 2)]
        [ValidateSet('Desktop','Temp','ProgramData')]
        [string]$Location = 'Temp',

        [Parameter(Position = 3)]
        [ValidateSet('InvokeRestMethod','WebClientDownloadFile','BitsTransfer','Curl')]
        [string]$Method = 'WebClientDownloadFile',

        [Parameter()]
        [switch]$OpenFolderAfterDownload,

        [Parameter()]
        [switch]$OpenFileAfterDownload
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # Resolve base path from Location
    $BasePath = switch ($Location) {
        'Desktop'     { [Environment]::GetFolderPath('Desktop') }
        'Temp' { if ($env:TMP) { $env:TMP } else { $env:TEMP } }
        'ProgramData' { $env:ProgramData }}

    if ([string]::IsNullOrWhiteSpace($BasePath) -or -not (Test-Path -LiteralPath $BasePath)) {
        throw "Kunne ikke resolve Location '$Location' til en gyldig sti. Resolved BasePath: '$BasePath'"
    }

    # Build download folder: <BasePath>\<FileNameWithoutExtension>\
    $SafeFileName = [IO.Path]::GetFileName($FileName)
    if ([string]::IsNullOrWhiteSpace($SafeFileName)) {
        throw "FileName er ikke gyldigt: '$FileName'"
    }

    $FolderName = [IO.Path]::GetFileNameWithoutExtension($SafeFileName)
    if ([string]::IsNullOrWhiteSpace($FolderName)) {
        throw "Kunne ikke udlede mappenavn fra FileName: '$FileName'"
    }

    $DownloadFolder  = Join-Path -Path $BasePath -ChildPath $FolderName
    $DestinationPath = Join-Path -Path $DownloadFolder -ChildPath $SafeFileName

    # Validate URL format
    try {
        $Uri = [Uri]$Link
        if ($Uri.Scheme -notin @('http','https')) { throw }
    } catch {
        throw "Link er ikke en gyldig http/https URL: '$Link'"
    }

    # Link validation
    function Test-HttpLink {
        param([Parameter(Mandatory)][string]$TestLink)

        $ProgressPreference = 'SilentlyContinue'

        try {
            $resp = Invoke-WebRequest -Uri $TestLink -Method Head -MaximumRedirection 5 -UseBasicParsing
            return ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300)
        } catch {
            try {
                $headers = @{ Range = 'bytes=0-0' }
                $resp2 = Invoke-WebRequest -Uri $TestLink -Method Get -Headers $headers -MaximumRedirection 5 -UseBasicParsing
                return ($resp2.StatusCode -ge 200 -and $resp2.StatusCode -lt 300)
            } catch {
                return $false
            }
        } finally {
            $ProgressPreference = 'Continue'
        }
    }

    if (-not (Test-HttpLink -TestLink $Link)) {
        throw "Link validering fejlede. URL svarer ikke med succes status (200-299): '$Link'"
    }

    # Create folder
    New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null

    # Download
    try {
        switch ($Method) {
            'InvokeRestMethod' {
                Invoke-RestMethod -Uri $Link -OutFile $DestinationPath
            }
            'WebClientDownloadFile' {
                $wc = New-Object System.Net.WebClient
                try { $wc.DownloadFile($Link, $DestinationPath) }
                finally { $wc.Dispose() }
            }
            'BitsTransfer' {
                if (-not (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue)) {
                    throw "Start-BitsTransfer er ikke tilgængelig."
                }
                Start-BitsTransfer -Source $Link -Destination $DestinationPath
            }
            'Curl' {
                $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
                if (-not $curl) { throw "curl.exe findes ikke." }

                & $curl.Source -L --fail -o $DestinationPath $Link | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    throw "curl fejlede med exitcode $LASTEXITCODE"
                }
            }
        }
    } catch {
        throw "Download fejlede via metode '$Method'. Fejl: $($_.Exception.Message)"
    }
    
    # Output
    [PSCustomObject]@{
        Link            = $Link
        Method          = $Method
        DownloadFolder  = $DownloadFolder
        DestinationPath = $DestinationPath
    } | Format-List

    # Post actions
    if ($OpenFolderAfterDownload) {
        Invoke-Item -LiteralPath $DownloadFolder
    }

    if ($OpenFileAfterDownload) {
        $Ext = [IO.Path]::GetExtension($DestinationPath)
        if ($null -eq $Ext) { $Ext = '' }
        $Ext = $Ext.ToLowerInvariant()

        if ($Ext -eq '.ps1') {
            . $DestinationPath
        } else {
            Write-Host "Executing..." -NoNewline
            Start-Process -FilePath $DestinationPath | Out-Null
            Start-Sleep -Seconds 2
            Write-Host ""
        }
    }
    
}
