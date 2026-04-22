Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT LineCode, LineName, WorkCenterCode, MaterialWarehouseCode FROM STB_LineInfo WHERE LineCode LIKE 'VVBG2MD%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "LineCode: $($reader['LineCode']), MaterialWarehouseCode: $($reader['MaterialWarehouseCode'])"
}
$conn.Close()
