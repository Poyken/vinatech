
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"
$Docs = @("260512000199", "260512000200", "260512000211", "260512000215", "260512000344", "260512000347")

$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

$inClause = "'" + ($Docs -join "','") + "'"
$query = "SELECT MaterialDocNo, DocStatus FROM STB_MaterialDocInfo WHERE MaterialDocNo IN ($inClause)"

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null

$dataset.Tables[0] | Format-Table -AutoSize

$SqlConnection.Close()
