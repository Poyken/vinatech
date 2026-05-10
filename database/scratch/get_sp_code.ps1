$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

$sql = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('usp_ListInputSuccessSlitting_HN')"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    $dt.Rows[0]['definition'] | Out-File -FilePath "scratch/usp_ListInputSuccessSlitting_HN.sql"
    Write-Host "SP definition saved to scratch/usp_ListInputSuccessSlitting_HN.sql"
} catch {
    Write-Error $_.Exception.Message
}
