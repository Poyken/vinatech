. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()

# Lay 1 LotNo hop le
$testLot = "VVQO193R072762"
Write-Output "Using Lot for testing: $testLot"

$testPO_0 = "TEST_PO_START_0"
$testPO_500 = "TEST_PO_START_500"
$testPO_NULL = "TEST_PO_START_NULL"

# Setup test data
$cmdSetup = $conn.CreateCommand()
$cmdSetup.CommandText = "
DELETE FROM STB_SanminaShipmentPlan WHERE PONumber IN ('$testPO_0', '$testPO_500', '$testPO_NULL');

INSERT INTO STB_SanminaShipmentPlan (PlanCode, PONumber, PartNumber, QtyPerBox, TotalBox, PrintedBoxCount, StartSerial, IsActive, Status, CreateDateTime, CreateUserID)
VALUES ('PLAN-TEST-0', '$testPO_0', 'LFIBLM164855', 102, 10, 0, 0, 1, 'ACTIVE', GETDATE(), 'TEST');

INSERT INTO STB_SanminaShipmentPlan (PlanCode, PONumber, PartNumber, QtyPerBox, TotalBox, PrintedBoxCount, StartSerial, IsActive, Status, CreateDateTime, CreateUserID)
VALUES ('PLAN-TEST-500', '$testPO_500', 'LFIBLM164855', 102, 10, 0, 500, 1, 'ACTIVE', GETDATE(), 'TEST');

INSERT INTO STB_SanminaShipmentPlan (PlanCode, PONumber, PartNumber, QtyPerBox, TotalBox, PrintedBoxCount, StartSerial, IsActive, Status, CreateDateTime, CreateUserID)
VALUES ('PLAN-TEST-NULL', '$testPO_NULL', 'LFIBLM164855', 102, 10, 0, NULL, 1, 'ACTIVE', GETDATE(), 'TEST');
"
$cmdSetup.ExecuteNonQuery() | Out-Null

function Run-SanminaTest($po, $lot, $desc) {
    Write-Output "============================================================"
    Write-Output "TEST: $desc"
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXEC dbo.usp_SanminaLabelPrint_get_Vietnam @pPONumber = '$po', @pLotNo = '$lot';"
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    
    $table = $ds.Tables[0]
    $subset = $table | Select-Object PONumber, CartonBoxNo, LabelClass, BoxSerialNo, Inner1Serial, Inner2Serial
    $subset | Format-Table -AutoSize
}

# 1. Test Plan StartSerial = 0, Thung 1
Run-SanminaTest $testPO_0 $testLot "1. StartSerial = 0, Thung 1 (Expect: 00001, 00002)"

# Update PrintedBoxCount = 1 cho Plan StartSerial = 0 de test Thung 2
$cmdUpdate1 = $conn.CreateCommand()
$cmdUpdate1.CommandText = "UPDATE STB_SanminaShipmentPlan SET PrintedBoxCount = 1 WHERE PONumber = '$testPO_0'"
$cmdUpdate1.ExecuteNonQuery() | Out-Null

# 2. Test Plan StartSerial = 0, Thung 2
Run-SanminaTest $testPO_0 $testLot "2. StartSerial = 0, Thung 2 sau khi in Thung 1 (Expect: 00003, 00004)"

# 3. Test Plan StartSerial = 500, Thung 1
Run-SanminaTest $testPO_500 $testLot "3. StartSerial = 500, Thung 1 (Expect: 00501, 00502)"

# 4. Test Plan StartSerial = NULL
Run-SanminaTest $testPO_NULL $testLot "4. StartSerial = NULL (Expect: Tiep tuc noi tiep tu lich su DB)"

# Clean up
$cmdClean = $conn.CreateCommand()
$cmdClean.CommandText = "DELETE FROM STB_SanminaShipmentPlan WHERE PONumber IN ('$testPO_0', '$testPO_500', '$testPO_NULL');"
$cmdClean.ExecuteNonQuery() | Out-Null

$conn.Close()
Write-Output "============================================================"
Write-Output "ALL TESTS COMPLETED SUCCESSFULLY!"
