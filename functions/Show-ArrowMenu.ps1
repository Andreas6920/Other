function Show-ArrowMenu {
    param(
        [string]$Title = "Select an option:",
        [array]$MenuItems,
        [string]$Banner = "",
        [scriptblock]$Header,
        [switch]$Separator
    )

    $selectedIndex = 0
    $usePromptFallback = $false
    try { [Console]::CursorVisible = $false } catch {}

    while ($true) {
        Clear-Host
        if ($Header) {
            & $Header
            Write-Host ""
        }
        if ($Banner) {
            Write-Host "`n"
            Write-Host $Banner.TrimEnd() -ForegroundColor Cyan
            Write-Host "`n"
            Write-Host "Developer: Andreas Mouritsen | Github: https://github.com/andreas6920"
            Write-Host "TIP: Use Up/Down Arrow keys to navigate, Enter to select." -ForegroundColor Cyan
            Write-Host ""
            Write-Host "============================================================================="
            Write-Host ""
        } else {
            Write-Host "TIP: Use Up/Down Arrow keys to navigate, Enter to select." -ForegroundColor DarkGray
        }
        if ($Separator) {
            Write-Host ""
            Write-Host "================================================================" -ForegroundColor DarkGray
            Write-Host ""
        }
        if ($Title) {
            Write-Host $Title -ForegroundColor Gray
        }

        for ($index = 0; $index -lt $MenuItems.Count; $index++) {
            $itemText = $MenuItems[$index].Name
            if ($usePromptFallback) {
                Write-Host ("  {0}. {1}" -f ($index + 1), $itemText)
            } elseif ($index -eq $selectedIndex) {
                $label = ("> {0} " -f $itemText).PadRight(58)
                Write-Host $label -ForegroundColor Black -BackgroundColor Cyan
            } elseif ($MenuItems[$index].Executed) {
                Write-Host "  $itemText" -ForegroundColor DarkGray
            } else {
                Write-Host "  $itemText"
            }
        }

        if ($usePromptFallback) {
            $choice = Read-Host 'Enter the number of your choice'
            $choiceNumber = 0
            if ([int]::TryParse($choice, [ref]$choiceNumber) -and $choiceNumber -ge 1 -and $choiceNumber -le $MenuItems.Count) {
                $selectedIndex = $choiceNumber - 1
                break
            }
            Write-Host 'Invalid selection. Enter one of the listed numbers.' -ForegroundColor Yellow
            continue
        }

        try {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } catch {
            $usePromptFallback = $true
            continue
        }

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