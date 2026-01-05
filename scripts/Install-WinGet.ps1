$ProgressPreference = "SilentlyContinue"

# Install NuGet
    if(!(test-path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208")){
    Write-Host "Installing NuGet" -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null;
    Write-Host "`t- Installation complete." -ForegroundColor DarkYellow}

# Install WinGet
    if(!(Get-Command winget -ErrorAction SilentlyContinue)){
    Write-Host "Installing WinGet" -ForegroundColor Yellow
    $job = Start-Job -ScriptBlock { Install-Script -Name winget-install -Force ; winget-install}
    Wait-Job $job | Out-Null
    Write-Host "`t- Installation complete." -ForegroundColor DarkYellow}

$ProgressPreference = "Continue"