Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Get Route Columns
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 0 * FROM STB_RouteInfo"
$reader = $cmd.ExecuteReader()
for ($i = 0; $i -lt $reader.FieldCount; $i++) { Write-Host $reader.GetName($i) }
$reader.Close()

# 2. Get a sample PO's full routing sequence
Write-Host "`n--- Sample Routing Sequence for a VVT PO ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 1 PONo FROM STB_ProductionOrderInfo WHERE PONo LIKE 'VVT%' ORDER BY CreateDateTime DESC"
$po = $cmd.ExecuteScalar()
if ($po) {
    Write-Host "PO: $po"
    $cmd.CommandText = "SELECT RouteCode, RouteSeq FROM STB_ProductionOrderRouting WHERE PONo = '$po' ORDER BY RouteSeq"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Seq: $($reader['RouteSeq']) | Route: $($reader['RouteCode'])"
    }
    $reader.Close()
}

$conn.Close()
