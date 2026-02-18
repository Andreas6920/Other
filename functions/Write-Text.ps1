<#
.SYNOPSIS
Writes formatted text to the console with predefined indentation and color based on header type.

.DESCRIPTION
Write-Text outputs text to the console using Write-Host with different indentation levels
and foreground colors depending on the specified HeaderType.
Header type 1 is written in uppercase for emphasis.
The function is intended for structured console output, such as headings, subheadings,
and informational messages.

.EXAMPLE
Write-Text -HeaderType 1 -Text "Starting installation"

Writes a top-level header in uppercase green text.

.EXAMPLE
Write-Text -HeaderType 3 -Text "Downloading files"

Writes an indented message in yellow.

.NOTES
This function is intended for interactive console output.
It uses Write-Host and does not return objects to the pipeline.
#>

function Write-Text {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("1","2","3","4")]
        [string]$HeaderType,

        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $false)]
        [ConsoleColor]$EnforceColor
    )

    $Timestamp = Get-Date -Format "[yyyy/MM/dd HH:mm:ss]"

    switch ($HeaderType) {

        "1" {
            $DefaultColor = "Green"
            $Indent = ""
            $OutputText = $Text.ToUpper()
        }

        "2" {
            $DefaultColor = "Green"
            $Indent = "    "
            $OutputText = $Text
        }

        "3" {
            $DefaultColor = "Yellow"
            $Indent = "        "
            $OutputText = $Text
        }

        "4" {
            $DefaultColor = "DarkYellow"
            $Indent = "            "
            $OutputText = $Text
        }

        default {
            $DefaultColor = "Red"
            $Indent = ""
            $OutputText = "Invalid HeaderType provided."
        }
    }

    $ColorToUse = if ($PSBoundParameters.ContainsKey("EnforceColor")) {
        $EnforceColor
    } else {
        $DefaultColor
    }

    Write-Host "$Timestamp`t$Indent" -NoNewline
    Write-Host $OutputText -ForegroundColor $ColorToUse
}
