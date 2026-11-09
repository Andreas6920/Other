$ErrorActionPreference = 'Stop'

$fidoUrl = 'https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1'
$fidoScript = Join-Path ([IO.Path]::GetTempPath()) ("Fido-{0}.ps1" -f [guid]::NewGuid().ToString('N'))

try {
	Invoke-WebRequest -Uri $fidoUrl -OutFile $fidoScript -UseBasicParsing -ErrorAction Stop

	$powerShellName = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh.exe' } else { 'powershell.exe' }
	$powerShellPath = Join-Path $PSHOME $powerShellName
	$arguments = @(
		'-NoProfile'
		'-STA'
		'-ExecutionPolicy'
		'Bypass'
		'-File'
		"`"$fidoScript`""
	)

	$process = Start-Process -FilePath $powerShellPath -ArgumentList $arguments -Wait -PassThru
	if ($process.ExitCode -ne 0) {
		Write-Warning "Fido exited with code $($process.ExitCode)."
	}
}
finally {
	Remove-Item -LiteralPath $fidoScript -Force -ErrorAction SilentlyContinue
}