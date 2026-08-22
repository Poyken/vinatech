$query = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_LotTrackingInfo_VVT2_get'))"
$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand($query, $conn)
$text = $cmd.ExecuteScalar()
$conn.Close()
$text | Out-File "scratch/sp_b782.sql" -Encoding utf8
Write-Output "Saved SP to scratch/sp_b782.sql (length: $($text.Length))"
