param()

$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$conn = Get-DbConnection -Profile "SmartFactoryV2"
$lots = @('VVQR173R825701', 'VVQR173R825702', 'VVQR173R825703', 'VVQR173R825704', 'VVQR173R825705', 'VVQR173R825706')

Write-Host "=== KIEM TRA NGAY 17/09/2026 (MUC TIEU: HIEN THI DU 6 LOT) ===" -ForegroundColor Cyan
foreach ($lot in $lots) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXEC usp_LotTrackingInfo_VVT2_get @pProcessUserID='it_check', @pProcessLanguage='en', @pCompanyCode='VVT', @pFromDate='2026-09-17', @pToDate='2026-09-17', @pRouteCode='*', @pLineCode='*', @pLotNo='$lot', @pMaterialCode='*', @pMarkingLetter='*', @pWorkCenterCode='VVT_F5'"
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    if ($dt.Rows.Count -gt 0) {
        $row = $dt.Rows[0]
        Write-Host "[OK 17/9] $($row['Barcode']) | Route: $($row['RouteCode']) ($($row['RouteName'])) | Qty: $($row['ProdQty']) | ProdDateTime: $($row['ProdDateTime']) | JobDate: $($row['JobDate'])" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $lot KHONG tim thay o ngay 17/9!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== KIEM TRA NGAY 18/09/2026 (MUC TIEU: AN SACH 0 LOT) ===" -ForegroundColor Cyan
foreach ($lot in $lots) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXEC usp_LotTrackingInfo_VVT2_get @pProcessUserID='it_check', @pProcessLanguage='en', @pCompanyCode='VVT', @pFromDate='2026-09-18', @pToDate='2026-09-18', @pRouteCode='*', @pLineCode='*', @pLotNo='$lot', @pMaterialCode='*', @pMarkingLetter='*', @pWorkCenterCode='VVT_F5'"
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    if ($dt.Rows.Count -gt 0) {
        Write-Host "[STILL ON 18/9] $lot van con o ngay 18/9!" -ForegroundColor Red
    } else {
        Write-Host "[CLEAN 18/9] $lot da an sach khoi ngay 18/9" -ForegroundColor Gray
    }
}

$conn.Close()
