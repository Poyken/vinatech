# Script Auto-Verify Dữ Liệu Lỗi Theo Screen ID & Key (Token-Optimized)
param(
    [Parameter(Mandatory=$true)]
    [string]$ScreenID,
    
    [Parameter(Mandatory=$true)]
    [string]$Key
)

$toolsDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\AI_AGENT_CONFIG\powershell_tools"
$runQueryScript = "$toolsDir\run_query.ps1"

# Lookup query map by Screen ID
$queryMap = @{
    "B597" = "SELECT TOP 5 Barcode, MaterialCode, RawMaterialBarcode, CreateDateTime FROM STB_RawMaterialInputHist WITH(NOLOCK) WHERE Barcode = '$Key' OR RawMaterialBarcode LIKE '%$Key%' ORDER BY CreateDateTime DESC;"
    "B523" = "SELECT TOP 5 Barcode, MaterialCode, PackingQty, BoxNo, CreateDateTime FROM STB_DividePackaging WITH(NOLOCK) WHERE Barcode = '$Key' OR LotNo = '$Key' ORDER BY CreateDateTime DESC;"
    "F330" = "SELECT TOP 5 MaterialDocNo, MaterialCode, InQty, QcResult, VendorCode FROM STB_MaterialDocInfo WITH(NOLOCK) WHERE MaterialDocNo = '$Key';"
    "C220" = "SELECT TOP 5 MaterialQcNo, MaterialCode, QcQty, RequestSampleQty, DecisionResult FROM STB_MaterialQcInfo WITH(NOLOCK) WHERE MaterialQcNo = '$Key' OR MaterialCode = '$Key';"
    "C443" = "SELECT TOP 5 Item.CommInspDocNo, Hist.ProdNo, Item.RouteCode, Item.ItemQty, Item.ItemTargetQty FROM STB_CommInspDocItem Item WITH(NOLOCK) JOIN STB_CommInspDocHistory Hist WITH(NOLOCK) ON Item.CommInspDocNo = Hist.CommInspDocNo WHERE Hist.ProdNo = '$Key' OR Item.CommInspDocNo = '$Key';"
    "C546" = "SELECT TOP 5 MaterialQcNo, MaterialQcDetailNo, QcInspectionItemCode, SampleQty, DecisionResult FROM STB_MaterialQcDetail WITH(NOLOCK) WHERE MaterialQcNo = '$Key';"
    "C530" = "SELECT TOP 5 MaterialQcNo, MaterialCode, QcQty, DecisionResult FROM STB_MaterialQcInfo WITH(NOLOCK) WHERE MaterialQcNo = '$Key';"
    "HNC321" = "SELECT TOP 5 ControlNo, ProcSeq, RouteCode, LineCode, OutQty, JobDate FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = (SELECT TOP 1 ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$Key') ORDER BY ProcSeq DESC;"
}

$cleanScreen = $ScreenID.Trim().ToUpper()

if (-not $queryMap.ContainsKey($cleanScreen)) {
    Write-Host "ScreenID '$ScreenID' not in predefined map. Running generic lookup on STB_SetInfo..."
    $sql = "SELECT TOP 5 ControlNo, Barcode, MaterialCode, PONo, CreateDateTime FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$Key' OR ControlNo = '$Key';"
} else {
    $sql = $queryMap[$cleanScreen]
}

Write-Host "Executing targeted verification query for Screen [$cleanScreen] with Key [$Key]..."
& "$runQueryScript" -Query $sql
