Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 5 LineCode, MaterialWarehouseCode FROM STB_LineInfo WHERE WorkCenterCode = 'VVT_F4' AND LineCode NOT IN ('VVBG2MD-01', 'VVBG2MD-02', 'VVBG2MD-03')"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "LineCode: $($reader['LineCode']), MaterialWarehouseCode: $($reader['MaterialWarehouseCode'])"
}
$conn.Close()
