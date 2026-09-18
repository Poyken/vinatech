param()
$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared
$conn = Get-DbConnection -Profile "SmartFactoryV2"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_MaterialWarehouseInOutHist_iud_exportElectr'))"
$result = $cmd.ExecuteScalar()
$conn.Close()
$outPath = Join-Path $PSScriptRoot "sp_export_electr.sql"
$result | Out-File -FilePath $outPath -Encoding UTF8
Write-Host "Saved SP to $outPath (Length: $($result.Length) chars)"
