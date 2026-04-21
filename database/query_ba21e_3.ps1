$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT DISTINCT
    RouteCode, ElectrodeClassCode, CurrentCollectorClassCode, ElectrodeThickness, DefectUnitPrice
FROM STB_ElectrodeWastePriceNew
WHERE ElectrodeThickness IN ('200', '200.000000') AND ElectrodeThickness IS NOT NULL
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

Write-Host "--- ElectrodeWastePriceNew (Thick 200) ---"
while ($reader.Read()) {
    Write-Host "Route: $($reader['RouteCode']) | Type: $($reader['ElectrodeClassCode']) | Collector: $($reader['CurrentCollectorClassCode']) | DefectPrice: $($reader['DefectUnitPrice'])"
}
$reader.Close()

$sql3 = @"
SELECT Barcode, MaterialCode, SIExtReal03 FROM STB_SetInfo
WHERE Barcode IN ('VVQM1820001E19', 'VVQM1820001E20') /* The two BA21E batches in screenshot */
"@
$cmd.CommandText = $sql3
$r3 = $cmd.ExecuteReader()
Write-Host "--- SetInfo for the Barcodes ---"
while($r3.Read()){
    Write-Host "BC: $($r3['Barcode']) | Mat: $($r3['MaterialCode']) | SIExtReal03 (Thick): $($r3['SIExtReal03'])"
}
$r3.Close()

$conn.Close()
