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





# Create folder
Write-host "Loading" -nonewline
$rootpath = "C:\ProgramData\winoptimizer"
if(!(test-path $rootpath)){Write-host "."; New-Item -ItemType Directory -Path $rootpath -Force | Out-Null}

# Download scripts
$script01 = "win_antibloat.ps1"
$script02 = "win_security.ps1"
$Script03 = "win_settings.ps1"
$scripts = "$script01","$script02","$Script03"
foreach ($script in $scripts){
Write-host ".";
$link = "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/$script"
$path = join-path -Path $rootpath -ChildPath $script
(New-Object net.webclient).Downloadfile("$link", "$path")}

# Create Registry keys
$reg_install = "HKLM:\Software\winoptimizer"
If(!(Test-Path $reg_install)) {
Write-host "."; New-Item -Path $reg_install -Force | Out-Null;
$scripts | ForEach-Object {Write-host "."; Set-ItemProperty -Path $reg_install -Name $_ -Type String -Value 0}}
$keys = (Get-Item -Path $reg_install).Property
$scripts | ForEach-Object {if((!$keys.Contains($_))){Write-host "."; Set-ItemProperty -Path $reg_install -Name $_ -Type String -Value 0}}
cls