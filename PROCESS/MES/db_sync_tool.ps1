param (
    [string]$SPName,
    [switch]$Clean
)

$procDir = Join-Path $PSScriptRoot "sql\procedures"

if ($Clean) {
    if (Test-Path $procDir) {
        $files = Get-ChildItem -Path $procDir -Filter "*.sql"
        if ($files.Count -gt 0) {
            $files | Remove-Item -Force
            Write-Host "Cleaned $($files.Count) temporary stored procedure file(s) from $procDir" -ForegroundColor Green
        } else {
            Write-Host "No temporary stored procedure files to clean in $procDir." -ForegroundColor Gray
        }
    } else {
        Write-Host "Procedures directory does not exist." -ForegroundColor Gray
    }
    exit 0
}

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

if (!(Test-Path $procDir)) {
    New-Item -ItemType Directory -Force -Path $procDir | Out-Null
}

$conn = Get-DbConnection
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
    Invoke-ProactiveKbSearch -SqlText $SPName
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
