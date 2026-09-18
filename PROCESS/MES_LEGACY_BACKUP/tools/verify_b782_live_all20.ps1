$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$conn = Get-DbConnection -Profile "SmartFactoryV2"
$allBarcodes = @(
    'VVQR113R060641', 'VVQR103R060625', 'VVQR113R060639', 'VVQR103R060615', 'VVQR073R060647',
    'VVQR073R060620', 'VVQR023R060671', 'VVQR023R060616', 'VVQR113R060628', 'VVQR023R060615',
    'VVQR023R060678', 'VVQR023R060603', 'VVQQ313R060616', 'VVQR073R060605', 'VVQR073R060607',
    'VVQR043R060604', 'VVQR023R060606', 'VVQR153R825705', 'VVQR153R825708', 'VVQR153R825713'
)

Write-Host "=================== NGHIEM THU B782 TRUC TIEP TREN LIVE DB ===================" -ForegroundColor Cyan

Write-Host "`n--- KIEM TRA B782 NGAY 18/09/2026 (MUC TIEU: DU 20/20 LOT TAI V-24_HY) ---" -ForegroundColor Yellow
$cnt18 = 0
foreach ($lot in $allBarcodes) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXEC usp_LotTrackingInfo_VVT2_get @pProcessUserID='it_check', @pProcessLanguage='en', @pCompanyCode='VVT', @pFromDate='2026-09-18', @pToDate='2026-09-18', @pRouteCode='*', @pLineCode='*', @pLotNo='$lot', @pMaterialCode='*', @pMarkingLetter='*', @pWorkCenterCode='VVT_F5'"
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    
    $v24 = $dt.Select("RouteCode = 'V-24_HY'")
    if ($v24.Length -gt 0) {
        $cnt18++
        Write-Host " [OK] $lot -> V-24_HY | ProdDateTime: $($v24[0]['ProdDateTime']) | JobDate: $($v24[0]['JobDate'])" -ForegroundColor Green
    } else {
        Write-Host " [MISSING] $lot KHONG thay o ngay 18!" -ForegroundColor Red
    }
}
Write-Host "Ket qua ngay 18: $cnt18 / $($allBarcodes.Length) lot hien thi day du tren B782" -ForegroundColor Cyan

Write-Host "`n--- KIEM TRA B782 NGAY 17/09/2026 (MUC TIEU: AN SACH V-24_HY) ---" -ForegroundColor Yellow
$cnt17 = 0
foreach ($lot in $allBarcodes) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXEC usp_LotTrackingInfo_VVT2_get @pProcessUserID='it_check', @pProcessLanguage='en', @pCompanyCode='VVT', @pFromDate='2026-09-17', @pToDate='2026-09-17', @pRouteCode='*', @pLineCode='*', @pLotNo='$lot', @pMaterialCode='*', @pMarkingLetter='*', @pWorkCenterCode='VVT_F5'"
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    
    $v24 = $dt.Select("RouteCode = 'V-24_HY'")
    if ($v24.Length -gt 0) {
        $cnt17++
        Write-Host " [CON TREN 17] $lot van con tren ngay 17!" -ForegroundColor Red
    }
}
Write-Host "Ket qua ngay 17: Con $cnt17 lot o cong doan V-24_HY (0 la da an sach)" -ForegroundColor Cyan

$conn.Close()
