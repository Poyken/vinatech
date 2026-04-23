Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'GBAKAC-608'"
$reader = $cmd.ExecuteReader()
$cols = $reader.FieldCount
if ($reader.Read()) {
    for ($i = 0; $i -lt $cols; $i++) {
        $name = $reader.GetName($i)
        $val = $reader.GetValue($i)
        Write-Host "$name : $val"
    }
}
$reader.Close()
$conn.Close()
