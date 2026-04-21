$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_ElectrodeWastePriceNew'
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

while ($reader.Read()) {
    Write-Host "- $($reader['COLUMN_NAME'])"
}
$reader.Close()

$sql2 = @"
SELECT TOP 5 * FROM STB_ElectrodeWastePriceNew
"@
$cmd.CommandText = $sql2
$reader2 = $cmd.ExecuteReader()
Write-Host "--- DATA ---"
while ($reader2.Read()) {
    $row = ""
    for($i=0; $i -lt $reader2.FieldCount; $i++) {
        $row += "$($reader2.GetName($i)): $($reader2.GetValue($i)) | "
    }
    Write-Host $row
}
$reader2.Close()


$conn.Close()
