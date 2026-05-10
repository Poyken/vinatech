$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "SL20250909000100"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    
    # Search in common ID columns
    $sql = "SELECT * FROM STB_MaterialLotInfo WHERE LotID LIKE '%$search%' OR LotNo LIKE '%$search%' OR PackingID LIKE '%$search%' OR PackingIdParent LIKE '%$search%' OR LotAttr01 LIKE '%$search%' OR LotAttr02 LIKE '%$search%'"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "No records found matching '$search' in key columns."
    } else {
        # Show only first 5 to avoid massive output, but show all columns
        $dt | Select-Object -First 5 | Format-List
    }
} catch {
    Write-Error $_.Exception.Message
}
