$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "ML20250825000072"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmdCols = New-Object System.Data.SqlClient.SqlCommand("SELECT TOP 0 * FROM STB_MaterialLotInfo", $conn)
    $adapterCols = New-Object System.Data.SqlClient.SqlDataAdapter($cmdCols)
    $dtCols = New-Object System.Data.DataTable
    $adapterCols.Fill($dtCols) | Out-Null
    
    foreach ($col in $dtCols.Columns) {
        if ($col.DataType -eq [string]) {
            $colName = $col.ColumnName
            $sql = "SELECT COUNT(*) FROM STB_MaterialLotInfo WHERE [$colName] = '$search'"
            $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
            $count = $cmd.ExecuteScalar()
            if ($count -gt 0) {
                Write-Host "Found $count matches in column: [$colName]"
            }
        }
    }
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
