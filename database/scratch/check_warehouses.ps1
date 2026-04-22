$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $sql = "SELECT MaterialWarehouseCode, MaterialWarehouseName, CompanyCode, WorkCenterCode FROM STB_MaterialWarehouse WHERE MaterialWarehouseCode IN ('ROH_BG_WH', 'MODULE_BG2_WH')"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $reader = $cmd.ExecuteReader()
    Write-Host "--- STB_MaterialWarehouse Information ---"
    while ($reader.Read()) {
        $row = ""
        for($i=0; $i -lt $reader.FieldCount; $i++) {
            $row += "$($reader.GetName($i)): $($reader.GetValue($i)) | "
        }
        Write-Host $row
    }
    $reader.Close()
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
