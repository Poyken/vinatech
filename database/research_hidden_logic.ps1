Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Search for Triggers
Write-Host "--- Database Triggers (SmartFactoryV2) ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name, parent_id, OBJECT_NAME(parent_id) as ParentTable FROM sys.triggers"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Trigger: $($reader['name']) | Table: $($reader['ParentTable'])"
}
$reader.Close()

# Search for DB Jobs / Scheduled SPs (Look for common names)
Write-Host "`n--- Potential Scheduled Jobs/SPs ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sys.procedures WHERE name LIKE '%Job%' OR name LIKE '%Batch%' OR name LIKE '%Schedule%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP: $($reader['name'])"
}
$reader.Close()

$conn.Close()

# Query Constants and BaseCodes from SmartFramework
$connStrFramework = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$connF = New-Object System.Data.SqlClient.SqlConnection($connStrFramework)
$connF.Open()

Write-Host "`n--- BaseCode Groups (Summary) ---"
$cmd = $connF.CreateCommand()
$cmd.CommandText = "SELECT TOP 20 CodeGroup, COUNT(*) as Count FROM STB_BaseCode GROUP BY CodeGroup ORDER BY Count DESC"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Group: $($reader['CodeGroup']) | Count: $($reader['Count'])"
}
$reader.Close()

Write-Host "`n--- System Constants ---"
$cmd = $connF.CreateCommand()
$cmd.CommandText = "SELECT ConstName, ConstValue, Description FROM STB_ConstCodeInfo"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Const: $($reader['ConstName']) | Value: $($reader['ConstValue'])"
}
$reader.Close()

$connF.Close()
