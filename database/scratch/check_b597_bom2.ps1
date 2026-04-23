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
SELECT h.ModelCode, m.ModelName, d.MaterialCode, mm.MaterialName
FROM STB_BomHeader h
JOIN STB_ModelBasicInfo m ON h.ModelCode = m.ModelCode
JOIN STB_BomDetail d ON h.BomHeaderNo = d.BomHeaderNo
JOIN STB_MaterialMaster mm ON d.MaterialCode = mm.MaterialCode
WHERE m.ModelName LIKE '%WEC3R0606QG%'
AND (d.MaterialCode LIKE '%GBCP%' OR d.MaterialCode LIKE '%GBEC%')
"

$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "ModelCode: " $reader["ModelCode"] " | ModelName: " $reader["ModelName"] " | MaterialCode: " $reader["MaterialCode"] " | MaterialName: " $reader["MaterialName"]
}
$reader.Close()
$conn.Close()
