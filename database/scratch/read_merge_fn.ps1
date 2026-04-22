Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_getdatebyVendorLot_MergeCode'))"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        $res.ToString() | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\fn_VVT_getdatebyVendorLot_MergeCode.sql" -Encoding UTF8
        Write-Host "Success: Extracted fn_VVT_getdatebyVendorLot_MergeCode"
    } else {
        Write-Host "Error: Function not found."
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
