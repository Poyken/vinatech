$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$conn = Get-DbConnection -Profile "SmartFactoryV2"
$lots = @('VVQR153R825705', 'VVQR153R825708', 'VVQR153R825713')

Write-Host "=================== KIEM TRA 3 LOT TREN B782 ===================" -ForegroundColor Cyan
foreach ($d in @('2026-09-17', '2026-09-18')) {
    Write-Host "`n--- NGAY TRA CUU: $d ---" -ForegroundColor Yellow
    foreach ($lot in $lots) {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "EXEC usp_LotTrackingInfo_VVT2_get @pProcessUserID='it_check', @pProcessLanguage='en', @pCompanyCode='VVT', @pFromDate='$d', @pToDate='$d', @pRouteCode='*', @pLineCode='*', @pLotNo='$lot', @pMaterialCode='*', @pMarkingLetter='*', @pWorkCenterCode='VVT_F5'"
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $da.Fill($dt) | Out-Null
        Write-Host "Lot $lot : $($dt.Rows.Count) dong" -ForegroundColor White
        foreach ($r in $dt.Rows) {
            Write-Host "   [Route $($r['RouteCode'])] Qty: $($r['ProdQty']) | ProdDateTime: $($r['ProdDateTime']) | JobDate: $($r['JobDate'])" -ForegroundColor Gray
        }
    }
}

$conn.Close()
