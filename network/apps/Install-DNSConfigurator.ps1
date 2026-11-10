$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$repoRawRoot = 'https://raw.githubusercontent.com/Andreas6920/Other/main'
$repoRoot = if ($PSScriptRoot) { Split-Path -Parent (Split-Path -Parent $PSScriptRoot) } else { $null }
$menuHelperPath = if ($repoRoot) { Join-Path $repoRoot 'functions\Show-ArrowMenu.ps1' } else { $null }
if ($menuHelperPath -and (Test-Path -LiteralPath $menuHelperPath)) {
    . $menuHelperPath
} else {
    $menuHelper = Invoke-RestMethod -Uri "$repoRawRoot/functions/Show-ArrowMenu.ps1" -ErrorAction Stop
    . ([scriptblock]::Create([string]$menuHelper))
}

$isAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdministrator) {
    throw 'DNS settings require an elevated PowerShell session. Run the toolkit as Administrator.'
}

$networkJob = Start-Job -ScriptBlock {
    $ProgressPreference = 'SilentlyContinue'
    # Use a public IP so finding the routed interface does not require DNS resolution.
    $result = Test-NetConnection -ComputerName '1.1.1.1' -InformationLevel Detailed -WarningAction SilentlyContinue
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

Write-Host 'Gathering information....' -NoNewline
while ((Get-Job -Id $networkJob.Id).State -eq 'Running') {
    Start-Sleep -Seconds 1
}
Write-Host ''

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

$nic = $networkInformation.InterfaceAlias
$interfaceIndex = $networkInformation.InterfaceIndex
if (-not $nic -or -not $interfaceIndex) {
    throw 'Could not determine the primary network interface. Check that the device has an active network connection.'
}

$currentDnsServers = @(
    Get-DnsClientServerAddress -InterfaceIndex $interfaceIndex -AddressFamily IPv4 -ErrorAction Stop |
        ForEach-Object { $_.ServerAddresses } |
        Where-Object { $_ }
)
$ipAddress = if ($networkInformation.SourceAddress) { $networkInformation.SourceAddress } else { 'Unknown' }
$gateway = $networkInformation.NextHop
if (-not $gateway -or $gateway -in @('0.0.0.0', '::')) {
    $gateway = 'Unknown'
}

function Write-NetworkConfiguration {
    param(
        [string]$Interface,
        [string]$IPAddress,
        [string]$Gateway,
        [string[]]$DnsServers
    )

    Write-Host 'Network Configuration:' -ForegroundColor Cyan
    Write-Host ("  - Interface: {0}" -f $Interface)
    Write-Host ("  - IP: {0}" -f $IPAddress)
    Write-Host ("  - Gateway: {0}" -f $Gateway)
    Write-Host '  - DNS: ' -NoNewline -ForegroundColor Cyan
    Write-Host $(if ($DnsServers) { $DnsServers -join ', ' } else { 'Automatic (DHCP)' })
}

$dnsOptions = @(
    @{ Name = 'Cloudflare + Google'; ServerAddresses = @('1.1.1.1', '8.8.8.8'); Executed = $false }
    @{ Name = 'Cloudflare'; ServerAddresses = @('1.1.1.1', '1.0.0.1'); Executed = $false }
    @{ Name = 'Cloudflare Kids'; ServerAddresses = @('1.1.1.3', '1.0.0.3'); Executed = $false }
    @{ Name = 'Google'; ServerAddresses = @('8.8.8.8', '8.8.4.4'); Executed = $false }
    @{ Name = 'Quad9'; ServerAddresses = @('9.9.9.9', '149.112.112.112'); Executed = $false }
    @{ Name = 'Return'; ServerAddresses = $null; Executed = $false }
)

while ($true) {
    $menuHeader = {
        Write-Host 'Network Configuration:' -ForegroundColor Cyan
        Write-Host ("  - Interface: {0}" -f $nic)
        Write-Host ("  - IP: {0}" -f $ipAddress)
        Write-Host ("  - Gateway: {0}" -f $gateway)
        Write-Host '  - DNS: ' -NoNewline -ForegroundColor Cyan
        Write-Host $(if ($currentDnsServers) { $currentDnsServers -join ', ' } else { 'Automatic (DHCP)' })
    }.GetNewClosure()

    $selectionIndex = Show-ArrowMenu -Title 'Choose a DNS configuration' -MenuItems $dnsOptions -Header $menuHeader -Separator
    $selectedOption = $dnsOptions[$selectionIndex]
    if ($selectedOption.Name -eq 'Return') {
        break
    }

    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses $selectedOption.ServerAddresses | Out-Null
    Clear-DnsClientCache -ErrorAction Stop
    Write-Host ("Applying {0} DNS to {1}..." -f $selectedOption.Name, $nic) -ForegroundColor Cyan

    $connected = $false
    $lastDnsError = $null
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        try {
            $dnsResult = Resolve-DnsName -Name 'google.com' -Type A -DnsOnly -ErrorAction Stop
            if ($dnsResult | Where-Object { $_.IPAddress }) {
                $connected = $true
                break
            }
        } catch {
            $lastDnsError = $_.Exception.Message
        }

        if ($attempt -lt 19) {
            Start-Sleep -Seconds 3
        }
    }

    if (-not $connected) {
        # Restore the previous DNS mode if name resolution did not recover within one minute.
        if ($currentDnsServers) {
            Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses $currentDnsServers | Out-Null
        } else {
            Set-DnsClientServerAddress -InterfaceAlias $nic -ResetServerAddresses | Out-Null
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        $failureMessage = 'DNS resolution did not succeed within 60 seconds. The previous DNS settings were restored.'
        if ($lastDnsError) {
            $failureMessage += " Last error: $lastDnsError"
        }
        throw $failureMessage
    }

    $currentDnsServers = @(
        Get-DnsClientServerAddress -InterfaceIndex $interfaceIndex -AddressFamily IPv4 -ErrorAction Stop |
            ForEach-Object { $_.ServerAddresses } |
            Where-Object { $_ }
    )
    $selectedOption.Executed = $true
    Clear-Host
    Write-NetworkConfiguration -Interface $nic -IPAddress $ipAddress -Gateway $gateway -DnsServers $currentDnsServers
    Write-Host ''
    Write-Host ("DNS updated successfully: {0}" -f ($selectedOption.ServerAddresses -join ', ')) -ForegroundColor Green
    Start-Sleep -Seconds 2
}
