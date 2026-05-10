$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetCode = "SP260508-003"

$sql = "SELECT * FROM STB_SavePackingTime_VVT"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    foreach ($row in $dt.Rows) {
        foreach ($col in $dt.Columns) {
            if ($row[$col.ColumnName] -like "*$targetCode*") {
                Write-Host "Found $targetCode in column: $($col.ColumnName)"
                $row | Format-List
                break
            }
        }
    }
} catch {
    Write-Error $_.Exception.Message
}
