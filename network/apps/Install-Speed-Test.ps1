$speedTestZipUrl = 'https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip'
$tempDirectory = Join-Path ([IO.Path]::GetTempPath()) ("Ookla-Speedtest-{0}" -f [guid]::NewGuid().ToString('N'))
$zipPath = Join-Path $tempDirectory 'speedtest.zip'
$stdoutPath = Join-Path $tempDirectory 'speedtest-output.json'
$stderrPath = Join-Path $tempDirectory 'speedtest-error.txt'

try {
    Write-Host 'Testing Internet Speed' -NoNewline
    New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null
    Invoke-WebRequest -Uri $speedTestZipUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tempDirectory -Force

    $speedTestExecutable = Get-ChildItem -LiteralPath $tempDirectory -Filter 'speedtest.exe' -File -Recurse |
        Select-Object -First 1
    if (-not $speedTestExecutable) {
        throw 'The downloaded Ookla archive did not contain speedtest.exe.'
    }

    # Hide the separate console window and capture output so only the animated status is shown.
    $process = Start-Process -FilePath $speedTestExecutable.FullName `
        -ArgumentList @('--accept-license', '--accept-gdpr', '--format=json') `
        -WorkingDirectory $speedTestExecutable.DirectoryName `
        -RedirectStandardOutput $stdoutPath `
        -RedirectStandardError $stderrPath `
        -WindowStyle Hidden `
        -PassThru

    while (-not $process.HasExited) {
        Write-Host '.' -NoNewline
        Start-Sleep -Seconds 1
        $process.Refresh()
    }
    Write-Host ''

    $process.WaitForExit()
    $exitCode = $process.ExitCode
    if ($null -ne $exitCode -and $exitCode -ne 0) {
        $diagnostics = @(
            foreach ($outputPath in @($stderrPath, $stdoutPath)) {
                if (Test-Path -LiteralPath $outputPath) {
                    $output = Get-Content -LiteralPath $outputPath -Raw
                    if (-not [string]::IsNullOrWhiteSpace($output)) {
                        $output.Trim()
                    }
                }
            }
        )
        $errorMessage = "Speedtest CLI failed with exit code $exitCode."
        if ($diagnostics.Count -gt 0) {
            $errorMessage += [Environment]::NewLine + ($diagnostics -join [Environment]::NewLine)
        } else {
            $errorMessage += ' The CLI returned no diagnostic output.'
        }
        throw $errorMessage
    }

    $jsonOutput = Get-Content -LiteralPath $stdoutPath -Raw
    if ([string]::IsNullOrWhiteSpace($jsonOutput)) {
        throw 'Speedtest CLI completed without returning JSON results.'
    }
    $result = $jsonOutput | ConvertFrom-Json -ErrorAction Stop
    if ($null -eq $result.download.bandwidth -or $null -eq $result.upload.bandwidth -or $null -eq $result.ping.latency) {
        throw 'Speedtest CLI returned results without the expected download, upload, or latency values.'
    }

    # Ookla JSON reports bandwidth in bytes per second; convert to megabits per second.
    $downloadMbps = [double]$result.download.bandwidth * 8 / 1000000
    $uploadMbps = [double]$result.upload.bandwidth * 8 / 1000000
    $latency = [double]$result.ping.latency
    $jitter = if ($null -ne $result.ping.jitter) { [double]$result.ping.jitter } else { $null }

    Write-Host 'Speed Test Results' -ForegroundColor Cyan
    Write-Host ('  - Download: {0:N2} Mbps' -f $downloadMbps)
    Write-Host ('  - Upload: {0:N2} Mbps' -f $uploadMbps)
    Write-Host ('  - Latency: {0:N2} ms' -f $latency)
    if ($null -ne $jitter) {
        Write-Host ('  - Jitter: {0:N2} ms' -f $jitter)
    }
} catch {
    Write-Host ''
    throw
} finally {
    if (Test-Path -LiteralPath $tempDirectory) {
        Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}
