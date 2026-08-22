$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT 
    SI.Barcode,
    PRH.RouteCode,
    PRH.WorkCenterCode,
    CONVERT(VARCHAR(10), PRH.JobDate, 120) AS JobDate,
    PRH.ProdQty,
    PRH.CompleteRoute,
    CONVERT(VARCHAR(19), PRH.ProdDateTime, 120) AS ProdDateTime
FROM dbo.STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE PRH.RouteCode LIKE 'V-26%'
  AND CAST(PRH.JobDate AS DATE) BETWEEN '2026-08-11' AND '2026-08-21'
ORDER BY PRH.JobDate, PRH.WorkCenterCode, SI.Barcode
"@

$cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$conn.Close()

$dt | Export-Csv -Path "scratch/db_aging_lots.csv" -NoTypeInformation -Encoding utf8
Write-Output "Exported $($dt.Rows.Count) rows to scratch/db_aging_lots.csv"
