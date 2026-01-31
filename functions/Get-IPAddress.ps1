function Get-IPAddress {
    [CmdletBinding()]
    param()

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # Select the interface that Windows uses for the default IPv4 route (0.0.0.0/0)
    $DefaultRoute = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Sort-Object RouteMetric, InterfaceMetric |
        Select-Object -First 1

    if (-not $DefaultRoute) {
        throw "No default IPv4 route (0.0.0.0/0) was found."
    }

    $Adapter = Get-NetAdapter -InterfaceIndex $DefaultRoute.InterfaceIndex -ErrorAction SilentlyContinue
    if (-not $Adapter) {
        throw "Could not resolve a network adapter for InterfaceIndex '$($DefaultRoute.InterfaceIndex)'."
    }

    $Name = $Adapter.Name

    # Get IPv4 address for the selected interface (prefer the most specific prefix)
    $Ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $Name -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -and $_.IPAddress -notlike '169.254.*' } |
        Sort-Object PrefixLength -Descending |
        Select-Object -First 1

    # Gateway from default route
    $Gw = $DefaultRoute.NextHop

    # Always keep DNS as an array
    $DnsList = @(
        Get-DnsClientServerAddress -InterfaceAlias $Name -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty ServerAddresses -ErrorAction SilentlyContinue |
            Where-Object { $_ }
    )

    [PSCustomObject]@{
        IPAddress        = $Ip.IPAddress
        Gateway          = $Gw
        'DNS Address 1'  = if ($DnsList.Count -ge 1) { $DnsList[0] } else { 'Not defined' }
        'DNS Address 2'  = if ($DnsList.Count -ge 2) { $DnsList[1] } else { 'Not defined' }
    } | Format-List
}
