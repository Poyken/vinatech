. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
SELECT TOP 10 ID, LotNo, CartonBoxNo, BoxSerialNo, PrintTime, PrintUserID
FROM STB_SanminaIndiaLabelPrintHist
ORDER BY ID DESC
"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null
$conn.Close()
$ds.Tables[0] | Format-Table -AutoSize
