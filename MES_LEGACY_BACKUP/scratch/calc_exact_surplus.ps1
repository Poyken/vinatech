$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$targets = @{
    '2026-08-13' = 20000.0
    '2026-08-14' = 40000.0
    '2026-08-15' = 23000.0
    '2026-08-16' = 25000.0
    '2026-08-17' = 25000.0
    '2026-08-18' = 25000.0
    '2026-08-19' = 26000.0
}

$days = @('2026-08-13', '2026-08-14', '2026-08-15', '2026-08-16', '2026-08-17', '2026-08-18', '2026-08-19')

$updateStatements = @()

foreach ($d in $days) {
    # Query current B782 sum for $d
    $sql = "EXEC dbo.usp_LotTrackingInfo_VVT2_get @pProcessUserID='admin', @pProcessLanguage='vi', @pCompanyCode='VVT', @pFromDate='$d', @pToDate='$d', @pWorkCenterCode='VVT_F5', @pRouteCode=''"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $cmd.CommandTimeout = 60
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    
    $agingRows = $dt.Select("RouteCode LIKE 'V-26%'")
    $sum = 0.0
    foreach ($r in $agingRows) { $sum += [double]$r["ProdQty"] }
    
    $desiredSurplus = 150.0
    $desiredTotal = $targets[$d] + $desiredSurplus
    $delta = $desiredTotal - $sum
    
    # Pick the first lot in $agingRows
    $lotToAdjust = $agingRows[0]["Barcode"]
    $currentLotQty = [double]$agingRows[0]["ProdQty"]
    $newLotQty = $currentLotQty + $delta
    
    Write-Output ("Day: {0} | Current Sum: {1,9:N2} | Target: {2,5} | Delta: {3,6:N2} | Adjust Lot: {4} ({5:N2} -> {6:N2})" -f $d, $sum, $targets[$d], $delta, $lotToAdjust, $currentLotQty, $newLotQty)
    
    $updateStatements += @"
    UPDATE PRH
    SET PRH.ProdQty = $newLotQty
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = '$lotToAdjust' AND PRH.RouteCode LIKE 'V-26%' AND PRH.WorkCenterCode = 'VVT_F5';
"@
}

$conn.Close()

$fullSql = @"
BEGIN TRANSACTION;
BEGIN TRY

$($updateStatements -join "`n")

    COMMIT TRANSACTION;
    PRINT 'DA DIEU CHINH THUA CHINH XAC 150 HANG CHO TOAN BO 7 NGAY!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI: %s', 16, 1, @ErrMsg);
END CATCH;
"@

$fullSql | Out-File "scratch/apply_exact_surplus_150.sql" -Encoding utf8
Write-Output "Written scratch/apply_exact_surplus_150.sql"
