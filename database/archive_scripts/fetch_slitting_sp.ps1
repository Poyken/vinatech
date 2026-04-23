[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"

$query = @"
SELECT sm.definition 
FROM sys.sql_modules sm
JOIN sys.procedures sp ON sm.object_id = sp.object_id
WHERE sp.name = 'usp_Vietnam_SlittingStock_get'
"@

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    $reader = $cmd.ExecuteReader()
    if ($reader.Read()) {
        $reader.GetString(0) | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_Vietnam_SlittingStock_get.sql" -Encoding UTF8
    }
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
