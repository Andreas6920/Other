Function Add-Reg {
            param (
                [Parameter(Mandatory=$true)]
                [string]$Path,
                [Parameter(Mandatory=$true)]
                [string]$Name,
                [Parameter(Mandatory=$true)]
                [ValidateSet('String', 'ExpandString', 'Binary', 'DWord', 'MultiString', 'Qword', 'Unknown')]
                [string]$Type,
                [Parameter(Mandatory=$true)]
                [string]$Value    )
        
            try {
                if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        
                $CurrentValue = $null
                if (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue) {$CurrentValue = (Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue)}
        
                if ($CurrentValue -ne $Value) {
                    New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction Stop | Out-Null
                    Write-Host "$(Get-LogDate)`t            - Setting '$Name' to '$Value'." -ForegroundColor DarkYellow} 
                else {Write-Host "$(Get-LogDate)`t            - '$Name' is already '$Value'." -ForegroundColor DarkYellow}}

            catch {
                if ($_.Exception.GetType().Name -eq "UnauthorizedAccessException") {
                    # Undertrykker denne type fejl
                    Write-Host "$(Get-LogDate)`t            - Access denied to modify '$Name'." -ForegroundColor Red}
                else {Write-Host "`t            - ERROR - cannot modify '$Name': $_" -ForegroundColor Red}}
        }
        