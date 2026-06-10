param (
    [string]$SPName
)

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$cs = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$procDir = Join-Path $PSScriptRoot "sql\procedures"
if (!(Test-Path $procDir)) {
    New-Item -ItemType Directory -Force -Path $procDir | Out-Null
}

$conn = New-Object System.Data.SqlClient.SqlConnection($cs)
$conn.Open()

function Export-SP([string]$name) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('$name');"
    $defn = $cmd.ExecuteScalar()
    if ($defn) {
        $outputPath = Join-Path $procDir "$name.sql"
        [System.IO.File]::WriteAllText($outputPath, $defn, [System.Text.Encoding]::UTF8)
        Write-Host "Sync successful: Exported $name to $outputPath" -ForegroundColor Green
    } else {
        Write-Host "Failed to find Stored Procedure '$name' in database." -ForegroundColor Red
    }
}

if ($SPName) {
    Export-SP $SPName
} else {
    Write-Host "No SPName specified. Syncing default project SPs..." -ForegroundColor Cyan
    $defaultSPs = @(
        "usp_DoCreateHelaInBoxBarcodeList",
        "usp_FinishGoodAllFactoryReport",
        "usp_Get_VVT_Prod_Bad_Status",
        "usp_Get_VVT_Prod_Bad_Stat_tail",
        "usp_Vietnam_MaterialFOQcDetail_get",
        "usp_InventoryOfGoodsReport_get",
        "usp_InventoryOfGoodsReport_iud",
        "usp_MaterialQcSampleResult_get",
        "usp_RawMaterialInputHist_get",
        "usp_Vietnam_GetBoxIDForLotNo_VVT",
        "usp_Vietnam_GetMaterialFOQCInfo",
        "usp_Vietnam_RawMaterialInputHist_uid",
        "usp_vvt_MaterialLotInfo_get"
    )
    foreach ($sp in $defaultSPs) {
        Export-SP $sp
    }
}

$conn.Close()
