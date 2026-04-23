$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT COUNT(*) FROM sys.procedures"
$count = $cmd.ExecuteScalar()
$conn.Close()
"Total SPs in Database: $count" | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\sp_count.txt"
