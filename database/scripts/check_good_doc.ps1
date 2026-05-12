
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"

$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

$query = @"
SELECT TOP 10 * FROM STB_RawMaterialInputHist 
WHERE MaterialLotNo IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '260512000211')
   OR Barcode IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '260512000211')
"@
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null

$dataset.Tables[0] | Format-Table -AutoSize

$SqlConnection.Close()
