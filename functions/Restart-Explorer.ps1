function Restart-Explorer {
    <#
    Restarts Explorer and attempts to restore focus to the window that was in the foreground.
    Uses a unique Win32 type name to avoid Add-Type caching conflicts in the same session.
    #>

    if (-not ("Win32FocusV2" -as [type])) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class Win32FocusV2 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError=true)]
    public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);

    public const int SW_RESTORE = 9;
    public const int KEYEVENTF_KEYUP = 0x0002;
    public const byte VK_MENU = 0x12; // ALT
}
"@ | Out-Null
    }

    # Capture target window handle
    $targetHwnd = [Win32FocusV2]::GetForegroundWindow()
    if ($targetHwnd -eq [IntPtr]::Zero) {
        $targetHwnd = [Win32FocusV2]::GetConsoleWindow()
    }

    # Fallback: powershell process window handle (may be 0 in Windows Terminal)
    $psProc = Get-Process -Id $PID -ErrorAction SilentlyContinue
    $psHwnd = if ($psProc -and $psProc.MainWindowHandle -ne 0) { $psProc.MainWindowHandle } else { [IntPtr]::Zero }

    # Stop Explorer if running
    if (Get-Process -Name Explorer -ErrorAction SilentlyContinue) {
        Stop-Process -Name Explorer -Force -ErrorAction SilentlyContinue | Out-Null

        $timeoutSeconds = 8
        $sw = [Diagnostics.Stopwatch]::StartNew()
        while ((Get-Process -Name Explorer -ErrorAction SilentlyContinue) -and ($sw.Elapsed.TotalSeconds -lt $timeoutSeconds)) {
            Start-Sleep -Milliseconds 200
        }
    }

    # Start Explorer (normal start, but we will later close any spawned File Explorer windows)
    if (-not (Get-Process -Name Explorer -ErrorAction SilentlyContinue)) {
        Start-Process Explorer -ErrorAction SilentlyContinue | Out-Null
    }

    # Give the shell time to settle
    Start-Sleep -Milliseconds 500

    # Close any newly spawned File Explorer windows (prevents "Quick access" from stealing front)
    try {
        $shell = New-Object -ComObject Shell.Application
        $wins = @($shell.Windows() | Where-Object { $_.FullName -like "*\explorer.exe" })
        foreach ($w in $wins) {
            $url = $null
            try { $url = $w.LocationURL } catch {}
            if ($url) { $w.Quit() }
        }
    } catch {}

    # Focus helper
    function Set-Focus([IntPtr]$hwnd) {
        if ($hwnd -eq [IntPtr]::Zero) { return $false }

        try {
            if ([Win32FocusV2]::IsIconic($hwnd)) {
                [Win32FocusV2]::ShowWindowAsync($hwnd, [Win32FocusV2]::SW_RESTORE) | Out-Null
            }

            # Alt tap to help Win11 allow foreground switch
            [Win32FocusV2]::keybd_event([Win32FocusV2]::VK_MENU, 0, 0, 0)
            Start-Sleep -Milliseconds 25
            [Win32FocusV2]::keybd_event([Win32FocusV2]::VK_MENU, 0, [Win32FocusV2]::KEYEVENTF_KEYUP, 0)

            return [Win32FocusV2]::SetForegroundWindow($hwnd)
        } catch {
            return $false
        }
    }

    # Try focusing the originally foreground window first, then fallback
    for ($i = 0; $i -lt 25; $i++) {
        if (Set-Focus -hwnd $targetHwnd) { break }
        Start-Sleep -Milliseconds 150
    }

    if ($psHwnd -ne [IntPtr]::Zero) {
        for ($i = 0; $i -lt 15; $i++) {
            if (Set-Focus -hwnd $psHwnd) { break }
            Start-Sleep -Milliseconds 150
        }
    }
}
