# ==============================================================================
# GoldenQueryEngine.ps1 — 360° Traceability Query Engine for MES_V2
# ==============================================================================

class MesGoldenQueryEngine {
    [object]$QueryEngine

    MesGoldenQueryEngine([object]$queryEngine) {
        $this.QueryEngine = $queryEngine
    }

    [hashtable] TraceBarcode([string]$barcode) {
        $cleanBarcode = $barcode.Trim().Replace("'", "''")
        $result = @{
            Barcode       = $cleanBarcode
            SetInfo       = $null
            MaterialLot   = $null
            RouteHistory  = $null
            SlittingStock = $null
            PackingDetail = $null
        }

        # 1. Query SetInfo
        $qSet = "SELECT TOP 10 Barcode, ControlNo, MaterialCode, PONo, DayPlanNo, InputLineCode, CurrentRouteCode, DefectQty, LotDecisionResult, CreateDateTime FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$cleanBarcode' OR ControlNo = '$cleanBarcode' OR NewBarcode = '$cleanBarcode'"
        $result.SetInfo = $this.QueryEngine.ExecuteQuery($qSet)

        # 2. Query MaterialLotInfo
        $qLot = "SELECT TOP 10 LotID, LotNo, MaterialLotNo, MaterialCode, MaterialWarehouseCode, CurrentQty, PackingID, LotAttr10, CreateDateTime FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = '$cleanBarcode' OR MaterialLotNo = '$cleanBarcode' OR PackingID = '$cleanBarcode' OR LotID = '$cleanBarcode'"
        $result.MaterialLot = $this.QueryEngine.ExecuteQuery($qLot)

        # 3. Query ProdRouteHist
        $qRoute = "SELECT TOP 30 ProdRouteHistNo, ControlNo, RouteCode, ProdQty, CompleteRoute, WorkerCode, MachineCode, JobDate, CreateDateTime FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo IN (SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$cleanBarcode') OR ControlNo = '$cleanBarcode' ORDER BY CreateDateTime ASC"
        $result.RouteHistory = $this.QueryEngine.ExecuteQuery($qRoute)

        # 4. Query SlittingStock
        $qSlit = "SELECT TOP 10 SlittingLotNo, SlittingLocationCode, MaterialCode, Length, Weight, RollQty, CreateDateTime FROM STB_SlittingStock_VVT WITH(NOLOCK) WHERE SlittingLotNo = '$cleanBarcode'"
        try {
            $result.SlittingStock = $this.QueryEngine.ExecuteQuery($qSlit)
        } catch {}

        # 5. Query DividePackaging
        $qPack = "SELECT TOP 20 PackingID, InBoxBarcode, OutBoxBarcode, Quantity, MaterialCode, CreateDateTime FROM STB_DividePackaging WITH(NOLOCK) WHERE PackingID = '$cleanBarcode' OR InBoxBarcode = '$cleanBarcode' OR OutBoxBarcode = '$cleanBarcode'"
        try {
            $result.PackingDetail = $this.QueryEngine.ExecuteQuery($qPack)
        } catch {}

        return $result
    }
}
