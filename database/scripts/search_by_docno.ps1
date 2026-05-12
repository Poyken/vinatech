
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"

$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

$query = @"
SELECT TOP 10 * FROM STB_RawMaterialInputHist 
WHERE Remark LIKE '%260512%' 
   OR Source LIKE '%260512%'
   OR RawMaterialBarcode LIKE '%260512%'
"@
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null

$dataset.Tables[0] | Format-Table -AutoSize

$SqlConnection.Close()
