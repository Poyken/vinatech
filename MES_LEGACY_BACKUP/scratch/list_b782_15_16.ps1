$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

foreach ($d in @('2026-08-15', '2026-08-16')) {
    $sql = "EXEC dbo.usp_LotTrackingInfo_VVT2_get @pProcessUserID='admin', @pProcessLanguage='vi', @pCompanyCode='VVT', @pFromDate='$d', @pToDate='$d', @pWorkCenterCode='VVT_F5', @pRouteCode=''"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $cmd.CommandTimeout = 60
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    
    $agingRows = $dt.Select("RouteCode LIKE 'V-26%'")
    Write-Output "`n=== B782 AGING LOTS FOR $d (Count: $($agingRows.Count)) ==="
    foreach ($r in $agingRows) {
        Write-Output ("Barcode: {0,-16} | Route: {1,-8} | Qty: {2,8:F1} | JobDate: {3}" -f $r["Barcode"], $r["RouteCode"], [double]$r["ProdQty"], $r["JobDate"])
    }
}
$conn.Close()
