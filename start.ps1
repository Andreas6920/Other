# Install modules
$dst = $env:PSmodulepath.split(";")[1]
$modules = @(
    "https://raw.githubusercontent.com/Andreas6920/Other/main/modules/upload.psm1";
    

	)
foreach ($module in $modules) {(New-Object net.webclient).Downloadfile("$_", "$dst")}
