. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('STB_SanminaShipmentPlan', 'STB_SanminaIndiaLabelPrintHist', 'STB_SanminaShipmentPlanLot')
ORDER BY TABLE_NAME, ORDINAL_POSITION
"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null
$conn.Close()
$ds.Tables[0] | Format-Table -AutoSize
