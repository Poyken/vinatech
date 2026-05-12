# AUTO CHECK COMMON MES ISSUES
# Mục đích: Tự động kiểm tra các lỗi thường gặp
# Cách dùng: .\auto_check_common_issues.ps1

param(
    [string]$Barcode,
    [string]$PONo,
    [string]$MaterialCode
)

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

Write-Host "=== AUTO CHECK COMMON MES ISSUES ===" -ForegroundColor Cyan

if ($Barcode) {
    Write-Host "`n🔍 Checking Barcode: $Barcode" -ForegroundColor Yellow
    
    # Check 1: Barcode exists in SetInfo
    Write-Host "`n[1] Check: Barcode exists in STB_SetInfo" -ForegroundColor Green
    $sql = "SELECT COUNT(*) as Count FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'"
    $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -h -1 -W
    if ($result -eq "0") {
        Write-Host "❌ Barcode NOT FOUND in STB_SetInfo" -ForegroundColor Red
    } else {
        Write-Host "✅ Barcode FOUND in STB_SetInfo" -ForegroundColor Green
        
        # Check 2: IsProdFinish status
        Write-Host "`n[2] Check: Production status" -ForegroundColor Green
        $sql = "SELECT IsProdFinish, LotDecisionResult, IsDefect FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'"
        $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -W -s "," -h -1
        Write-Host $result
        
        # Check 3: Routing status
        Write-Host "`n[3] Check: Routing completion" -ForegroundColor Green
        $controlNo = sqlcmd -S $server -d $database -U $user -P $password -C -Q "SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'" -h -1 -W
        $controlNo = $controlNo.Trim()
        
        if ($controlNo -ne "" -and $controlNo -ne "ControlNo") {
            $sql = "SELECT COUNT(*) as Count, MIN(RouteCode) as FirstRoute, MAX(RouteCode) as LastRoute FROM STB_ProdRouteHist WHERE ControlNo = '$controlNo'"
            $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -W -s "," -h -1
            Write-Host $result
        }
    }
}

if ($PONo) {
    Write-Host "`n🔍 Checking PO: $PONo" -ForegroundColor Yellow
    
    # Check 1: PO exists
    Write-Host "`n[1] Check: PO exists in STB_ProductionOrderInfo" -ForegroundColor Green
    $sql = "SELECT COUNT(*) as Count FROM STB_ProductionOrderInfo WHERE PONo = '$PONo'"
    $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -h -1 -W
    if ($result -eq "0") {
        Write-Host "❌ PO NOT FOUND" -ForegroundColor Red
    } else {
        Write-Host "✅ PO FOUND" -ForegroundColor Green
        
        # Check 2: PO status
        Write-Host "`n[2] Check: PO status" -ForegroundColor Green
        $sql = "SELECT IsFinish, IsFix, PlannedQty, ProdFinishQty FROM STB_ProductionOrderInfo WHERE PONo = '$PONo'"
        $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -W -s "," -h -1
        Write-Host $result
        
        # Check 3: PO routing
        Write-Host "`n[3] Check: PO routing" -ForegroundColor Green
        $sql = "SELECT COUNT(*) as RouteCount FROM STB_ProductionOrderRouting WHERE PONo = '$PONo'"
        $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -h -1 -W
        Write-Host "Routes: $result"
    }
}

if ($MaterialCode) {
    Write-Host "`n🔍 Checking Material: $MaterialCode" -ForegroundColor Yellow
    
    # Check 1: Material exists
    Write-Host "`n[1] Check: Material exists in STB_MaterialMaster" -ForegroundColor Green
    $sql = "SELECT COUNT(*) as Count FROM STB_MaterialMaster WHERE MaterialCode = '$MaterialCode'"
    $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -h -1 -W
    if ($result -eq "0") {
        Write-Host "❌ Material NOT FOUND" -ForegroundColor Red
    } else {
        Write-Host "✅ Material FOUND" -ForegroundColor Green
        
        # Check 2: Material stock
        Write-Host "`n[2] Check: Material stock" -ForegroundColor Green
        $sql = "SELECT StockQty, AllocQty, AvailableQty FROM STB_MaterialStock WHERE MaterialCode = '$MaterialCode'"
        $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -W -s "," -h -1
        Write-Host $result
        
        # Check 3: Material in ModelBasicInfo
        Write-Host "`n[3] Check: Material in ModelBasicInfo" -ForegroundColor Green
        $sql = "SELECT COUNT(*) as Count FROM STB_ModelBasicInfo WHERE ModelCode = '$MaterialCode'"
        $result = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql -h -1 -W
        if ($result -eq "0") {
            Write-Host "⚠️ Material NOT in ModelBasicInfo (may need to add)" -ForegroundColor Yellow
        } else {
            Write-Host "✅ Material in ModelBasicInfo" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== CHECK COMPLETE ===" -ForegroundColor Cyan
