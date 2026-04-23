Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = "UPDATE STB_MaterialMaster SET MMExtInt01 = 1200 WHERE MaterialCode = 'TRAY1320-B015';"

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
try {
    $rows = $cmd.ExecuteNonQuery()
    Write-Host "Successfully updated shelf life for TRAY1320-B015. Rows affected: $rows"
} catch {
    Write-Host "Failed to update: $($_.Exception.Message)"
}
$conn.Close()
