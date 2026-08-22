. (Join-Path $PSScriptRoot "..\db_shared.ps1")
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
CREATE TABLE #r (
    SupplierName varchar(50), PartNumber varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
    Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
    PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
    CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
    Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
); 
INSERT INTO #r EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pLotNo = 'VVQP313R072705'; 
SELECT LabelClass, PONumber, LotNo, LotCode, LotCode2, CartonBoxNo, BoxSerialNo FROM #r;
"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null

$cmdPlan = $conn.CreateCommand()
$cmdPlan.CommandText = "SELECT * FROM STB_SanminaShipmentPlan WHERE IsActive = 1;"
$dsPlan = New-Object System.Data.DataSet
$adapterPlan = New-Object System.Data.SqlClient.SqlDataAdapter($cmdPlan)
$adapterPlan.Fill($dsPlan) | Out-Null

$conn.Close()

Write-Host "=== KET QUA EXEC SP CHO LOT: VVQO203R072758 ===" -ForegroundColor Green
$ds.Tables[0] | Format-Table -AutoSize

Write-Host "=== PLAN DANG ACTIVE TREN HE THONG ===" -ForegroundColor Yellow
$dsPlan.Tables[0] | Format-Table -AutoSize
