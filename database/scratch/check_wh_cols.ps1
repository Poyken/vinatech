$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $sql = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_MaterialWarehouse'"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Columns in STB_MaterialWarehouse ---"
    while ($reader.Read()) {
        Write-Host "- $($reader['COLUMN_NAME'])"
    }
    $reader.Close()
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
