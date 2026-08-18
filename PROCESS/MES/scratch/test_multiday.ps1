. (Join-Path $PSScriptRoot "..\db_shared.ps1")
$conn = Get-DbConnection
$conn.Open()
$tran = $conn.BeginTransaction()

try {
    $cmdInsert = $conn.CreateCommand()
    $cmdInsert.Transaction = $tran
    $cmdInsert.CommandText = "
        INSERT INTO STB_SanminaIndiaLabelPrintHist (
            SupplierName, SanminaPartNumber, PartDesc, MFR, MPN, Quantity, PONumber, LotNo, 
            LotCode, PackingDate, InspEmpID, InspEmpName, CartonBoxNo, PrintTime, PrintUserID, BoxSerialNo
        )
        VALUES (
            'Vinatech Vina', 'LFIBLM164855', 'CAP,TH EDLC 720F 3V D35MMXL105MM', 'VINA TECHNOLOGY', 'VEC3R0727QG', 
            '100', 'PO12345', 'VVPS043R072701', '251004', '251006', 'OQC01', 'TESTER', '02/02', 
            '2026-08-17 23:59:59', 'TEST_USER', 'VINA402500062'
        );
    "
    $cmdInsert.ExecuteNonQuery() | Out-Null

    $cmdSelect = $conn.CreateCommand()
    $cmdSelect.Transaction = $tran
    $cmdSelect.CommandText = "
        CREATE TABLE #res (
            SupplierName varchar(50), SanminaPartNumber varchar(50), PartDesc nvarchar(100), MFR varchar(50), MPN varchar(50), 
            Quantity varchar(100), PONumber varchar(50), LotNo varchar(50), LotCode varchar(20), LotCode2 varchar(20), 
            PackingDate varchar(20), InspEmpID varchar(20), InspEmpName nvarchar(200), CartonBoxNo varchar(20), 
            CommandType varchar(20), LabelClass varchar(20), BoxSerialNo varchar(100), PrintSerialNo varchar(100), 
            Inner1Serial varchar(50), Inner2Serial varchar(50), SerialListForQR varchar(200)
        ); 
        INSERT INTO #res EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pPONumber = 'PO12345', @pLotNo = 'VVPS043R072701', @pQuantity = '100', @pTotalBox = 1; 
        SELECT LabelClass, CartonBoxNo, BoxSerialNo, PrintSerialNo, SerialListForQR FROM #res;
    "

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSelect)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    
    Write-Host "=== KET QUA TEST GIA LAP SANG NGAY MOI (HOM QUA = 00062) ===" -ForegroundColor Green
    $ds.Tables[0] | Format-Table -AutoSize
} finally {
    $tran.Rollback()
    $conn.Close()
    Write-Host "Da ROLLBACK giao dịch test an toan 100%!" -ForegroundColor Cyan
}
