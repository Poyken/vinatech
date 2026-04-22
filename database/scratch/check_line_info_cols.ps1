Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 1 * FROM STB_LineInfo"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    $row = ""
    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
        $row += "$($reader.GetName($i)), "
    }
    Write-Host $row
}
$conn.Close()
