$CPU = (Get-CimInstance Win32_Processor).Name
$GPU= (Get-CimInstance Win32_VideoController | where caption -match "Intel|AMD|NVIDIA").Caption
    $RAM_gb = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
    $RAM_version =(Get-WmiObject Win32_PhysicalMemory).ConfiguredVoltage; If ($ram_version -eq 2500){$ram_version = "DDR1"};If ($ram_version -eq 1800){$ram_version = "DDR2"};If ($ram_version -eq 1500){$ram_version = "DDR3"};If ($ram_version -eq 1200){$ram_version = "DDR4"}; 
    $RAM_SPEED = (Get-WmiObject Win32_PhysicalMemory).Speed[1]
    $RAM_manufacture = (Get-WmiObject Win32_PhysicalMemory).Manufacturer[0]
$RAM = "$RAM_manufacture $RAM_gb GB $ram_version $RAM_SPEED Mhz" 
$disk = (Get-CimInstance Win32_DiskDrive)[0].Model

"";"";"";
Write-host CPU `t`t $CPU
Write-host RAM `t`t $RAM 
Write-host GPU `t`t $gpu 
Write-host Disk `t`t $disk
"";"";"";