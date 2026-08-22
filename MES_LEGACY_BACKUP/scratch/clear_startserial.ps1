. (Join-Path $PSScriptRoot "..\db_shared.ps1")
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "UPDATE STB_SanminaShipmentPlan SET StartSerial = NULL WHERE PlanID = 7;"
$rows = $cmd.ExecuteNonQuery()
$conn.Close()
Write-Host "Da cap nhat StartSerial = NULL cho Plan 7 thanh cong! (Rows: $rows)" -ForegroundColor Green
