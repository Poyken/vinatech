$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

$spList = @(
    'usp_DoProcessProdRouteHist',
    'usp_DoProcessProdGIMaterialByBOM',
    'usp_DoProcessProdGRMaterialByOne',
    'usp_RawMaterialInputHist_iud',
    'usp_MaterialQcInfo_iud',
    'usp_InsertDataAgingAndSorting',
    'usp_Vietnam_DoProcessProdPacking_VVT'
)

$exportPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\schema_export\StrategicAudit"
if (!(Test-Path $exportPath)) { New-Item -ItemType Directory -Path $exportPath }

foreach ($spName in $spList) {
    $sql = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('$spName')"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $def = $cmd.ExecuteScalar()
    if ($def) {
        $def | Out-File "$exportPath\$spName.sql" -Encoding UTF8
        Write-Host "Exported $spName" -ForegroundColor Green
    } else {
        Write-Host "NOT FOUND: $spName" -ForegroundColor Red
    }
}

$conn.Close()
