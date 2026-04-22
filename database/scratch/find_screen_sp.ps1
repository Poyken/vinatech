Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT ScreenName, ObjectName, ObjectType, Description FROM STB_ScreenObjects WHERE ScreenName = 'VNT_MaterialWarehouseInOutHistReg'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "ObjectName: $($reader['ObjectName']), ObjectType: $($reader['ObjectType']), Description: $($reader['Description'])"
}
$conn.Close()
