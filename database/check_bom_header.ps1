Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
    SELECT * 
    FROM STB_BomHeader 
    WHERE MaterialCode LIKE '%VEC3R0406QC%'
"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Model: $($reader['MaterialCode']) | Version: $($reader['BomVersion'])"
}
$conn.Close()
