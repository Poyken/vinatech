Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
SELECT t.name AS TableName, c.name AS ColumnName
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.name IN ('LineCode', 'MaterialWarehouseCode')
ORDER BY t.name, c.name
"
$reader = $cmd.ExecuteReader()
$tables = @{}
while ($reader.Read()) {
    $t = $reader['TableName']
    $c = $reader['ColumnName']
    if (-not $tables.ContainsKey($t)) { $tables[$t] = @() }
    $tables[$t] += $c
}
foreach ($t in $tables.Keys) {
    if ($tables[$t].Count -ge 2) {
        Write-Host "Table: $t has both LineCode and MaterialWarehouseCode"
    } else {
        Write-Host "Table: $t has only $($tables[$t][0])"
    }
}
$conn.Close()
