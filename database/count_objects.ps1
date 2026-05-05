$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

function Get-Count($sql) {
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    return $cmd.ExecuteScalar()
}

$tables = Get-Count "SELECT COUNT(*) FROM sys.objects WHERE type = 'U'"
$sps = Get-Count "SELECT COUNT(*) FROM sys.objects WHERE type = 'P'"
$funcs = Get-Count "SELECT COUNT(*) FROM sys.objects WHERE type IN ('FN', 'IF', 'TF')"
$views = Get-Count "SELECT COUNT(*) FROM sys.objects WHERE type = 'V'"
$triggers = Get-Count "SELECT COUNT(*) FROM sys.objects WHERE type = 'TR'"

Write-Host "Database Statistics for SmartFactoryV2:"
Write-Host "Tables: $tables"
Write-Host "SPs: $sps"
Write-Host "Functions: $funcs"
Write-Host "Views: $views"
Write-Host "Triggers: $triggers"

$conn.Close()
