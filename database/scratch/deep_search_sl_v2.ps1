$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "SL20250909000100"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmdCols = New-Object System.Data.SqlClient.SqlCommand("SELECT TOP 0 * FROM STB_MaterialLotInfo", $conn)
    $adapterCols = New-Object System.Data.SqlClient.SqlDataAdapter($cmdCols)
    $dtCols = New-Object System.Data.DataTable
    $adapterCols.Fill($dtCols) | Out-Null
    
    $results = @()
    foreach ($col in $dtCols.Columns) {
        if ($col.DataType -eq [string]) {
            $colName = $col.ColumnName
            $sql = "SELECT '$colName' as MatchedColumn, LotID, LotNo, PackingID, PackingIdParent FROM STB_MaterialLotInfo WHERE [$colName] = '$search'"
            $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            $dt = New-Object System.Data.DataTable
            $adapter.Fill($dt) | Out-Null
            if ($dt.Rows.Count -gt 0) {
                foreach ($row in $dt.Rows) { $results += $row }
            }
        }
    }
    $conn.Close()

    if ($results.Count -eq 0) {
        Write-Host "No data found for '$search'."
    } else {
        $results | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
