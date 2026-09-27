$targets = @(
    @{ Name='BN'; IP='42.112.60.211'; Port=443; Url='https://42.112.60.211/ng/system/dashboard/11' },
    @{ Name='HY'; IP='10.0.0.1'; Port=4443; Url='https://10.0.0.1:4443/login?redir=%2Fng%2Finterface' },
    @{ Name='BG2'; IP='14.252.33.178'; Port=443; Url='https://14.252.33.178/login?redir=%2Fng' },
    @{ Name='BG1'; IP='14.241.37.102'; Port=443; Url='https://14.241.37.102/login' }
)
foreach ($item in $targets) {
    $t = Test-NetConnection -ComputerName $item.IP -Port $item.Port -WarningAction SilentlyContinue
    [PSCustomObject]@{
        Name = $item.Name
        IP = $item.IP
        Port = $item.Port
        TcpTestSucceeded = $t.TcpTestSucceeded
    }
}
