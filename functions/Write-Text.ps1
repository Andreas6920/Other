function Write-Text {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("1", "2", "3")]
        [string]$HeaderType,  # Angiver hvilken headertype der skal anvendes
        [Parameter(Mandatory=$true)]
        [string]$Text   # Den tekst, der skal vises
    )

    # Angiver forskellige indryk for hver HeaderType
    switch ($HeaderType) {
        "1" {Write-Host $Text -ForegroundColor Green}
        "2" {Write-Host "`t    $Text" -ForegroundColor Green}
        "3" {Write-Host "`t        $Text" -ForegroundColor Yellow}
        "4" {Write-Host "`t            $Text" -ForegroundColor DarkYellow}
        default {Write-Host "Invalid HeaderType provided." -ForegroundColor Red}
    }
}
