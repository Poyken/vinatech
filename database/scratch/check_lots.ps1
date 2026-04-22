$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $lots = "'ML20251120000334', 'SP2026040202024296', 'ML20251120000332', 'ML20251120000330', 'ML20251120000329', 'ML20251120000328', 'ML20250521001482'"
    $sql = "SELECT LotID, MaterialCode, MaterialLotNo, CurrentQty, MaterialWarehouseCode, WorkCenterCode FROM STB_MaterialLotInfo WHERE LotID IN ($lots)"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Lot ID Information ---"
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
