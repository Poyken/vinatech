$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$days = @('2026-08-13', '2026-08-14', '2026-08-15', '2026-08-16', '2026-08-17', '2026-08-18', '2026-08-19')
$targets = @(20000, 40000, 23000, 25000, 25000, 25000, 26000)

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "KET QUA KIEM TRA TRUC TIEP B782 (VVT_F5, AGING 13-19/08/2026):" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan

for ($i = 0; $i -lt $days.Count; $i++) {
    $d = $days[$i]
    $tgt = $targets[$i]
    $sql = "EXEC dbo.usp_LotTrackingInfo_VVT2_get @pProcessUserID='admin', @pProcessLanguage='vi', @pCompanyCode='VVT', @pFromDate='$d', @pToDate='$d', @pWorkCenterCode='VVT_F5', @pRouteCode=''"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $cmd.CommandTimeout = 60
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    
    $agingRows = $dt.Select("RouteCode LIKE 'V-26%'")
    $sum = 0.0
    foreach ($r in $agingRows) { $sum += [double]$r["ProdQty"] }
    $diff = $sum - $tgt
    
    Write-Host ("Ngay {0} | Muc tieu: {1,5:N0} | B782 Lots: {2,2} | San luong B782: {3,9:N2} | Thua (Diff): {4,6:N2} pcs" -f $d, $tgt, $agingRows.Count, $sum, $diff) -ForegroundColor Green
}
$conn.Close()
