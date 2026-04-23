Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.fn_VVT_getdatebyVendorLot_MergeCode')) AS def"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) { [System.IO.File]::WriteAllText('.\scratch\fn_MergeCode.sql', $reader['def'].ToString()) }
$reader.Close()

$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.fn_VVT_getdatebyVendorLot')) AS def"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) { [System.IO.File]::WriteAllText('.\scratch\fn_Original.sql', $reader['def'].ToString()) }
$reader.Close()

$conn.Close()
