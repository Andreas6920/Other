function Get-Activated {
    [CmdletBinding()]
    param(
        [switch]$Windows,
        [switch]$Office,
        [switch]$WindowsAndOffice
    )

    if (-not ($Windows -or $Office -or $WindowsAndOffice)) {

        Write-Host ""
        Write-Host "Select an option:" -ForegroundColor Cyan
        Write-Host "1. Windows"
        Write-Host "2. Office"
        Write-Host "3. Windows & Office"
        Write-Host "4. Exit"
        Write-Host ""

        $choice = Read-Host "Enter your choice"

        switch ($choice) {
            '1' {   Get-Activated -Windows}
            '2' {   Get-Activated -Office }
            '3' {   Get-Activated -WindowsAndOffice }
            '4' {   Write-Host "Exiting." return}
            default {
                Write-Warning "Invalid selection."
                return
            }
        }
    }

    if ($Windows) {& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /HWID}
    if ($Office) {& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /Ohook}
    if ($WindowsAndOffice) {& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /HWID; & ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /Ohook}
}
