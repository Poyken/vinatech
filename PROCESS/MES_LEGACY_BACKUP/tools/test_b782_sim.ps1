$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$conn = Get-DbConnection -Profile "SmartFactoryV2"
$tx = $conn.BeginTransaction()

$allBarcodes = @(
    'VVQR113R060641', 'VVQR103R060625', 'VVQR113R060639', 'VVQR103R060615', 'VVQR073R060647',
    'VVQR073R060620', 'VVQR023R060671', 'VVQR023R060616', 'VVQR113R060628', 'VVQR023R060615',
    'VVQR023R060678', 'VVQR023R060603', 'VVQQ313R060616', 'VVQR073R060605', 'VVQR073R060607',
    'VVQR043R060604', 'VVQR023R060606', 'VVQR153R825705', 'VVQR153R825708', 'VVQR153R825713'
)

$ctrlList = @(
    '20260911000619', '20260910000370', '20260911000617', '20260910000055', '20260907000380',
    '20260907000154', '20260902000417', '20260902000178', '20260911000606', '20260902000177',
    '20260902000424', '20260902000165', '20260831000089', '20260907000139', '20260907000141',
    '20260904000095', '20260902000168', '20260915000222', '20260915000225', '20260915000619'
)

$ctrlStr = "'" + ($ctrlList -join "','") + "'"

# Thử nghiệm cập nhật ProdDateTime qua mốc 10h00 sáng ngày 18/09
$updCmd = $conn.CreateCommand()
$updCmd.Transaction = $tx
$updCmd.CommandText = "
    UPDATE STB_ProdRouteHist 
    SET ProdDateTime = DATEADD(HOUR, 10, ProdDateTime)
    WHERE ControlNo IN ($ctrlStr) AND RouteCode = 'V-24_HY';
"
$rowsAff = $updCmd.ExecuteNonQuery()
Write-Host "Updated $rowsAff rows in transaction." -ForegroundColor Cyan

# Kiểm tra thử trên B782 ngày 18/09
Write-Host "`n--- KIEM TRA TREN B782 NGAY 18/09/2026 ---" -ForegroundColor Yellow
$foundCount = 0
foreach ($lot in $allBarcodes) {
    $cmd = $conn.CreateCommand()
    $cmd.Transaction = $tx
    $cmd.CommandText = "EXEC usp_LotTrackingInfo_VVT2_get @pProcessUserID='it_check', @pProcessLanguage='en', @pCompanyCode='VVT', @pFromDate='2026-09-18', @pToDate='2026-09-18', @pRouteCode='*', @pLineCode='*', @pLotNo='$lot', @pMaterialCode='*', @pMarkingLetter='*', @pWorkCenterCode='VVT_F5'"
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    
    $v24Rows = $dt.Select("RouteCode = 'V-24_HY'")
    if ($v24Rows.Length -gt 0) {
        $foundCount++
        Write-Host " [OK] $lot -> V-24_HY | ProdDateTime: $($v24Rows[0]['ProdDateTime']) | JobDate: $($v24Rows[0]['JobDate'])" -ForegroundColor Green
    } else {
        Write-Host " [MISSING] $lot -> KHONG co V-24_HY tren B782 ngay 18! (Total rows: $($dt.Rows.Count))" -ForegroundColor Red
    }
}

Write-Host "`nTotal found on B782 date 18: $foundCount / $($allBarcodes.Length)" -ForegroundColor Cyan

# Luôn ROLLBACK lại vì đây chỉ là script mô phỏng kiểm tra
$tx.Rollback()
Write-Host "Transaction rolled back safely." -ForegroundColor Gray
$conn.Close()
