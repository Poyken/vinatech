
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"
$Docs = @("260512000199", "260512000200", "260512000211", "260512000215", "260512000344", "260512000347")

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

$results = @()

foreach ($doc in $Docs) {
    $detail = Execute-Query "SELECT MaterialCode, RequestQty, AllowQty FROM STB_MaterialDocDetail WHERE MaterialDocNo = '$doc'"
    $lot = Execute-Query "SELECT SUM(StockQty) as TotalStockQty, COUNT(*) as LotCount FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '$doc'"
    
    $reqQty = 0
    $allowQty = 0
    $matCode = "MISSING"
    
    if ($detail.Rows.Count -gt 0) {
        $reqQty = $detail.Rows[0].RequestQty
        $allowQty = $detail.Rows[0].AllowQty
        $matCode = $detail.Rows[0].MaterialCode
    }
    
    $stockQty = 0
    $lotCount = 0
    if ($lot.Rows.Count -gt 0 -and $lot.Rows[0].TotalStockQty -ne [DBNull]::Value) {
        $stockQty = $lot.Rows[0].TotalStockQty
        $lotCount = $lot.Rows[0].LotCount
    }

    $status = "OK"
    if ($matCode -eq "MISSING") { $status = "MISSING DETAIL" }
    elseif ($reqQty -ne $stockQty) { $status = "QTY MISMATCH (REQ vs LOT)" }
    elseif ($allowQty -ne $stockQty) { $status = "QTY MISMATCH (ALLOW vs LOT)" }

    $results += [PSCustomObject]@{
        MaterialDocNo = $doc
        MaterialCode  = $matCode
        RequestQty    = $reqQty
        AllowQty      = $allowQty
        TotalStockQty = $stockQty
        LotCount      = $lotCount
        Status        = $status
    }
}

Write-Host "--- BULK RECONCILIATION REPORT ---" -ForegroundColor Cyan
$results | Format-Table -AutoSize

$SqlConnection.Close()
