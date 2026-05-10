$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "SL20250909000100"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    
    $cmdCols = New-Object System.Data.SqlClient.SqlCommand("SELECT TOP 0 * FROM STB_MaterialLotInfo", $conn)
    $adapterCols = New-Object System.Data.SqlClient.SqlDataAdapter($cmdCols)
    $dtCols = New-Object System.Data.DataTable
    $adapterCols.Fill($dtCols) | Out-Null
    
    foreach ($col in $dtCols.Columns) {
        $colName = $col.ColumnName
        $sql = "SELECT LotID, LotNo, PackingID, PackingIdParent, [$colName] as FoundValue FROM STB_MaterialLotInfo WHERE CAST([$colName] as nvarchar(max)) LIKE '%$search%'"
        $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $adapter.Fill($dt) | Out-Null
        if ($dt.Rows.Count -gt 0) {
            Write-Host "Found matches in column: [$colName]"
            $dt | Format-Table -AutoSize
        }
    }
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
