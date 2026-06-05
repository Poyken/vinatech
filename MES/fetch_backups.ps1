$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$cs = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$conn = New-Object System.Data.SqlClient.SqlConnection($cs)
$conn.Open()

function Export-SP($spName, $outputPath) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('$spName');"
    $defn = $cmd.ExecuteScalar()
    if ($defn) {
        [System.IO.File]::WriteAllText($outputPath, $defn, [System.Text.Encoding]::UTF8)
        Write-Host "Backup exported: $spName to $outputPath" -ForegroundColor Green
    } else {
        Write-Host "Failed to find $spName in database." -ForegroundColor Red
    }
}

Export-SP "usp_Get_VVT_Prod_Bad_Status" "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_Get_VVT_Prod_Bad_Status_ORIGINAL.sql"
Export-SP "usp_Get_VVT_Prod_Bad_Stat_tail" "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_Get_VVT_Prod_Bad_Stat_tail_ORIGINAL.sql"

$conn.Close()
