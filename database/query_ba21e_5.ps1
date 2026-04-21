$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT DISTINCT
    RouteCode, ElectrodeClassCode, CurrentCollectorClassCode, ElectrodeThickness, DefectUnitPrice
FROM STB_ElectrodeWastePriceNew
WHERE RouteCode = 'V-03' 
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

Write-Host "--- V-03 in ElectrodeWastePriceNew ---"
while ($reader.Read()) {
    Write-Host "Route: $($reader['RouteCode']) | Type: $($reader['ElectrodeClassCode']) | Collector: $($reader['CurrentCollectorClassCode']) | Thick: $($reader['ElectrodeThickness']) | DefectPrice: $($reader['DefectUnitPrice'])"
}
$reader.Close()

$sql2 = @"
SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'CREBO83-01'
"@
$cmd.CommandText = $sql2
$r2 = $cmd.ExecuteReader()
Write-Host "--- MaterialMaster CREBO83-01 ---"
while($r2.Read()){
    Write-Host "Thickness: $($r2['MaterialThickness']) | Width: $($r2['MaterialWidth']) | Ext1: $($r2['MaterialExt01']) | Ext2: $($r2['MaterialExt02'])"
}
$r2.Close()

$sql3 = @"
SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'CREY08S-04'
"@
$cmd.CommandText = $sql3
$r3 = $cmd.ExecuteReader()
Write-Host "--- MaterialMaster CREY08S-04 ---"
while($r3.Read()){
    Write-Host "Thickness: $($r3['MaterialThickness']) | Width: $($r3['MaterialWidth']) | Ext1: $($r3['MaterialExt01']) | Ext2: $($r3['MaterialExt02'])"
}
$r3.Close()

$conn.Close()
