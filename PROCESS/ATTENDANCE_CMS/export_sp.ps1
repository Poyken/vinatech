. "$PSScriptRoot\DATABASE\tools\db_shared.ps1"
$db = Get-DBConnection -Profile SmartFactoryV2
$cmd = $db.Connection.CreateCommand()
$cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('usp_SyncFingerData')"
$cmd.CommandTimeout = 60
$def = $cmd.ExecuteScalar()
[System.IO.File]::WriteAllText("$PSScriptRoot\usp_SyncFingerData.sql", $def, [System.Text.Encoding]::UTF8)
Write-Host "Exported usp_SyncFingerData, Length: $($def.Length)"
