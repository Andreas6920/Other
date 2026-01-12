$cs  = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

$type = if (Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue) { "Laptop" } else { "Workstation" }
$ram  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 0)

$gpus = Get-CimInstance Win32_VideoController |
        Where-Object { $_.Caption -and $_.Caption -notmatch 'DisplayLink' } |
        Select-Object -ExpandProperty Caption -Unique
$gpuText = if ($gpus) { $gpus -join ", " } else { "Unknown" }

Write-Host ("- Model: {0} {1} (Type: {2})" -f $cs.Manufacturer, $cs.Model, $type)
Write-Host ("- CPU: {0} @ {1} GHz" -f ($cpu.Name -replace '\s+', ' '), ([math]::Round($cpu.MaxClockSpeed / 1000, 1)))
Write-Host ("- GPU: {0}" -f $gpuText)
Write-Host ("- RAM: {0} GB" -f $ram)

Get-Volume | Where-Object DriveLetter | Sort-Object DriveLetter | ForEach-Object {
    Write-Host ("- Drive {0} (Name: {1}, Size: {2} GB, Remaining: {3} GB)" -f `
        $_.DriveLetter,
        $_.FileSystemLabel,
        [math]::Round($_.Size / 1GB, 0),
        [math]::Round($_.SizeRemaining / 1GB, 0)
    )
}
