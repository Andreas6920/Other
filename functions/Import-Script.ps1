function Import-Script {
    param (
        [Parameter(Mandatory=$true)]
        [string]$link,  # Link til online .ps1, .psm1 fil, eller lokal sti til en mappe eller script

        [Parameter(Mandatory=$true)]
        [string]$path   # Lokal sti til et script (.ps1/.psm1) eller en mappe
    )

    Write-Host "Processing..." -NoNewline

    # Hvis stien er en mappe
    if (Test-Path $path -and (Test-Path $path -PathType Container)) {
        Write-Host "Directory found: $path" -ForegroundColor Green

        # Find alle PowerShell-filer i mappen
        $psFiles = Get-ChildItem -Path $path -Recurse -File -Filter "*.ps1", "*.psm1"

        if ($psFiles.Count -eq 0) {
            Write-Host "No PowerShell files found in the directory." -ForegroundColor Red
            return
        }

        foreach ($file in $psFiles) {
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            Write-Host "Found PowerShell file: $file" -ForegroundColor Yellow

            # Tjek om filen allerede er importeret som en funktion
            if (Get-Command -Name $fileName -ErrorAction SilentlyContinue) {
                Write-Host "Function $fileName is already loaded." -ForegroundColor Yellow
                continue
            }

            # Hvis det er en .psm1 fil (PowerShell-modul)
            if ($file.Extension -eq ".psm1") {
                # Definer modulsti og download (hvis nødvendigt)
                $modulePath = $env:PSModulePath.Split(";")[1]
                $fileDestination = Join-Path -Path $modulePath -ChildPath "$fileName\$file.Name"
                $fileSubfolder = [System.IO.Path]::GetDirectoryName($fileDestination)

                # Opret mappe, hvis den ikke eksisterer
                If (!(Test-Path -Path $fileSubfolder)) {
                    New-Item -ItemType Directory -Path $fileSubfolder -Force | Out-Null
                    Write-Host "Created folder: $fileSubfolder" -ForegroundColor Green
                }

                # Download og installer moduler
                try {
                    Write-Host "Downloading module $fileName..." -NoNewline
                    (New-Object System.Net.WebClient).DownloadFile($file.FullName, $fileDestination)
                    Write-Host " Done" -ForegroundColor Green
                } catch {
                    Write-Host " ERROR: Failed to download module $fileName" -ForegroundColor Red
                    continue
                }

                # Importer modulet
                try {
                    Write-Host "Installing module $fileName..." -NoNewline
                    Import-Module -Name $fileName -Force
                    Write-Host " Module $fileName imported successfully." -ForegroundColor Green
                } catch {
                    Write-Host " ERROR: Failed to import module $fileName" -ForegroundColor Red
                }

            }
            # Hvis det er en .ps1 fil, dot-sourcer vi den
            else {
                try {
                    Write-Host "Loading function from $fileName..." -NoNewline
                    . $file.FullName
                    Write-Host " Done" -ForegroundColor Green
                } catch {
                    Write-Host " ERROR: Failed to load function from $fileName" -ForegroundColor Red
                }
            }
        }

    }
    # Hvis stien er et script
    elseif (Test-Path $path -and (Test-Path $path -PathType Leaf)) {
        Write-Host "Script file found: $path" -ForegroundColor Green

        # Tjek om scriptet allerede er importeret som funktion eller modul
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($path)
        if (Get-Command -Name $fileName -ErrorAction SilentlyContinue) {
            Write-Host "Function $fileName is already loaded." -ForegroundColor Yellow
            return
        }

        # Hvis det er en .psm1 fil (PowerShell-modul)
        if ($path.EndsWith(".psm1")) {
            # Definer modulsti og download (hvis nødvendigt)
            $modulePath = $env:PSModulePath.Split(";")[1]
            $fileDestination = Join-Path -Path $modulePath -ChildPath "$fileName\$fileName.psm1"
            $fileSubfolder = [System.IO.Path]::GetDirectoryName($fileDestination)

            # Opret mappe, hvis den ikke eksisterer
            If (!(Test-Path -Path $fileSubfolder)) {
                New-Item -ItemType Directory -Path $fileSubfolder -Force | Out-Null
                Write-Host "Created folder: $fileSubfolder" -ForegroundColor Green
            }

            # Download og installer moduler
            try {
                Write-Host "Downloading module $fileName..." -NoNewline
                (New-Object System.Net.WebClient).DownloadFile($path, $fileDestination)
                Write-Host " Done" -ForegroundColor Green
            } catch {
                Write-Host " ERROR: Failed to download module $fileName" -ForegroundColor Red
                continue
            }

            # Importer modulet
            try {
                Write-Host "Installing module $fileName..." -NoNewline
                Import-Module -Name $fileName -Force
                Write-Host " Module $fileName imported successfully." -ForegroundColor Green
            } catch {
                Write-Host " ERROR: Failed to import module $fileName" -ForegroundColor Red
            }

        }
        # Hvis det er en .ps1 fil, dot-sourcer vi den
        else {
            try {
                Write-Host "Loading function from $fileName..." -NoNewline
                . $path
                Write-Host " Done" -ForegroundColor Green
            } catch {
                Write-Host " ERROR: Failed to load function from $fileName" -ForegroundColor Red
            }
        }
    }
    # Hvis link er angivet som en URL
    elseif ($link -match "https?://") {
        Write-Host "Downloading script from URL: $link" -ForegroundColor Green

        # Definer destinationssti
        $fileName = [System.IO.Path]::GetFileName($link)
        $tempPath = Join-Path -Path $env:TEMP -ChildPath $fileName

        try {
            # Download filen
            Write-Host "Downloading $fileName..." -NoNewline
            (New-Object System.Net.WebClient).DownloadFile($link, $tempPath)
            Write-Host " Done" -ForegroundColor Green

            # Hvis filen er en .psm1 fil, download og installer modulet
            if ($tempPath.EndsWith(".psm1")) {
                # Definer modulsti
                $modulePath = $env:PSModulePath.Split(";")[1]
                $fileDestination = Join-Path -Path $modulePath -ChildPath "$fileName"
                $fileSubfolder = [System.IO.Path]::GetDirectoryName($fileDestination)

                # Opret mappe, hvis den ikke eksisterer
                If (!(Test-Path -Path $fileSubfolder)) {
                    New-Item -ItemType Directory -Path $fileSubfolder -Force | Out-Null
                    Write-Host "Created folder: $fileSubfolder" -ForegroundColor Green
                }

                # Download og installer modulet
                try {
                    Write-Host "Downloading module $fileName..." -NoNewline
                    (New-Object System.Net.WebClient).DownloadFile($link, $fileDestination)
                    Write-Host " Done" -ForegroundColor Green
                } catch {
                    Write-Host " ERROR: Failed to download module $fileName" -ForegroundColor Red
                    continue
                }

                # Installer modulet
                try {
                    Write-Host "Installing module $fileName..." -NoNewline
                    Import-Module -Name $fileName -Force
                    Write-Host " Module $fileName imported successfully." -ForegroundColor Green
                } catch {
                    Write-Host " ERROR: Failed to import module $fileName" -ForegroundColor Red
                }
            }
            # Hvis det er en .ps1 fil, dot-sourcer vi den
            else {
                try {
                    Write-Host "Loading function from $fileName..." -NoNewline
                    . $tempPath
                    Write-Host " Done" -ForegroundColor Green
                } catch {
                    Write-Host " ERROR: Failed to load function from $fileName" -ForegroundColor Red
                }
            }
        } catch {
            Write-Host " ERROR: Failed to download script from $link" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Invalid path or link provided." -ForegroundColor Red
    }

    Write-Host "Processing complete." -ForegroundColor Green
}
