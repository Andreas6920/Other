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

                $Timestamp = Get-Date -Format "[yyyy/MM/dd HH:mm:ss]"

            try {
                if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        
                $CurrentValue = $null
                
                # If key path already exists, just continue
                if (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue) {$CurrentValue = (Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue)}
        
                # If key path does not exist, create it
                if ($CurrentValue -ne $Value) {
                    New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction Stop | Out-Null
                    Write-Host "$Timestamp               - Setting '$Name' to '$Value'." -ForegroundColor Yellow} 
                
                # If key value is already set to demanded value, continue
                else {Write-Host "$Timestamp               - '$Name' is already '$Value'."}}

            catch {
                # If access denied to registry path
                if ($_.Exception.GetType().Name -eq "UnauthorizedAccessException"){
                    Write-Host "$Timestamp               - Access denied to modify '$Name'." -ForegroundColor Yellow} 
                
                # If something else fails
                else {
                    Write-Text "$Timestamp               - ERROR: Cannot modify '$Name': $_" -ForegroundColor Red}}}
        