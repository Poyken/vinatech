$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sys.procedures ORDER BY name"
$reader = $cmd.ExecuteReader()
$sps = New-Object System.Collections.Generic.List[string]
while($reader.Read()){ $sps.Add($reader[0]) }
$conn.Close()
$sps | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\all_sps_list.txt" -Encoding UTF8
"Found $($sps.Count) procedures. List saved to all_sps_list.txt"
