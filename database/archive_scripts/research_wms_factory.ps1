Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Investigate Picking / Warehouse Transfer
Write-Host "--- Picking / WMS SPs ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sys.procedures WHERE name LIKE '%Picking%' OR name LIKE '%Warehouse%Move%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP: $($reader['name'])"
}
$reader.Close()

# 2. Check how SPs are grouped for VVT vs VNT (Prefix patterns)
Write-Host "`n--- Factory Prefix Patterns ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 10 name FROM sys.procedures WHERE name LIKE '%VVT%' OR name LIKE '%VNT%' OR name LIKE '%Vietnam%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP: $($reader['name'])"
}
$reader.Close()

$conn.Close()
