Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
UPDATE STB_LineInfo 
SET MaterialWarehouseCode = 'MODULE_BG2_WH',
    ChangeUserID = 'vanduc',
    ChangeDateTime = GETDATE()
WHERE LineCode IN ('VVBG2MD-01', 'VVBG2MD-02', 'VVBG2MD-03')
"@
$rowsAffected = $cmd.ExecuteNonQuery()
Write-Host "Rows affected: $rowsAffected"
$conn.Close()
