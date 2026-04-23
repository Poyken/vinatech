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
$cmd.CommandText = "
SELECT TOP 10 h.ModelCode, m.ModelName, d.MaterialCode
FROM STB_BomHeader h (NOLOCK)
JOIN STB_ModelBasicInfo m (NOLOCK) ON h.ModelCode = m.ModelCode
JOIN STB_BomDetail d (NOLOCK) ON h.BomCode = d.BomCode
WHERE m.ModelName LIKE '%WEC3R0606QG%'
"
# Wait, I don't know the exact join column.
# Let me query the schema of BomHeader and BomDetail
$cmd.CommandText = "
SELECT COLUMN_NAME, TABLE_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('STB_BomHeader', 'STB_BomDetail', 'STB_ModelBasicInfo')
AND COLUMN_NAME LIKE '%Bom%' OR COLUMN_NAME LIKE '%Model%' OR COLUMN_NAME LIKE '%Code%'
"

$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host $reader["TABLE_NAME"] "-" $reader["COLUMN_NAME"]
}
$reader.Close()

$conn.Close()
