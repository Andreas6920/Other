function Get-Activated {
    [CmdletBinding()]
    param(
        [switch]$Windows,
        [switch]$Office
    )

if($Windows){$target = "/HWID"}
if($Office){$target = "/Ohook"}

$TempFile = "$env:TEMP\Activate.ps1"
Invoke-RestMethod -Uri "https://get.activated.win" | Out-File -FilePath $tempFile -Encoding UTF8
& powershell -ExecutionPolicy Bypass -File $TempFile $target
}

