function Restart-Explorer {
    <#
    When explorer restarts with the regular stop-process function, the active PowerShell loses focus,
    which means you'll have to click on the window in order to enter your input. here's the hotfix.
    #>

    $windowname = $Host.UI.RawUI.WindowTitle

    # Stop Explorer if it exists
    $explorer = Get-Process -Name Explorer -ErrorAction SilentlyContinue
    if ($explorer) {
        Stop-Process -Name Explorer -Force -ErrorAction SilentlyContinue | Out-Null

        # Wait briefly for Explorer to fully exit (avoid race conditions)
        $timeoutSeconds = 5
        $sw = [Diagnostics.Stopwatch]::StartNew()
        while ((Get-Process -Name Explorer -ErrorAction SilentlyContinue) -and ($sw.Elapsed.TotalSeconds -lt $timeoutSeconds)) {
            Start-Sleep -Milliseconds 200
        }
    }

    # Start Explorer if it's not running
    if (-not (Get-Process -Name Explorer -ErrorAction SilentlyContinue)) {
        Start-Process Explorer -ErrorAction SilentlyContinue | Out-Null
    }

    # Try to refocus PowerShell window
    try {
        Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction Stop
        [Microsoft.VisualBasic.Interaction]::AppActivate($windowname) | Out-Null
    } catch {
        # Ignore focus errors, they are non-critical
    }
}
