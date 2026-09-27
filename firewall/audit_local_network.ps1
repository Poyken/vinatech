$adapters = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -ne 'Loopback Pseudo-Interface 1' } | Select-Object InterfaceAlias, IPAddress, PrefixLength
$routes = Get-NetRoute -AddressFamily IPv4 | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' -or $_.DestinationPrefix -like '192.168.*' -or $_.DestinationPrefix -like '10.*' } | Select-Object DestinationPrefix, NextHop, InterfaceAlias, RouteMetric
$dns = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses.Count -gt 0 } | Select-Object InterfaceAlias, ServerAddresses
$arp = arp -a | Out-String

try {
    $wc = New-Object System.Net.WebClient
    $publicIp = $wc.DownloadString('https://api.ipify.org')
} catch {
    $publicIp = "N/A: " + $_.Exception.Message
}

# Test connection to local FortiGate
$gw = ($routes | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop
$gwTest = Test-NetConnection -ComputerName $gw -WarningAction SilentlyContinue

[PSCustomObject]@{
    PublicIP = $publicIp
    Gateway = $gw
    GatewayPingable = $gwTest.PingSucceeded
    Adapters = $adapters
    IPAddresses = $ipAddresses
    DefaultRoutes = $routes
    DNS = $dns
} | ConvertTo-Json -Depth 5
