



# Install Librewolf settings
    $link = "https://drive.google.com/uc?export=download&confirm=uc-download-link&id=1m8TZD7d9nc-Vkmv1PgyyXwUMuNgFrI3s"
    $src = "$env:TMP\librewolfprofile.zip"
    write-host "downloading to $src..." -f green
    (New-Object net.webclient).Downloadfile($link, $src); Start-Sleep -s 2

    write-host "Starting Libre Wolf..." -f green
    Start-Process "C:\Program Files\LibreWolf\librewolf.exe"
    Start-Sleep -s 5
    Stop-Process -name "librewolf"

    $dst = [Environment]::GetFolderPath("ApplicationData")
    $dst = Join-path $dst -ChildPath "librewolf\Profiles"
    $dst = (gci $dst | ? name -match "-default?$").FullName

    Start-Sleep -s 10
    write-host "Extracting from $src..." -f green
    write-host "Extracting to $dst..." -f green

    Expand-Archive -Path $src -DestinationPath $dst -Force

# Install ShareX settings
    $link = "https://drive.google.com/uc?export=download&confirm=uc-download-link&id=13xOvgOXgOkdLuGG-JqQiVQla6Gz6Sria"
    $src = "$env:TMP\sharexprofile.zip"
    write-host "downloading to $src..." -f green
    (New-Object net.webclient).Downloadfile($link, $src);

    $dst = [Environment]::GetFolderPath("MyDocuments")
    $dst = Join-path $dst -ChildPath "Sharex"
    $dst = (gci $dst | ? name -match "-default?$").FullName

    write-host "Extracting from $src..." -f green
    write-host "Extracting to $dst..." -f green

    Expand-Archive -Path $src -DestinationPath $dst -Force
