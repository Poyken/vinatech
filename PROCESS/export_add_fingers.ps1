. "$PSScriptRoot\DATABASE\tools\db_shared.ps1"
$db = Get-DBConnection -Profile SmartFactoryV2

$cmd = $db.Connection.CreateCommand()
$cmd.CommandText = "SELECT definition FROM OPENQUERY([CMS_VINA_LINK], 'SELECT definition FROM CMS_VINA.sys.sql_modules WHERE object_id = OBJECT_ID(''CMS_VINA.dbo.Add_Fingers'')')"
$cmd.CommandTimeout = 60
$def = $cmd.ExecuteScalar()
[System.IO.File]::WriteAllText("$PSScriptRoot\CMS_Add_Fingers.sql", $def, [System.Text.Encoding]::UTF8)
Write-Host "Exported Add_Fingers, Length: $($def.Length)"
