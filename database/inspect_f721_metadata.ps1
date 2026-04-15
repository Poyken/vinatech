Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 10 * FROM STB_ScreenInfo WHERE ProjectID = 'VVT' OR ScreenID LIKE '%F721%'"
$reader = $cmd.ExecuteReader()
$cols = $reader.FieldCount
while ($reader.Read()) {
    Write-Host "--- Screen ---"
    for ($i = 0; $i -lt $cols; $i++) {
        Write-Host "$($reader.GetName($i)) : $($reader.GetValue($i))"
    }
}
$reader.Close()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 50 * FROM STB_ScreenObjects WHERE ScreenID LIKE '%F721%'"
$reader = $cmd.ExecuteReader()
$cols = $reader.FieldCount
while ($reader.Read()) {
    Write-Host "--- Object ---"
    for ($i = 0; $i -lt $cols; $i++) {
        Write-Host "$($reader.GetName($i)) : $($reader.GetValue($i))"
    }
}
$reader.Close()

$conn.Close()
