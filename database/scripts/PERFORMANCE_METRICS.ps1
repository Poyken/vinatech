# PERFORMANCE METRICS - Track and Optimize Debug Script Performance
# Mục đích: Theo dõi và tối ưu hóa hiệu suất debug scripts
# Cách dùng: .\PERFORMANCE_METRICS.ps1 -Script "auto_debug_barcode.ps1" -Barcode "VE260506-001"

param(
    [string]$Script,
    [string]$Barcode,
    [string]$PONo,
    [string]$MaterialCode
)

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

Write-Host "=== PERFORMANCE METRICS ===" -ForegroundColor Cyan

# Start timer
$startTime = Get-Date

if ($Script -eq "auto_debug_barcode.ps1" -and $Barcode) {
    Write-Host "`nRunning auto_debug_barcode.ps1..." -ForegroundColor Yellow
    
    # Step 1: Check SetInfo
    $step1Start = Get-Date
    $sql1 = "SELECT COUNT(*) as Count FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'"
    $result1 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql1 -h -1 -W
    $step1End = Get-Date
    $step1Duration = ($step1End - $step1Start).TotalSeconds
    
    Write-Host "Step 1 (Check SetInfo): $step1Duration seconds" -ForegroundColor Green
    
    # Step 2: Check ProdRouteHist
    $step2Start = Get-Date
    $controlNo = sqlcmd -S $server -d $database -U $user -P $password -C -Q "SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '$Barcode' OR ControlNo = '$Barcode'" -h -1 -W
    $controlNo = $controlNo.Trim()
    
    if ($controlNo -ne "" -and $controlNo -ne "ControlNo") {
        $sql2 = "SELECT COUNT(*) as Count FROM STB_ProdRouteHist WHERE ControlNo = '$controlNo'"
        $result2 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql2 -h -1 -W
    }
    $step2End = Get-Date
    $step2Duration = ($step2End - $step2Start).TotalSeconds
    
    Write-Host "Step 2 (Check ProdRouteHist): $step2Duration seconds" -ForegroundColor Green
    
    # Step 3: Check PO
    $step3Start = Get-Date
    if ($controlNo -ne "" -and $controlNo -ne "ControlNo") {
        $poNo = sqlcmd -S $server -d $database -U $user -P $password -C -Q "SELECT PONo FROM STB_SetInfo WHERE ControlNo = '$controlNo'" -h -1 -W
        $poNo = $poNo.Trim()
        
        if ($poNo -ne "" -and $poNo -ne "PONo") {
            $sql3 = "SELECT COUNT(*) as Count FROM STB_ProductionOrderInfo WHERE PONo = '$poNo'"
            $result3 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql3 -h -1 -W
        }
    }
    $step3End = Get-Date
    $step3Duration = ($step3End - $step3Start).TotalSeconds
    
    Write-Host "Step 3 (Check PO): $step3Duration seconds" -ForegroundColor Green
    
    # Step 4: Check Defect
    $step4Start = Get-Date
    if ($controlNo -ne "" -and $controlNo -ne "ControlNo") {
        $sql4 = "SELECT COUNT(*) as Count FROM STB_DefectRepairInfo WHERE ControlNo = '$controlNo'"
        $result4 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql4 -h -1 -W
    }
    $step4End = Get-Date
    $step4Duration = ($step4End - $step4Start).TotalSeconds
    
    Write-Host "Step 4 (Check Defect): $step4Duration seconds" -ForegroundColor Green
    
    # Step 5: Check Procedure Log
    $step5Start = Get-Date
    $sql5 = "SELECT TOP 10 COUNT(*) as Count FROM STB_ProcedureLog WHERE VariableValue LIKE '%$Barcode%' AND CreateDateTime >= DATEADD(HOUR, -24, GETDATE())"
    $result5 = sqlcmd -S $server -d $database -U $user -P $password -C -Q $sql5 -h -1 -W
    $step5End = Get-Date
    $step5Duration = ($step5End - $step5Start).TotalSeconds
    
    Write-Host "Step 5 (Check Procedure Log): $step5Duration seconds" -ForegroundColor Green
    
    # Total duration
    $endTime = Get-Date
    $totalDuration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "`n=== PERFORMANCE SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Duration: $totalDuration seconds" -ForegroundColor Yellow
    Write-Host "Average per Step: $($totalDuration / 5) seconds" -ForegroundColor Yellow
    
    # Performance rating
    if ($totalDuration -lt 5) {
        Write-Host "Performance Rating: ⚡ EXCELLENT (< 5s)" -ForegroundColor Green
    } elseif ($totalDuration -lt 10) {
        Write-Host "Performance Rating: ✅ GOOD (< 10s)" -ForegroundColor Yellow
    } else {
        Write-Host "Performance Rating: ⚠️ NEEDS OPTIMIZATION (> 10s)" -ForegroundColor Red
    }
    
    # Optimization suggestions
    Write-Host "`n=== OPTIMIZATION SUGGESTIONS ===" -ForegroundColor Cyan
    if ($step1Duration -gt 2) {
        Write-Host "- Step 1 slow: Consider adding index on Barcode column" -ForegroundColor Yellow
    }
    if ($step2Duration -gt 2) {
        Write-Host "- Step 2 slow: Consider adding index on ControlNo column" -ForegroundColor Yellow
    }
    if ($step5Duration -gt 3) {
        Write-Host "- Step 5 slow: Consider limiting ProcedureLog query time range" -ForegroundColor Yellow
    }
    
} elseif ($Script -eq "auto_check_common_issues.ps1") {
    Write-Host "`nRunning auto_check_common_issues.ps1..." -ForegroundColor Yellow
    
    # Similar performance tracking for other scripts
    $endTime = Get-Date
    $totalDuration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "Total Duration: $totalDuration seconds" -ForegroundColor Yellow
} else {
    Write-Host "Please specify script to track performance" -ForegroundColor Red
    Write-Host "Usage: .\PERFORMANCE_METRICS.ps1 -Script 'auto_debug_barcode.ps1' -Barcode 'VE260506-001'" -ForegroundColor Yellow
}

Write-Host "`n=== METRICS COMPLETE ===" -ForegroundColor Cyan
