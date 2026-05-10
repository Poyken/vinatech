$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "SL20250909000100"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    
    # Get all column names
    $cmd = New-Object System.Data.SqlClient.SqlCommand("SELECT TOP 0 * FROM STB_MaterialLotInfo", $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dtCols = New-Object System.Data.DataTable
    $adapter.Fill($dtCols) | Out-Null
    
    $whereClauses = @()
    foreach ($col in $dtCols.Columns) {
        if ($col.DataType -eq [string]) {
            $whereClauses += "[$($col.ColumnName)] = '$search'"
        }
    }
    
    $sql = "SELECT LotNo, MaterialCode, CurrentQty, PackingIdParent, IsSlitting, CreateDateTime FROM STB_MaterialLotInfo WHERE " + ($whereClauses -join " OR ")
    
    $cmdSearch = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapterSearch = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSearch)
    $dtResults = New-Object System.Data.DataTable
    $adapterSearch.Fill($dtResults) | Out-Null
    
    $conn.Close()

    if ($dtResults.Rows.Count -eq 0) {
        Write-Host "No data found for '$search' in any string column of STB_MaterialLotInfo."
    } else {
        $dtResults | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
