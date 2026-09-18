param()
$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared
$conn = Get-DbConnection -Profile "SmartFactoryV2"
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SELECT DISTINCT OBJECT_NAME(sm.object_id) AS ObjectName, o.type_desc 
FROM sys.sql_modules sm 
JOIN sys.objects o ON sm.object_id = o.object_id 
WHERE sm.definition LIKE '%INTO STB_MaterialLotInfo%' 
ORDER BY ObjectName;
"@
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
$conn.Close()
$dt | Format-Table -AutoSize
