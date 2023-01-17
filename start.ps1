# Install modules
$dst = $env:PSmodulepath.split(";")[1]
$modules = @(
    

	)
foreach ($module in $modules) {(New-Object net.webclient).Downloadfile("$_", "$dst")}
