$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT 
    MaterialCode, MaterialName, MaterialThickness, MaterialWidth, MaterialUnit, MaterialTypeCode
FROM STB_MaterialMaster 
WHERE MaterialCode LIKE '%BA21E%' OR MaterialCode LIKE '%CREY0BS-04%'

SELECT * FROM STB_ElectrodeWastePriceNew WHERE MaterialCode LIKE '%BA21E%' OR MaterialCode LIKE '%CREY0BS-04%'
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

Write-Host "--- STB_MaterialMaster ---"
while ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode']) | Name: $($reader['MaterialName']) | Thickness: $($reader['MaterialThickness']) | Width: $($reader['MaterialWidth'])"
}

$reader.NextResult()

Write-Host "--- STB_ElectrodeWastePriceNew ---"
while ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode']) | Price: $($reader['Price']) | ElectrodeThickness: $($reader['ElectrodeThickness'])"
}

$reader.Close()
$conn.Close()
