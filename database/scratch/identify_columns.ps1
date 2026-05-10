$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$lotNo = "649873-2100"
$sql = "SELECT * FROM STB_MaterialLotInfo WHERE LotNo = '$lotNo'"

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
            $val = $row[$col.ColumnName]
            if ($val -ne $null -and $val.ToString().Contains("ML20250825000072")) {
                Write-Host "Column [$($col.ColumnName)] contains 'ML20250825000072': $val"
            }
            if ($val -ne $null -and $val.ToString().Contains("SL20250909000100")) {
                Write-Host "Column [$($col.ColumnName)] contains 'SL20250909000100': $val"
            }
        }
    }
} catch {
    Write-Error $_.Exception.Message
}
