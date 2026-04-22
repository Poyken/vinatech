Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # Extract usp_DoChangeMaterialDocLotInfo
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_DoChangeMaterialDocLotInfo'))"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        $res.ToString() | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_DoChangeMaterialDocLotInfo.sql" -Encoding UTF8
        Write-Host "Extracted usp_DoChangeMaterialDocLotInfo"
    }

    # Extract usp_DoUpdateVendorLotNoManual
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_DoUpdateVendorLotNoManual'))"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        $res.ToString() | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_DoUpdateVendorLotNoManual.sql" -Encoding UTF8
        Write-Host "Extracted usp_DoUpdateVendorLotNoManual"
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
