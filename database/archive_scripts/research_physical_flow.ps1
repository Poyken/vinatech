Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Get Physical Route Steps
Write-Host "--- Route Sequence (STB_RouteInfo) ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 10 RouteCode, Description FROM STB_RouteInfo WHERE RouteCode LIKE 'V%' OR RouteCode LIKE 'E%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Route: $($reader['RouteCode']) | Desc: $($reader['Description'])"
}
$reader.Close()

# 2. Trace a specific Barcode (example) to see the history flow
Write-Host "`n--- Tracing Sample Routing History ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 5 ControlNo, RouteCode, CreateDateTime FROM STB_ProdRouteHist ORDER BY CreateDateTime DESC"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Barcode: $($reader['ControlNo']) | Route: $($reader['RouteCode']) | Time: $($reader['CreateDateTime'])"
}
$reader.Close()

$conn.Close()
