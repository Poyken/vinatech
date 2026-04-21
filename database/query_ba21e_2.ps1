$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT 
    MaterialCode, MaterialName, MaterialThickness, MaterialWidth
FROM STB_MaterialMaster 
WHERE MaterialCode IN ('CREB08S-01', 'CREY08S-01', 'CREY08S-04')
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

Write-Host "--- STB_MaterialMaster ---"
while ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode']) | Thickness: $($reader['MaterialThickness']) | Width: $($reader['MaterialWidth'])"
}
$reader.Close()

$sql2 = @"
SELECT * FROM STB_ElectrodeWastePriceNew
WHERE ElectrodeThickness IN ('83', '85', '120') /* 83 for BA21E, 85 for YP */
"@
$cmd.CommandText = $sql2
$r2 = $cmd.ExecuteReader()
Write-Host "--- ElectrodeWastePriceNew ---"
while ($r2.Read()) {
    Write-Host "RouteCode: $($r2['RouteCode']) | ElectrodeClassCode: $($r2['ElectrodeClassCode']) | Type: $($r2['CurrentCollectorClassCode']) | Thick: $($r2['ElectrodeThickness']) | DefectUnitPrice: $($r2['DefectUnitPrice'])"
}
$r2.Close()
$conn.Close()
