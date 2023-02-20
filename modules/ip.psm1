function ip {
    $name = (Get-NetAdapter -physical| where status -eq 'up' | sort ifStatus | select -first 1).Name
    (Get-NetIPAddress | Where-Object AddressFamily -eq IPv4 |Where-Object InterfaceAlias -eq  $name).IPAddress}
    