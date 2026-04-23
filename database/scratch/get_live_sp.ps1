[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=15;"

$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.usp_Vietnam_RawMaterialInputHist_uid'))"

$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    $content = $reader[0].ToString()
    [System.IO.File]::WriteAllText(".\scratch\live_sp.txt", $content, [System.Text.Encoding]::UTF8)
}
$reader.Close()
$conn.Close()
