. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
SELECT PlanID, PlanCode, PONumber, PartNumber, LotNo, QtyPerBox, TotalBox, PrintedBoxCount, StartSerial, IsActive, Status, CreateDateTime
FROM STB_SanminaShipmentPlan
ORDER BY PlanID DESC
"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null

$cmdHist = $conn.CreateCommand()
$cmdHist.CommandText = "
SELECT TOP 10 ID, LotNo, CartonBoxNo, LabelClass, BoxSerialNo, PrintSerialNo, InsertDate
FROM STB_SanminaIndiaLabelPrintHist
ORDER BY ID DESC
"
$adapterHist = New-Object System.Data.SqlClient.SqlDataAdapter($cmdHist)
$dsHist = New-Object System.Data.DataSet
$adapterHist.Fill($dsHist) | Out-Null

$conn.Close()

Write-Output "=== STB_SanminaShipmentPlan ==="
$ds.Tables[0] | Format-Table -AutoSize

Write-Output "=== STB_SanminaIndiaLabelPrintHist ==="
$dsHist.Tables[0] | Format-Table -AutoSize
