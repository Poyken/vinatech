$targets = @(
    @{ Name='Core Switch L3 (Local Gateway)'; IP='192.168.184.1' },
    @{ Name='Hưng Yên FortiGate 100F (L3 Link)'; IP='10.0.0.1' },
    @{ Name='Bắc Ninh FortiGate 80F (VPN)'; IP='192.168.0.254' },
    @{ Name='Server MES Bắc Ninh'; IP='192.168.112.254' },
    @{ Name='Bắc Giang 1 FortiGate 80F'; IP='192.168.120.1' },
    @{ Name='Wanju Factory Korea (VPN)'; IP='192.168.20.1' },
    @{ Name='Internet Public DNS (Google)'; IP='8.8.8.8' }
)

$results = foreach ($t in $targets) {
    $ping = Test-NetConnection -ComputerName $t.IP -WarningAction SilentlyContinue
    [PSCustomObject]@{
        TargetName = $t.Name
        IP = $t.IP
        PingOk = $ping.PingSucceeded
        LatencyMs = $ping.PingReplyDetails.RoundtripTime
    }
}

$results | Format-Table -AutoSize | Out-String | Write-Host

# Trace route to Google
Write-Host "`n--- TRACE ROUTE TO 8.8.8.8 (INTERNET) ---"
tracert -d -h 5 8.8.8.8

# Trace route to Bac Ninh LAN via VPN
Write-Host "`n--- TRACE ROUTE TO BAC NINH (192.168.0.254 via IPSEC VPN) ---"
tracert -d -h 5 192.168.0.254
