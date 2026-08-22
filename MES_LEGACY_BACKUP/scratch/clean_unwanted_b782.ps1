$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Unwanted lots appearing in Day 15 Aging for VVT_F5
$unwanted_d15 = @('VVQP243R072701', 'VVQP263R072702', 'VVQO183R072710', 'VVQO183R072747', 'VVQO193R072716', 'VVQO153R072713', 'VVQO183R072761', 'VVQO193R072711', 'VVQO153R072710', 'VVQO193R072710', 'VVQO193R072715', 'VVQO173R072719', 'VVQO193R072714', 'VVQO173R072716', 'VVQO183R072718', 'VVQO113R072735')

# Unwanted lots appearing in Day 16 Aging for VVT_F5
$unwanted_d16 = @('VVQP163R072702', 'VVQP183R072707', 'VVQP183R072708', 'VVQP263R072708', 'VVQP273R072705', 'VVQO153R072722', 'VVQO153R072724', 'VVQO173R072722', 'VVQO193R072727', 'VVQO203R072743', 'VVQQ103R072717')

$unwantedSql15 = ($unwanted_d15 | ForEach-Object { "'$_'" }) -join ", "
$unwantedSql16 = ($unwanted_d16 | ForEach-Object { "'$_'" }) -join ", "

$sql = @"
UPDATE PRH
SET PRH.WorkCenterCode = 'VVT_F1',
    PRH.CompleteRoute = NULL
FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE SI.Barcode IN ($unwantedSql15, $unwantedSql16)
  AND PRH.RouteCode LIKE 'V-26%';
"@

$cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
$rows = $cmd.ExecuteNonQuery()
Write-Output "Updated $rows unwanted route hist records back to VVT_F1."

$conn.Close()
