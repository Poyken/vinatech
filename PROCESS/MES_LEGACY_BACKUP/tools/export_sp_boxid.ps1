param()
$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared
$conn = Get-DbConnection -Profile "SmartFactoryV2"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_GetBoxIDForLotNo_VVT'))"
$def = $cmd.ExecuteScalar()
$conn.Close()
$outPath = Join-Path $PSScriptRoot "usp_Vietnam_GetBoxIDForLotNo_VVT.sql"
[System.IO.File]::WriteAllText($outPath, $def, [System.Text.Encoding]::UTF8)
Write-Host "Exported SP, Length: $($def.Length)"
