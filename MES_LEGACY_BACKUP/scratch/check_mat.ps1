. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
SELECT SI.Barcode, SI.MaterialCode, MM.MaterialName
FROM STB_SetInfo SI
LEFT JOIN STB_MaterialMaster MM ON SI.MaterialCode = MM.MaterialCode
WHERE SI.Barcode = 'VVQO193R072762'
"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null
$conn.Close()
$ds.Tables[0] | Format-Table -AutoSize
