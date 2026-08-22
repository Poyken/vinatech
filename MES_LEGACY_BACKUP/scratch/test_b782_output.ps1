$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$days = @('2026-08-13', '2026-08-14', '2026-08-15', '2026-08-16', '2026-08-17', '2026-08-18', '2026-08-19')

Write-Output "=== B782 OUTPUT SIMULATION FOR AGING (VVT_F5, 13-19/08) ==="

foreach ($day in $days) {
    $sql = @"
    EXEC dbo.usp_LotTrackingInfo_VVT2_get 
        @pProcessUserID='admin', 
        @pProcessLanguage='vi', 
        @pCompanyCode='VVT', 
        @pFromDate='$day', 
        @pToDate='$day', 
        @pWorkCenterCode='VVT_F5', 
        @pRouteCode=''
"@
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $cmd.CommandTimeout = 60
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    
    # Filter for Aging routes (V-26%)
    $agingRows = $dt.Select("RouteCode LIKE 'V-26%'")
    $totalQty = 0.0
    foreach ($r in $agingRows) {
        $totalQty += [double]$r["ProdQty"]
    }
    
    $barcodes = ($agingRows | ForEach-Object { $_["Barcode"] }) -join ", "
    Write-Output ("Day: {0} | Lots: {1,2} | Total Qty: {2,9:N2}" -f $day, $agingRows.Count, $totalQty)
}
$conn.Close()
