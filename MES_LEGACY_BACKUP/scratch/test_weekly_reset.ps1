. (Join-Path $PSScriptRoot "..\db_shared.ps1")
$conn = Get-DbConnection
$conn.Open()
$tran = $conn.BeginTransaction()

try {
    # 1. Nạp SP mới vào Transaction
    $spContent = Get-Content -Path (Join-Path $PSScriptRoot "..\sql\procedures\usp_SanminaLabelPrint_get_Vietnam.sql") -Raw -Encoding UTF8
    $cmdDeploy = $conn.CreateCommand()
    $cmdDeploy.Transaction = $tran
    $cmdDeploy.CommandText = $spContent
    $cmdDeploy.ExecuteNonQuery() | Out-Null
    Write-Host "[1/4] Da nap SP moi vao Transaction thanh cong!" -ForegroundColor Green

    # Tắt tạm Plan 7 để test chế độ auto history
    $cmdPlan = $conn.CreateCommand()
    $cmdPlan.Transaction = $tran
    $cmdPlan.CommandText = "UPDATE STB_SanminaShipmentPlan SET IsActive = 0 WHERE PlanID = 7;"
    $cmdPlan.ExecuteNonQuery() | Out-Null

    # 2. TEST CASE 1: Lot Tuần 25 (Đã có lịch sử in đến 00688) -> Phải tăng tiếp 00689, 00690
    $cmdTest1 = $conn.CreateCommand()
    $cmdTest1.Transaction = $tran
    $cmdTest1.CommandText = "
        CREATE TABLE #res1 (
            SupplierName varchar(50), PartNumber varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
            Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
            PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
            CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
            Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
        ); 
        INSERT INTO #res1 EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pLotNo = 'VVQO203R072725', @pQuantity = '102', @pTotalBox = 1; 
        SELECT LabelClass, LotCode2, CartonBoxNo, BoxSerialNo FROM #res1;
    "
    $adapter1 = New-Object System.Data.SqlClient.SqlDataAdapter($cmdTest1)
    $ds1 = New-Object System.Data.DataSet
    $adapter1.Fill($ds1) | Out-Null
    Write-Host "`n=== TEST CASE 1: LOT TUẦN 25 (Lịch sử đã có đến 00688) ===" -ForegroundColor Yellow
    $ds1.Tables[0] | Format-Table -AutoSize

    # 3. TEST CASE 2: Tạo một Lot Tuần 38 (Date = 2026-09-15 -> 3826, CHƯA TỪNG IN BAO GIỜ)
    # Thêm Lot giả lập vào STB_SetInfo bằng cách copy từ Lot hợp lệ
    $cmdInsertSet = $conn.CreateCommand()
    $cmdInsertSet.Transaction = $tran
    $cmdInsertSet.CommandText = "
        INSERT INTO STB_SetInfo (ControlNo, PONo, DayPlanNo, MaterialCode, SetSeq, IsLineInput, IsLoss, IsDefect, Barcode, IsProdFinish, CreateDateTime)
        SELECT 'TEST_999999999', PONo, DayPlanNo, MaterialCode, SetSeq, IsLineInput, IsLoss, IsDefect, 'VVQR153R072701', 1, GETDATE()
        FROM STB_SetInfo
        WHERE Barcode = 'VVQO203R072725';
    "
    $cmdInsertSet.ExecuteNonQuery() | Out-Null

    $cmdTest2 = $conn.CreateCommand()
    $cmdTest2.Transaction = $tran
    $cmdTest2.CommandText = "
        CREATE TABLE #res2 (
            SupplierName varchar(50), PartNumber varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
            Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
            PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
            CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
            Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
        ); 
        INSERT INTO #res2 EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pLotNo = 'VVQR153R072701', @pQuantity = '102', @pTotalBox = 1; 
        SELECT LabelClass, LotCode2, CartonBoxNo, BoxSerialNo FROM #res2;
    "
    $adapter2 = New-Object System.Data.SqlClient.SqlDataAdapter($cmdTest2)
    $ds2 = New-Object System.Data.DataSet
    $adapter2.Fill($ds2) | Out-Null
    Write-Host "=== TEST CASE 2: LOT TUẦN MỚI HOÀN TOÀN 38 (3826) -> PHẢI RESET VỀ 00001, 00002 ===" -ForegroundColor Green
    $ds2.Tables[0] | Format-Table -AutoSize

    # 4. TEST CASE 3: Giả lập đã in xong thùng 1 của tuần 38 (00001, 00002), quét tiếp thùng 2 -> Phải tăng lên 00003, 00004!
    $cmdInsertHist = $conn.CreateCommand()
    $cmdInsertHist.Transaction = $tran
    $cmdInsertHist.CommandText = "
        INSERT INTO STB_SanminaIndiaLabelPrintHist (
            SupplierName, SanminaPartNumber, PartDesc, MFR, MPN, Quantity, PONumber, LotNo, 
            LotCode, PackingDate, InspEmpID, InspEmpName, CartonBoxNo, PrintTime, PrintUserID, BoxSerialNo
        )
        VALUES 
        ('Vinatech Vina', 'LFIBLM164855', 'CAP,TH EDLC 720F 3V D35MMXL105MM', 'VINA TECHNOLOGY', 'VEC3R0727QG', '102', 'PO123', 'VVQR153R072701', '260915', '260822', 'OQC01', 'TESTER', '01/10', GETDATE(), 'TEST_USER', 'VINA382600001'),
        ('Vinatech Vina', 'LFIBLM164855', 'CAP,TH EDLC 720F 3V D35MMXL105MM', 'VINA TECHNOLOGY', 'VEC3R0727QG', '102', 'PO123', 'VVQR153R072701', '260915', '260822', 'OQC01', 'TESTER', '01/10', GETDATE(), 'TEST_USER', 'VINA382600002');
    "
    $cmdInsertHist.ExecuteNonQuery() | Out-Null

    $cmdTest3 = $conn.CreateCommand()
    $cmdTest3.Transaction = $tran
    $cmdTest3.CommandText = "
        CREATE TABLE #res3 (
            SupplierName varchar(50), PartNumber varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
            Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
            PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
            CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
            Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
        ); 
        INSERT INTO #res3 EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pLotNo = 'VVQR153R072701', @pQuantity = '102', @pTotalBox = 1; 
        SELECT LabelClass, LotCode2, CartonBoxNo, BoxSerialNo FROM #res3;
    "
    $adapter3 = New-Object System.Data.SqlClient.SqlDataAdapter($cmdTest3)
    $ds3 = New-Object System.Data.DataSet
    $adapter3.Fill($ds3) | Out-Null
    Write-Host "=== TEST CASE 3: QUÉT TIẾP THÙNG 2 CỦA TUẦN 38 -> PHẢI TĂNG TIẾP 00003, 00004 ===" -ForegroundColor Green
    $ds3.Tables[0] | Format-Table -AutoSize

} finally {
    $tran.Rollback()
    $conn.Close()
    Write-Host "`nĐã ROLLBACK giao dịch test an toàn 100% (Không ảnh hưởng CSDL thực)!" -ForegroundColor Cyan
}
