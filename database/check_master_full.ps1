Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 20 MaterialCode, MaterialName, MaterialNameL, MaterialSpec FROM STB_MaterialMaster WHERE MaterialCode = 'GBAKAC-608' OR MaterialCode LIKE 'GBAKAC%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode']) | Name: $($reader['MaterialName']) | NameL: $($reader['MaterialNameL']) | Spec: $($reader['MaterialSpec'])"
}
$reader.Close()
$conn.Close()
