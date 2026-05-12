
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"
$Docs = @("260512000199", "260512000200", "260512000211", "260512000215", "260512000344", "260512000347")

$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

$inClause = "'" + ($Docs -join "','") + "'"

$query = @"
SELECT 
    I.MaterialDocNo, 
    I.DocStatus,
    D.MaterialCode, 
    D.RequestQty, 
    D.AllowQty, 
    L.TotalStockQty, 
    L.LotCount
FROM STB_MaterialDocInfo I
LEFT JOIN STB_MaterialDocDetail D ON I.MaterialDocNo = D.MaterialDocNo
LEFT JOIN (
    SELECT MaterialDocNo, SUM(StockQty) as TotalStockQty, COUNT(*) as LotCount 
    FROM STB_MaterialDocLotInfo 
    GROUP BY MaterialDocNo
) L ON I.MaterialDocNo = L.MaterialDocNo
WHERE I.MaterialDocNo IN ($inClause)
"@

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null

$table = $dataset.Tables[0]

$results = foreach ($row in $table.Rows) {
    $status = "OK"
    if ($row.MaterialCode -eq [DBNull]::Value) { $status = "MISSING DETAIL" }
    elseif ($row.TotalStockQty -eq [DBNull]::Value) { $status = "MISSING LOTS" }
    elseif ($row.RequestQty -ne $row.TotalStockQty) { $status = "QTY MISMATCH (REQ vs LOT)" }
    elseif ($row.AllowQty -ne $row.TotalStockQty) { $status = "QTY MISMATCH (ALLOW vs LOT)" }

    [PSCustomObject]@{
        DocNo      = $row.MaterialDocNo
        Status     = $row.DocStatus
        MatCode    = $row.MaterialCode
        ReqQty     = $row.RequestQty
        AllowQty   = $row.AllowQty
        StockQty   = $row.TotalStockQty
        LotCount   = $row.LotCount
        CheckState = $status
    }
}

$results | Format-Table -AutoSize

$SqlConnection.Close()
