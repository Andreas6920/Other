Write-Host "Gathering information" -NoNewline
$cs  = Get-CimInstance Win32_ComputerSystem
$computerName = $env:COMPUTERNAME
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$bios = Get-CimInstance Win32_BIOS

Write-Host "." -NoNewline
$type = if (Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue) { "Laptop" } else { "Workstation" }
# Check SMBIOS manufacturer and model markers; HypervisorPresent can also be true on physical PCs.
$systemIdentifiers = @($cs.Manufacturer, $cs.Model, $bios.Manufacturer, $bios.SMBIOSBIOSVersion) -join ' '
$isVirtualMachine = $systemIdentifiers -match '(?i)(VMware|VirtualBox|innotek|QEMU|SeaBIOS|Bochs|Xen|Parallels|BHYVE|Amazon EC2|Google Compute Engine|Virtual Machine|OpenStack|\bKVM\b)'
$model = if ($isVirtualMachine) { "Virtual Machine (VM)" } else { "{0} {1}" -f $cs.Manufacturer, $cs.Model }
$ram  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 0)
$volumes = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType = 3' |
    Where-Object { $_.DeviceID -match '^[A-Z]:$' -and $_.Size -gt 0 } |
    Sort-Object DeviceID

Write-Host "." -NoNewline
$gpus = Get-CimInstance Win32_VideoController |
        Where-Object { $_.Caption -and $_.Caption -notmatch 'DisplayLink' } |
        Select-Object -ExpandProperty Caption -Unique
$gpuText = if ($gpus) { $gpus -join ", " } else { "Unknown" }

# Run the network test asynchronously so the loading message can animate while it waits.
Write-Host "." -NoNewline
$networkJob = Start-Job -ScriptBlock {
    $ProgressPreference = 'SilentlyContinue'
    $result = Test-NetConnection -ComputerName google.com -InformationLevel Detailed -WarningAction SilentlyContinue
    $sourceAddress = $result.SourceAddress
    $sourceAddressText = if ($sourceAddress.IPAddressToString) {
        [string]$sourceAddress.IPAddressToString
    } elseif ($sourceAddress.IPAddress) {
        [string]$sourceAddress.IPAddress
    } elseif ($sourceAddress) {
        $sourceAddress.ToString()
    } else {
        $null
    }

    [pscustomobject]@{
        InterfaceAlias = $result.InterfaceAlias
        SourceAddress = $sourceAddressText
        NextHop = $result.NetRoute.NextHop
        InterfaceIndex = $result.NetRoute.InterfaceIndex
    }
}

while ((Get-Job -Id $networkJob.Id).State -eq 'Running') {
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1
}

$networkJob = Get-Job -Id $networkJob.Id
if ($networkJob.State -ne 'Completed') {
    $jobReason = $networkJob.ChildJobs[0].JobStateInfo.Reason
    Remove-Job -Job $networkJob -Force -ErrorAction SilentlyContinue
    if ($jobReason) {
        throw "Network information lookup failed: $jobReason"
    }
    throw "Network information lookup ended with state '$($networkJob.State)'."
}

try {
    $networkInformation = Receive-Job -Job $networkJob -ErrorAction Stop
} finally {
    Remove-Job -Job $networkJob -Force -ErrorAction SilentlyContinue
}
$networkInterface = if ($networkInformation.InterfaceAlias) { $networkInformation.InterfaceAlias } else { "Unknown" }
$networkIp = if ($networkInformation.SourceAddress) { $networkInformation.SourceAddress } else { "Unknown" }
$networkGateway = if ($networkInformation.NextHop -and $networkInformation.NextHop -notin @("0.0.0.0", "::")) {
    $networkInformation.NextHop
} else {
    "Unknown"
}
$dnsServers = @(
    if ($networkInformation.InterfaceIndex) {
        Get-DnsClientServerAddress -InterfaceIndex $networkInformation.InterfaceIndex -ErrorAction Stop |
            ForEach-Object { $_.ServerAddresses } |
            Where-Object { $_ -and $_ -notin @("0.0.0.0", "::") } |
            Select-Object -Unique
    }
)
$dnsText = if ($dnsServers) { $dnsServers -join ", " } else { "Unknown" }

Clear-Host
Write-Host ("Name: {0}" -f $computerName) -ForegroundColor Cyan
Write-Host "Device:" -ForegroundColor Cyan
Write-Host ("  - Type: {0}" -f $type)
Write-Host ("  - Model: {0}" -f $model)
Write-Host ("  - CPU: {0} @ {1} GHz" -f ($cpu.Name -replace '\s+', ' '), ([math]::Round($cpu.MaxClockSpeed / 1000, 1)))
Write-Host ("  - GPU: {0}" -f $gpuText)
Write-Host ("  - RAM: {0} GB" -f $ram)
Write-Host "  - Storage"
$volumes | ForEach-Object {
    $driveLetter = $_.DeviceID.TrimEnd(':')
    $percentFull = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 0)
    Write-Host ("      - Letter: {0} ({1}% full)" -f $driveLetter, $percentFull)
    Write-Host ("      - Size: {0} GB" -f [math]::Round($_.Size / 1GB, 0))
    Write-Host ("      - Remaining: {0} GB" -f [math]::Round($_.FreeSpace / 1GB, 0))
}

Write-Host ""
Write-Host "Network:" -ForegroundColor Cyan
Write-Host ("  - Interface: {0}" -f $networkInterface)
Write-Host ("  - IP: {0}" -f $networkIp)
Write-Host ("  - Gateway: {0}" -f $networkGateway)
Write-Host ("  - DNS: {0}" -f $dnsText)
Write-Host ""
