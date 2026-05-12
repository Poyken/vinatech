
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

Write-Host "Checking STB_MaterialDocDetail..."
foreach ($doc in $Docs) {
    $dt = Execute-Query "SELECT COUNT(*) FROM STB_MaterialDocDetail WHERE MaterialDocNo = '$doc'"
    Write-Host "Doc: $doc | Count: $($dt.Rows[0][0])"
}

Write-Host "`nChecking STB_MaterialDocLotInfo..."
foreach ($doc in $Docs) {
    $dt = Execute-Query "SELECT COUNT(*) FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '$doc'"
    Write-Host "Doc: $doc | Count: $($dt.Rows[0][0])"
}

$SqlConnection.Close()
