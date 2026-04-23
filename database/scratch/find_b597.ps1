Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT ObjectName FROM STB_ScreenObjects WHERE ScreenName LIKE '%B597%' OR Caption LIKE '%B597%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP for B597: $($reader['ObjectName'])"
}
$conn.Close()
$connStr2 = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn2 = New-Object System.Data.SqlClient.SqlConnection($connStr2)
$conn2.Open()
$cmd2 = $conn2.CreateCommand()
$cmd2.CommandText = "SELECT OBJECT_NAME(object_id) AS sp_name FROM sys.sql_modules WHERE definition LIKE N'%được thiết lập, khác với mã%'"
$reader2 = $cmd2.ExecuteReader()
while ($reader2.Read()) {
    Write-Host "Found Error Message in SP: $($reader2['sp_name'])"
}
$conn2.Close()
