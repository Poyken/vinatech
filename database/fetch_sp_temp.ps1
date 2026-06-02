$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User Id=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))"
$result = $cmd.ExecuteScalar()
$conn.Close()
$result | Out-File -FilePath 'usp_Vietnam_RawMaterialInputHist_uid.sql' -Encoding UTF8
Write-Host "SP fetched successfully. Length: $($result.Length) characters"
