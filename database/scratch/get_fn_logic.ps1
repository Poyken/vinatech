Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactory;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('fn_VVT_getdatebyVendorLot')"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        $res | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\fn_VVT_getdatebyVendorLot.sql" -Encoding UTF8
        Write-Host "Function definition saved successfully."
    } else {
        Write-Host "Function not found."
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
