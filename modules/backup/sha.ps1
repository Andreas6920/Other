# Install ShareX settings
$link = "https://drive.google.com/uc?export=download&confirm=uc-download-link&id=13xOvgOXgOkdLuGG-JqQiVQla6Gz6Sria"
$src = "$env:TMP\sharexprofile.zip"
write-host "`t`t`t- Downloading to settings" -f Yellow
(New-Object net.webclient).Downloadfile($link, $src);

write-host "`t`t`t- Importing settings" -f Yellow
$dst = [Environment]::GetFolderPath("MyDocuments")
$dst = Join-path $dst -ChildPath "Sharex"
Expand-Archive -Path $src -DestinationPath $dst -Force