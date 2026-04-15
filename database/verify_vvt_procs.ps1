Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$procs = @(
    'usp_VVT_ProductionResult_get', 
    'usp_Vietnam_DoProcessProdPacking_VVT', 
    'usp_ProductionOrderInfo_get', 
    'usp_VVT_GetMaterialDoc_DetailHistory',
    'usp_vvt_MaterialLotInfo_get',
    'usp_RawMaterialInputHist_iud',
    'usp_VVT_GetMaterialDoc_SummaryHistory',
    'usp_Vietnam_GetProdPackingForBarcode_VVT',
    'usp_Vietnam_GetBoxIDForLotNo_VVT'
)

foreach ($proc in $procs) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT name FROM sys.procedures WHERE name = '$proc'"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        Write-Host "Found: $res"
    } else {
        Write-Host "NOT FOUND: $proc"
    }
}

$conn.Close()
