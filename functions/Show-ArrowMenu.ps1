function Show-ArrowMenu {
    param(
        [string]$Title = "Select an option:",
        [array]$MenuItems,
        [string]$Banner = ""
    )

    $selectedIndex = 0
    try { [Console]::CursorVisible = $false } catch {}

    while ($true) {
        Clear-Host
        if ($Banner) {
            Write-Host "`n"
            Write-Host $Banner.TrimEnd() -ForegroundColor Blue
            Write-Host "`n"
            Write-Host "Developer: Andreas Mouritsen | Github: https://github.com/andreas6920"
            Write-Host "============================================================================="
        }
        Write-Host $Title -ForegroundColor Gray
        Write-Host "Use Up/Down Arrow keys to navigate, Enter to select.`n" -ForegroundColor DarkGray

        for ($index = 0; $index -lt $MenuItems.Count; $index++) {
            $itemText = $MenuItems[$index].Name
            if ($index -eq $selectedIndex) {
                $label = ("> {0} " -f $itemText).PadRight(58)
                Write-Host $label -ForegroundColor Black -BackgroundColor Green
            } elseif ($MenuItems[$index].Executed) {
                Write-Host "  $itemText" -ForegroundColor DarkGray
            } else {
                Write-Host "  $itemText"
            }
        }

        $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($keyInfo.VirtualKeyCode) {
            38 { if ($selectedIndex -gt 0) { $selectedIndex-- } }
            40 { if ($selectedIndex -lt $MenuItems.Count - 1) { $selectedIndex++ } }
            13 { break }
        }

        if ($keyInfo.VirtualKeyCode -eq 13) { break }
    }

    try { [Console]::CursorVisible = $true } catch {}
    return $selectedIndex
}