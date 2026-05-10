$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

$sql = "SELECT OBJECT_NAME(object_id) AS Name, definition FROM sys.sql_modules WHERE definition LIKE '%F743%' OR definition LIKE '%SlittingLOTMaterial%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    $dt | Select-Object Name | Format-Table -AutoSize
} catch {
    Write-Error $_.Exception.Message
}
