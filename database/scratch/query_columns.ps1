$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"
$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

# Query: Find if 'Note1' exists in other Sorting related layouts
$query = @"
SELECT 
    Name,
    DATALENGTH(XmlLayout) AS XmlLength,
    CHARINDEX('Note1', XmlLayout) AS Note1Position
FROM SmartFramework.dbo.STB_ScreenLayoutInfo WITH (NOLOCK)
WHERE Name IN ('GetDataSortingProgram', 'SortingDataError', 'SortingDataError2', 'SortingErrorData', 'SortingErrorDataExcel', 'SortingErrorDataFinal', 'VVT_SortingDataError', 'ZSRT01_SortingData')
"@

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null
$dataset.Tables[0] | Format-Table -AutoSize

$SqlConnection.Close()
