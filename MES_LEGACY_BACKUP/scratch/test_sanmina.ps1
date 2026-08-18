. (Join-Path $PSScriptRoot "..\db_shared.ps1")
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
CREATE TABLE #res (
    SupplierName varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
    Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
    PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
    CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
    Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
); 
INSERT INTO #res EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pPONumber = 'PO12345', @pLotNo = 'VVPS043R072701', @pQuantity = '100', @pTotalBox = 2; 
SELECT LabelClass, CartonBoxNo, BoxSerialNo, PrintSerialNo, SerialListForQR FROM #res;
"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null
$conn.Close()
$ds.Tables[0] | Format-Table -AutoSize
