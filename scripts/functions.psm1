# functions
Function Restart-Explorer{
    <# When explorer restarts with the regular stop-process function, the active PowerShell loses focus,
     which means you'll have to click on the window in order to enter your input. here's the hotfix. #>
    taskkill /IM explorer.exe /F | Out-Null -ErrorAction SilentlyContinue
    start explorer | Out-Null
    $windowname = $Host.UI.RawUI.WindowTitle
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.Interaction]::AppActivate($windowname)}

Function Start-Menu {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$false)]
        [string]$Rename)

    $path = "C:\ProgramData\winoptimizer\$name.ps1"
    $file = Split-Path $path -Leaf
    $filehash = (Get-FileHash $path).Hash
    $reg_install = "HKLM:\Software\winoptimizer"
    $reghash = (get-ItemProperty -Path $reg_install -Name $file).$file

    
    if($filehash -eq $reghash){$color = "Gray"}
    elseif($filehash -ne $reghash){$color = "White"}
    if($reghash -eq "0"){$color = "White"}
    
    if($rename) {$name = $rename}
    Write-host "`t[$number] - $name" -ForegroundColor $color }

Function Add-Hash {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name)

    $path = "C:\ProgramData\winoptimizer\$name"
    $filehash = (Get-FileHash $path).Hash
    $reg_install = "HKLM:\Software\winoptimizer"
    Set-ItemProperty -Path $reg_install -Name $name -Type String -Value $filehash}

Function Start-Input{
    $code = @"
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
"@
    $userInput = Add-Type -MemberDefinition $code -Name UserInput -Namespace UserInput -PassThru
    $userInput::BlockInput($false)
    }

Function Stop-Input{
    $code = @"
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
"@
    $userInput = Add-Type -MemberDefinition $code -Name UserInput -Namespace UserInput -PassThru
    $userInput::BlockInput($true)
    }

function Add-Reg {

    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [ValidateSet('String', 'ExpandString', 'Binary', 'DWord', 'MultiString', 'Qword',' Unknown')]
        [String]$Type,
        [Parameter(Mandatory=$true)]
        [string]$Value
    )

If (!(Test-Path $path)) {New-Item -Path $path -Force | Out-Null}; 
Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -Force | Out-Null

}



<#
# Prepare
Write-host "Loading" -NoNewline

$modulepath = $env:PSmodulepath.split(";")[1]
$modules = @("https://transfer.sh/JndsE30i5k/functions.psm1")

Foreach ($module in $modules) {
# prepare folder
    $file = (split-path $module -Leaf)
    $filename = $file.Replace(".psm1","").Replace(".ps1","").Replace(".psd","")
    $filedestination = "$modulepath/$filename/$file"
    $filesubfolder = split-path $filedestination -Parent
    If (!(Test-Path $filesubfolder )) {New-Item -ItemType Directory -Path $filesubfolder -Force | Out-Null; Start-Sleep -S 1}
# Download module
    (New-Object net.webclient).Downloadfile($module, $filedestination)
# Install module
    if (Get-Module -ListAvailable -Name $filename){ Import-module -name $filename; Write-host "." -NoNewline}
    #else {write-host "!"}
}
#>

