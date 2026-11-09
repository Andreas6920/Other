$ErrorActionPreference = 'Stop'

function Install-WizTree {
    $downloadPage = 'https://diskanalyzer.com/download'
    $tempPath = [System.IO.Path]::GetTempPath()
    $desktopPath = [Environment]::GetFolderPath('Desktop')

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $html = Invoke-WebRequest -Uri $downloadPage -UseBasicParsing
    $fileUrl = ($html.Links | Where-Object { $_.href -match 'portable\.zip$' } | Select-Object -First 1).href
    if (-not $fileUrl) { throw 'Could not find the WizTree portable download link.' }
    if ($fileUrl -notmatch '^https?://') { $fileUrl = "https://diskanalyzer.com/$($fileUrl.TrimStart('/'))" }

    $zipFile = Join-Path $tempPath ([System.IO.Path]::GetFileName($fileUrl))
    $extractFolder = Join-Path $desktopPath ([System.IO.Path]::GetFileNameWithoutExtension($zipFile))

    try {
        $webClient = New-Object Net.WebClient
        try { $webClient.DownloadFile($fileUrl, $zipFile) }
        finally { $webClient.Dispose() }

        $exe = $null
        if (Test-Path -LiteralPath $extractFolder) {
            $exe = Get-ChildItem -Path $extractFolder -Filter 'WizTree64.exe' -Recurse | Select-Object -First 1
            if (-not $exe) {
                $exe = Get-ChildItem -Path $extractFolder -Filter 'WizTree.exe' -Recurse | Select-Object -First 1
            }
        }

        if (-not $exe) {
            if (Test-Path -LiteralPath $extractFolder) {
                $extractFolder = Join-Path $desktopPath ("{0}_{1}" -f [System.IO.Path]::GetFileNameWithoutExtension($zipFile), [guid]::NewGuid().ToString('N'))
            }

            Expand-Archive -LiteralPath $zipFile -DestinationPath $extractFolder
            $exe = Get-ChildItem -Path $extractFolder -Filter 'WizTree64.exe' -Recurse | Select-Object -First 1
            if (-not $exe) {
                $exe = Get-ChildItem -Path $extractFolder -Filter 'WizTree.exe' -Recurse | Select-Object -First 1
            }
        }

        if (-not $exe) { throw 'Could not find WizTree.exe in the downloaded archive.' }
        Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName
    }
    finally {
        Remove-Item -LiteralPath $zipFile -Force -ErrorAction SilentlyContinue
    }
}

Install-WizTree
