$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = "EXEC dbo.usp_LotTrackingInfo_VVT2_get @pProcessUserID='admin', @pProcessLanguage='vi', @pCompanyCode='VVT', @pFromDate='2026-08-18', @pToDate='2026-08-18', @pWorkCenterCode='VVT_F5', @pRouteCode=''"
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
$cmd.CommandTimeout = 60
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$conn.Close()

$agingRows = $dt.Select("RouteCode LIKE 'V-26%'")
Write-Output "=== DAY 18 B782 AGING LOTS (Count: $($agingRows.Count)) ==="
foreach ($r in $agingRows) {
    Write-Output ("Barcode: {0,-16} | Qty: {1,8:F1} | Route: {2,-8} | JobDate: {3}" -f $r["Barcode"], [double]$r["ProdQty"], $r["RouteCode"], $r["JobDate"])
}
