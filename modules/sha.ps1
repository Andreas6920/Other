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