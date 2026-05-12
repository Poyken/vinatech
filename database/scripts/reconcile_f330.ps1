
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"
$DocNo = "260512000347"

$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

function Execute-Query($query) {
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) | Out-Null
    return $dataset.Tables[0]
}

Write-Host "--- RECONCILIATION FOR DOC: $DocNo ---" -ForegroundColor Cyan

Write-Host "`n[1] STB_MaterialDocInfo:" -ForegroundColor Yellow
$info = Execute-Query "SELECT MaterialDocNo, DocStatus, CreateUserID, CreateDateTime FROM STB_MaterialDocInfo WHERE MaterialDocNo = '$DocNo'"
$info | Format-Table -AutoSize

Write-Host "`n[2] STB_MaterialDocDetail:" -ForegroundColor Yellow
$detail = Execute-Query "SELECT MaterialDocNo, MaterialCode, RequestQty, AllowQty, PickingQty FROM STB_MaterialDocDetail WHERE MaterialDocNo = '$DocNo'"
$detail | Format-Table -AutoSize

Write-Host "`n[3] STB_MaterialDocLotInfo (Summary):" -ForegroundColor Yellow
$lotSummary = Execute-Query "SELECT MaterialDocNo, MaterialCode, COUNT(*) as LotCount, SUM(StockQty) as TotalStockQty FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '$DocNo' GROUP BY MaterialDocNo, MaterialCode"
$lotSummary | Format-Table -AutoSize

Write-Host "`n[4] STB_RawMaterialInputHist (Matching via LotID -> MaterialLotNo):" -ForegroundColor Yellow
$rawQuery = @"
SELECT MaterialCode, COUNT(*) as RawCount, SUM(Qty) as TotalRawQty 
FROM STB_RawMaterialInputHist 
WHERE MaterialLotNo IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '$DocNo')
GROUP BY MaterialCode
"@
$raw = Execute-Query $rawQuery
$raw | Format-Table -AutoSize

Write-Host "`n[5] Detailed Lot Comparison (DocLot vs RawInput):" -ForegroundColor Yellow
$compareQuery = @"
SELECT 
    L.LotID, 
    L.StockQty as DocLot_Qty, 
    R.Qty as Raw_Qty,
    (CASE WHEN L.StockQty = R.Qty THEN 'OK' ELSE 'MISMATCH' END) as Status
FROM STB_MaterialDocLotInfo L
LEFT JOIN STB_RawMaterialInputHist R ON L.LotID = R.MaterialLotNo
WHERE L.MaterialDocNo = '$DocNo'
"@
$compare = Execute-Query $compareQuery
$compare | Format-Table -AutoSize

$SqlConnection.Close()
