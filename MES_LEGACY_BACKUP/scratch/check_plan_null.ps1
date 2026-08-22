. (Join-Path $PSScriptRoot "..\db_shared.ps1")
$conn = Get-DbConnection
$conn.Open()
$tran = $conn.BeginTransaction()

try {
    # 1. Update StartSerial = NULL cho Plan 7 trong transaction
    $cmdUpdate = $conn.CreateCommand()
    $cmdUpdate.Transaction = $tran
    $cmdUpdate.CommandText = "UPDATE STB_SanminaShipmentPlan SET StartSerial = NULL WHERE PlanID = 7;"
    $cmdUpdate.ExecuteNonQuery() | Out-Null

    # 2. Test voi Lot Tuan 25 (VVQO203R072758)
    $cmdTest1 = $conn.CreateCommand()
    $cmdTest1.Transaction = $tran
    $cmdTest1.CommandText = "
        CREATE TABLE #r1 (
            SupplierName varchar(50), PartNumber varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
            Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
            PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
            CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
            Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
        ); 
        INSERT INTO #r1 EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pLotNo = 'VVQO203R072758'; 
        SELECT LabelClass, PONumber, LotNo, LotCode2, CartonBoxNo, BoxSerialNo FROM #r1;
    "
    $adapter1 = New-Object System.Data.SqlClient.SqlDataAdapter($cmdTest1)
    $ds1 = New-Object System.Data.DataSet
    $adapter1.Fill($ds1) | Out-Null
    Write-Host "`n=== KHI STARTSERIAL = NULL: QUET LOT TUAN 25 (VVQO203R072758 - CUNG TUAN 25) ===" -ForegroundColor Yellow
    $ds1.Tables[0] | Format-Table -AutoSize

    # 3. Test voi Lot Tuan 31 (VVQQ023R072718 - Tuan moi)
    $cmdTest2 = $conn.CreateCommand()
    $cmdTest2.Transaction = $tran
    $cmdTest2.CommandText = "
        CREATE TABLE #r2 (
            SupplierName varchar(50), PartNumber varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
            Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
            PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
            CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
            Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
        ); 
        INSERT INTO #r2 EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pLotNo = 'VVQQ023R072718'; 
        SELECT LabelClass, PONumber, LotNo, LotCode2, CartonBoxNo, BoxSerialNo FROM #r2;
    "
    $adapter2 = New-Object System.Data.SqlClient.SqlDataAdapter($cmdTest2)
    $ds2 = New-Object System.Data.DataSet
    $adapter2.Fill($ds2) | Out-Null
    Write-Host "=== KHI STARTSERIAL = NULL: QUET LOT TUAN 31 (VVQQ023R072718 - TUAN MOI) ===" -ForegroundColor Green
    $ds2.Tables[0] | Format-Table -AutoSize
} finally {
    $tran.Rollback()
    $conn.Close()
}
