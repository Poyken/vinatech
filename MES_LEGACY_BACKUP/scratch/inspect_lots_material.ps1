$data = Import-Csv "scratch/db_aging_lots.csv"

# Let's inspect all lots between 13 and 19 by Barcode prefix and model
$queryLots = @"
SELECT 
    SI.Barcode,
    SI.MaterialCode,
    MM.MaterialName,
    PRH.RouteCode,
    PRH.WorkCenterCode,
    CONVERT(VARCHAR(10), PRH.JobDate, 120) AS JobDate,
    PRH.ProdQty,
    PRH.CompleteRoute,
    CONVERT(VARCHAR(19), PRH.ProdDateTime, 120) AS ProdDateTime
FROM dbo.STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
LEFT JOIN dbo.STB_MaterialMaster MM WITH (NOLOCK) ON SI.MaterialCode = MM.MaterialCode
WHERE PRH.RouteCode LIKE 'V-26%'
  AND CAST(PRH.JobDate AS DATE) BETWEEN '2026-08-13' AND '2026-08-19'
ORDER BY PRH.JobDate, PRH.WorkCenterCode, SI.Barcode
"@

$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$cmd = New-Object System.Data.SqlClient.SqlCommand($queryLots, $conn)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$conn.Close()

$dt | Export-Csv -Path "scratch/aging_lots_with_material.csv" -NoTypeInformation -Encoding utf8
Write-Output "Exported $($dt.Rows.Count) rows"

# Summary by Barcode prefix and MaterialName per date
$dt | ForEach-Object {
    [PSCustomObject]@{
        Barcode = $_.Barcode
        Prefix = $_.Barcode.Substring(0,4)
        MaterialCode = $_.MaterialCode
        MaterialName = $_.MaterialName
        WorkCenterCode = $_.WorkCenterCode
        RouteCode = $_.RouteCode
        JobDate = $_.JobDate
        ProdQty = [double]$_.ProdQty
    }
} | Group-Object JobDate, WorkCenterCode, Prefix | ForEach-Object {
    $parts = $_.Name -split ', '
    $cnt = $_.Count
    $sum = ($_.Group | Measure-Object -Property ProdQty -Sum).Sum
    Write-Output ("Date: {0,-10} | WC: {1,-6} | Prefix: {2,-4} | Lots: {3,2} | Sum: {4,8:F1}" -f $parts[0], $parts[1], $parts[2], $cnt, $sum)
}
