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

# Create procedures folder if it doesn't exist
$procDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures"
if (!(Test-Path $procDir)) {
    New-Item -ItemType Directory -Force -Path $procDir | Out-Null
}

Export-SP "usp_FinishGoodAllFactoryReport" "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_FinishGoodAllFactoryReport_ORIGINAL.sql"
Export-SP "usp_InventoryOfGoodsReport_get" "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_InventoryOfGoodsReport_get_ORIGINAL.sql"
Export-SP "usp_InventoryOfGoodsReport_iud" "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_InventoryOfGoodsReport_iud_ORIGINAL.sql"

$conn.Close()
