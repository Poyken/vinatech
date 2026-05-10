$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$today = (Get-Date).ToString("yyyy-MM-dd")

$sql = "SELECT TOP 10 LotID, ProcessedLotID, SourceMaterialWarehouseCode, TargetMaterialWarehouseCode, CreateDateTime 
        FROM STB_MaterialWarehouseInOutHist 
        WHERE CAST(CreateDateTime as DATE) = '$today'
        ORDER BY CreateDateTime DESC"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "No warehouse history found for today ($today)."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
