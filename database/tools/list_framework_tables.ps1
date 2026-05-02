Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sys.objects WHERE type = 'U' AND (name LIKE 'STB_Menu%' OR name LIKE 'STB_Function%' OR name LIKE 'STB_Procedure%' OR name LIKE 'STB_Program%')"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host $reader['name']
}
$conn.Close()
