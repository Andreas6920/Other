$mirrorPageUrl = 'https://www.majorgeeks.com/mg/getmirror/complete_internet_repair,1.html'
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$tempScript = Join-Path ([IO.Path]::GetTempPath()) ("CompleteInternetRepair-{0}.exe" -f [guid]::NewGuid().ToString('N'))

try {
    $mirrorPage = Invoke-WebRequest -Uri $mirrorPageUrl -WebSession $webSession -UseBasicParsing -ErrorAction Stop
    # The download URL is session-specific, so reuse the mirror page's web session.
    $downloadLinkMatch = [regex]::Match($mirrorPage.Content, '(?is)<a\s+href="([^"]*action=download[^"]*)"[^>]*>\s*<img[^>]*click_here')
    if (-not $downloadLinkMatch.Success) {
        throw 'Could not find the MajorGeeks click-here download link.'
    }

    $downloadPath = [System.Net.WebUtility]::HtmlDecode($downloadLinkMatch.Groups[1].Value)
    $downloadUrl = [uri]::new([uri]'https://www.majorgeeks.com/', $downloadPath)
    Invoke-WebRequest -Uri $downloadUrl -WebSession $webSession -OutFile $tempScript -UseBasicParsing -ErrorAction Stop

    $stream = [IO.File]::OpenRead($tempScript)
    try {
        $reader = New-Object IO.BinaryReader($stream)
        if ($reader.ReadUInt16() -ne 0x5A4D) {
            throw 'The downloaded file is not a Windows executable.'
        }

        $stream.Position = 0x3C
        $peOffset = $reader.ReadInt32()
        if ($peOffset -lt 0 -or $peOffset -gt ($stream.Length - 4)) {
            throw 'The downloaded executable has an invalid PE header.'
        }

        $stream.Position = $peOffset
        if ([BitConverter]::ToString($reader.ReadBytes(4)) -ne '50-45-00-00') {
            throw 'The downloaded executable has an invalid PE signature.'
        }
    } finally {
        $stream.Dispose()
    }

    Write-Host 'Complete Internet Repair has been downloaded from MajorGeeks.' -ForegroundColor Cyan
    Write-Warning 'This tool can change Windows network settings. Only run it if you intend to repair a network problem.'
    $confirmation = Read-Host 'Run Complete Internet Repair now? [y/N]'
    if ($confirmation -notmatch '^(y|yes)$') {
        Write-Host 'Execution cancelled.'
        return
    }

    Start-Process -FilePath $tempScript -Wait
} finally {
    Remove-Item -LiteralPath $tempScript -Force -ErrorAction SilentlyContinue
}
