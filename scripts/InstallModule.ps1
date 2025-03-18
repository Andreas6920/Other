Write-Host "Loading" -NoNewline

# Define the module URL and module path
$modulePath = $env:PSModulePath.Split(";")[1]
$modules = @("https://transfer.sh/JndsE30i5k/functions.psm1")

# Iterate over each module to process it
foreach ($module in $modules) {
    # Extract filename and module name from the URL
    $file = [System.IO.Path]::GetFileName($module)
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($file)

    # Check if the module is already imported
    if (Get-Module -ListAvailable -Name $filename) {
        Write-Host "Module $filename is already imported." -ForegroundColor Yellow
        continue  # Skip further steps if module is already imported
    }

    # Define destination path for the module
    $fileDestination = Join-Path -Path $modulePath -ChildPath "$filename\$file"
    $fileSubfolder = [System.IO.Path]::GetDirectoryName($fileDestination)

    # Create folder if it does not exist
    If (!(Test-Path -Path $fileSubfolder)) {
        New-Item -ItemType Directory -Path $fileSubfolder -Force | Out-Null
        Write-Host "Created folder: $fileSubfolder" -ForegroundColor Green
    }

    # Download module file
    try {
        Write-Host "Downloading $file..." -NoNewline
        (New-Object System.Net.WebClient).DownloadFile($module, $fileDestination)
        Write-Host " Done" -ForegroundColor Green
    } catch {
        Write-Host " ERROR: Failed to download $file" -ForegroundColor Red
        continue  # Skip further steps if download fails
    }

    # Install module
    try {
        Write-Host "Installing module $filename..."
        Import-Module -Name $filename -Force
        Write-Host "Module $filename imported successfully." -ForegroundColor Green
    } catch {
        Write-Host " ERROR: Failed to import module $filename" -ForegroundColor Red
    }
}

Write-Host "Loading complete." -ForegroundColor Green
