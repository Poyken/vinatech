# AUTO DEBUG BARCODE SCRIPT
# Mục đích: Tự động debug barcode khi user báo lỗi
# Cách dùng: .\auto_debug_barcode.ps1 -Barcode "VE260506-001"

param(
    [Parameter(Mandatory=$true)]
    [string]$Barcode
)

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

Write-Host "=== DEBUG BARCODE: $Barcode ===" -ForegroundColor Cyan

# 1. Check SetInfo
Write-Host "`n[1] Checking SetInfo..." -ForegroundColor Yellow
$sql1 = "SELECT Barcode, ControlNo, PONo, MaterialCode, ProdQty, IsLineInput, IsProdFinish, LotDecisionResult, IsDefect, DefectQty FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'"
$result1 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql1 -W -s "," -h -1
Write-Host $result1

# 2. Get ControlNo
$controlNo = sqlcmd -S $server -d $database -U $user -P $password -C -Q "SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'" -h -1 -W
$controlNo = $controlNo.Trim()

if ($controlNo -eq "" -or $controlNo -eq "ControlNo") {
    Write-Host "ERROR: Barcode not found in STB_SetInfo" -ForegroundColor Red
    exit
}

Write-Host "`n[2] ControlNo: $controlNo" -ForegroundColor Green

# 3. Check ProdRouteHist
Write-Host "`n[3] Checking ProdRouteHist..." -ForegroundColor Yellow
$sql2 = "SELECT RouteCode, ProdQty, WorkerCode, MachineCode, ProdDateTime, CreateDateTime FROM STB_ProdRouteHist WHERE ControlNo = '$controlNo' ORDER BY CreateDateTime"
$result2 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql2 -W -s "," -h -1
Write-Host $result2

# 4. Check PO
Write-Host "`n[4] Checking Production Order..." -ForegroundColor Yellow
$poNo = sqlcmd -S $server -d $database -U $user -P $password -C -Q "SELECT PONo FROM STB_SetInfo WHERE ControlNo = '$controlNo'" -h -1 -W
$poNo = $poNo.Trim()

if ($poNo -ne "" -and $poNo -ne "PONo") {
    $sql3 = "SELECT PONo, MaterialCode, PlannedQty, ProdFinishQty, POType, IsFinish FROM STB_ProductionOrderInfo WHERE PONo = '$poNo'"
    $result3 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql3 -W -s "," -h -1
    Write-Host $result3
}

# 5. Check Defect
Write-Host "`n[5] Checking Defect..." -ForegroundColor Yellow
$sql4 = "SELECT FindRouteCode, BasicDefectGroupName, DefectName, DefectQty, CreateDateTime FROM STB_DefectRepairInfo WHERE ControlNo = '$controlNo' ORDER BY CreateDateTime DESC"
$result4 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql4 -W -s "," -h -1
Write-Host $result4

# 6. Check Procedure Log
Write-Host "`n[6] Checking Procedure Log (last 24h)..." -ForegroundColor Yellow
$sql5 = "SELECT TOP 10 ProcedureName, VariableName, VariableValue, CreateDateTime FROM STB_ProcedureLog WHERE VariableValue LIKE '%$Barcode%' AND CreateDateTime >= DATEADD(HOUR, -24, GETDATE()) ORDER BY CreateDateTime DESC"
$result5 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql5 -W -s "," -h -1
Write-Host $result5

Write-Host "`n=== DEBUG COMPLETE ===" -ForegroundColor Cyan
