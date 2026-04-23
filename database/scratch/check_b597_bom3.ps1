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
SELECT TOP 1 h.BomHeaderNo 
FROM STB_BomHeader h 
WHERE h.ModelCode = (SELECT ModelCode FROM STB_ModelBasicInfo WHERE ModelName LIKE '%WEC3R0606QG%')
ORDER BY h.CreateDateTime DESC
"
$bomHeaderNo = $cmd.ExecuteScalar()
Write-Host "BomHeaderNo: $bomHeaderNo"

$cmd.CommandText = "
SELECT d.MaterialCode, mm.MaterialName, d.Qty
FROM STB_BomDetail d
JOIN STB_MaterialMaster mm ON d.MaterialCode = mm.MaterialCode
WHERE d.BomHeaderNo = @BomHeaderNo
AND (d.MaterialCode LIKE '%GBCP%' OR d.MaterialCode LIKE '%GBEC%')
"
$cmd.Parameters.AddWithValue("@BomHeaderNo", $bomHeaderNo) | Out-Null
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "   -> MaterialCode: " $reader["MaterialCode"] " | Name: " $reader["MaterialName"]
}
$reader.Close()
$conn.Close()
