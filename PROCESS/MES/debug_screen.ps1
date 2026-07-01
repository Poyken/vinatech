param (
    [string]$TCode,
    [string]$ErrorMsg,
    [string]$Barcode,
    [string]$LotID,
    [string]$OutFile
)

# Initialize variables to hold diagnostic data
$dtScreen = $null
$dtObjects = $null
$dtRes = $null
$dtSps = $null
$dtSet = $null
$dtModel = $null
$dtHist = $null
$dtFed = $null
$dtPo = $null
$dtLot = $null
$dtQc = $null
$dtUsage = $null
$dtMat = $null

# Custom terminal table formatter to prevent truncation/wrapping on narrow consoles
function Out-ConsoleTable {
    param(
        [System.Data.DataTable]$DataTable,
        [string[]]$Columns,
        [int[]]$Widths,
        [string[]]$Headers
    )
    
    if (-not $DataTable -or $DataTable.Rows.Count -eq 0) { return }
    
    # Print Header
    $headerLine = ""
    $separatorLine = ""
    for ($i = 0; $i -lt $Columns.Count; $i++) {
        $headerName = if ($Headers) { $Headers[$i] } else { $Columns[$i] }
        $width = $Widths[$i]
        
        $headerLine += "{0,-$width}" -f $headerName
        $separatorLine += ("-" * ($width - 1)) + " "
    }
    Write-Host $headerLine -ForegroundColor Cyan
    Write-Host $separatorLine -ForegroundColor Gray
    
    # Print Rows
    foreach ($row in $DataTable.Rows) {
        $rowLine = ""
        for ($i = 0; $i -lt $Columns.Count; $i++) {
            $colName = $Columns[$i]
            $width = $Widths[$i]
            $val = $row.$colName
            
            # Format value
            $strVal = ""
            if ($val -is [System.DateTime]) {
                $strVal = $val.ToString("MM/dd HH:mm:ss")
            } elseif ($val -eq $null -or $val -is [System.DBNull]) {
                $strVal = ""
            } else {
                $strVal = $val.ToString()
            }
            
            # Truncate if exceeds width (minus 1 space for padding)
            $limit = $width - 1
            if ($strVal.Length -gt $limit) {
                if ($limit -gt 3) {
                    $strVal = $strVal.Substring(0, $limit - 3) + "..."
                } else {
                    $strVal = $strVal.Substring(0, $limit)
                }
            }
            
            $rowLine += "{0,-$width}" -f $strVal
        }
        Write-Host $rowLine -ForegroundColor White
    }
    Write-Host ""
}

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

if ([string]::IsNullOrEmpty($TCode) -and [string]::IsNullOrEmpty($ErrorMsg) -and [string]::IsNullOrEmpty($Barcode) -and [string]::IsNullOrEmpty($LotID)) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -TCode B523" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -ErrorMsg 'chua duoc dua vao tuyen'" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -Barcode 'K16418106262500772'" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -LotID 'WRHI00-002'" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -Barcode 'K164...' -OutFile report.html" -ForegroundColor Yellow
    exit 1
}

$conn = Get-DbConnection
$conn.Open()

# Case 1: TCode diagnostics
if ($TCode) {
    Write-Host "=== [DIAGNOSTIC] Retrieving Screen Info for TCode: $TCode ===" -ForegroundColor Cyan
    
    # 1. Screen general info
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT Name, Caption, ParentName, ShowInMenu FROM SmartFramework.dbo.STB_ScreenInfo WITH(NOLOCK) WHERE TCode = @TCode;"
    $cmd.Parameters.AddWithValue("@TCode", $TCode) | Out-Null
    
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dtScreen = New-Object System.Data.DataTable
    $adapter.Fill($dtScreen) | Out-Null
    
    if ($dtScreen.Rows.Count -eq 0) {
        Write-Host ("[WARNING] No screen registered under TCode '" + $TCode + "' in SmartFramework.dbo.STB_ScreenInfo.") -ForegroundColor Yellow
    } else {
        $row = $dtScreen.Rows[0]
        Write-Host ("Screen Name:   " + $row.Name) -ForegroundColor White
        Write-Host ("Caption:       " + $row.Caption) -ForegroundColor White
        Write-Host ("Parent Menu:   " + $row.ParentName) -ForegroundColor White
        Write-Host ("Show In Menu:  " + $row.ShowInMenu) -ForegroundColor White
        Write-Host ""
        
        $screenName = $row.Name
        
        # 2. UI objects mapping
        Write-Host "--- Registered Stored Procedures & UI Objects ---" -ForegroundColor Cyan
        $cmdObj = $conn.CreateCommand()
        $cmdObj.CommandText = "SELECT ObjectName, ObjectType, Caption FROM SmartFramework.dbo.STB_ScreenObjects WITH(NOLOCK) WHERE ScreenName = @ScreenName;"
        $cmdObj.Parameters.AddWithValue("@ScreenName", $screenName) | Out-Null
        
        $dtObjects = New-Object System.Data.DataTable
        $adapterObj = New-Object System.Data.SqlClient.SqlDataAdapter($cmdObj)
        $adapterObj.Fill($dtObjects) | Out-Null
        
        if ($dtObjects.Rows.Count -eq 0) {
            Write-Host "No UI objects/procedures mapped in STB_ScreenObjects." -ForegroundColor Gray
        } else {
            Out-ConsoleTable -DataTable $dtObjects -Columns @("ObjectName", "ObjectType", "Caption") -Widths @(40, 20, 30) -Headers @("Object Name", "Object Type", "Caption")
        }
    }
    
    # 3. Trigger KB scan for TCode
    Invoke-ProactiveKbSearch -SqlText $TCode
}

# Case 2: Error Message lookup and SP mapping
if ($ErrorMsg) {
    Write-Host ("=== [DIAGNOSTIC] Looking up localized error: '" + $ErrorMsg + "' ===") -ForegroundColor Cyan
    
    # 1. Search String Resources
    $cmdRes = $conn.CreateCommand()
    $cmdRes.CommandText = "SELECT Name, Language, Value FROM SmartFramework.dbo.STB_StringResources WITH(NOLOCK) WHERE Value LIKE @ErrorMsg;"
    $cmdRes.Parameters.AddWithValue("@ErrorMsg", "%" + $ErrorMsg + "%") | Out-Null
    
    $dtRes = New-Object System.Data.DataTable
    $adapterRes = New-Object System.Data.SqlClient.SqlDataAdapter($cmdRes)
    $adapterRes.Fill($dtRes) | Out-Null
    
    if ($dtRes.Rows.Count -eq 0) {
        Write-Host "[WARNING] No matching entries found in SmartFramework.dbo.STB_StringResources." -ForegroundColor Yellow
    } else {
        Write-Host "Found matching localized entries:" -ForegroundColor Yellow
        Out-ConsoleTable -DataTable $dtRes -Columns @("Name", "Language", "Value") -Widths @(35, 12, 45) -Headers @("Key Name", "Language", "Value")
        
        # Extract unique keys
        $keys = @()
        foreach ($row in $dtRes.Rows) {
            $keys += $row.Name
        }
        $keys = $keys | Select-Object -Unique
        
        # 2. Search sys.sql_modules for all keys in a single batched query
        Write-Host "--- Searching Database Stored Procedures raising these keys (Optimized) ---" -ForegroundColor Cyan
        
        $conditions = @()
        $cmdSp = $conn.CreateCommand()
        
        $i = 0
        foreach ($key in $keys) {
            $cleanKey = $key.Replace("^", "")
            $paramName1 = "@KeyPattern_$i"
            $paramName2 = "@CleanKeyPattern_$i"
            
            $conditions += "sm.definition LIKE $paramName1"
            $conditions += "sm.definition LIKE $paramName2"
            
            $cmdSp.Parameters.AddWithValue($paramName1, "%" + $key + "%") | Out-Null
            $cmdSp.Parameters.AddWithValue($paramName2, "%" + $cleanKey + "%") | Out-Null
            $i++
        }
        
        if ($conditions.Count -gt 0) {
            $whereClause = $conditions -join " OR "
            $cmdSp.CommandText = "
                SELECT DISTINCT OBJECT_NAME(sm.object_id) AS SPName, sm.definition
                FROM sys.sql_modules sm WITH(NOLOCK)
                WHERE $whereClause;"
            
            $dtSps = New-Object System.Data.DataTable
            $adapterSp = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSp)
            $adapterSp.Fill($dtSps) | Out-Null
            
            if ($dtSps.Rows.Count -eq 0) {
                Write-Host "No active Stored Procedures reference these keys in their code." -ForegroundColor Gray
            } else {
                Write-Host ("Found " + $dtSps.Rows.Count + " Stored Procedure(s) raising matching errors:") -ForegroundColor Green
                foreach ($spRow in $dtSps.Rows) {
                    $spName = $spRow.SPName
                    $matchedKeys = @()
                    foreach ($key in $keys) {
                        $cleanKey = $key.Replace("^", "")
                        if ($spRow.definition -match [regex]::Escape($key) -or $spRow.definition -match [regex]::Escape($cleanKey)) {
                            $matchedKeys += $key
                        }
                    }
                    Write-Host ("  - " + $spName + " (raised by: " + ($matchedKeys -join ", ") + ")") -ForegroundColor White
                }
            }
        }
    }
}

# Case 3: Barcode Tracing (STB_SetInfo & STB_ProdRouteHist)
if ($Barcode) {
    Write-Host ("=== [TRACE] Tracing Barcode: '" + $Barcode + "' ===") -ForegroundColor Cyan
    
    # 1. Query STB_SetInfo
    $cmdSet = $conn.CreateCommand()
    $cmdSet.CommandText = "
        SELECT ControlNo, PONo, MaterialCode, SetSeq, IsLineInput, IsLoss, IsDefect, CurrentRouteCode, CreateDateTime, LotDecisionResult
        FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
        WHERE Barcode = @Barcode;"
    $cmdSet.Parameters.AddWithValue("@Barcode", $Barcode) | Out-Null
    
    $dtSet = New-Object System.Data.DataTable
    $adapterSet = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSet)
    $adapterSet.Fill($dtSet) | Out-Null
    
    if ($dtSet.Rows.Count -eq 0) {
        Write-Host "No record found in STB_SetInfo for Barcode." -ForegroundColor Yellow
    } else {
        Write-Host "STB_SetInfo Record:" -ForegroundColor Yellow
        Out-ConsoleTable -DataTable $dtSet -Columns @("ControlNo", "PONo", "MaterialCode", "SetSeq", "IsLineInput", "LotDecisionResult") -Widths @(16, 14, 15, 8, 13, 12) -Headers @("Control No", "PO No", "Material Code", "Seq", "Line Input", "QC Decision")
        
        $controlNo = $dtSet.Rows[0].ControlNo
        $poNo = $dtSet.Rows[0].PONo
        $matCode = $dtSet.Rows[0].MaterialCode
        
        # 2. Query Model Configuration (STB_ModelBasicInfo)
        if ($matCode) {
            $cmdModel = $conn.CreateCommand()
            $cmdModel.CommandText = "
                SELECT ModelCode, ModelName, OqcType, InspectionType, InspectionLevel, MBIExtText01 AS [Voltage], MBIExtText02 AS [Farad], AcEsr, DcEsr, LeakageCurrent
                FROM SmartFactoryV2.dbo.STB_ModelBasicInfo WITH(NOLOCK)
                WHERE ModelCode = @ModelCode;"
            $cmdModel.Parameters.AddWithValue("@ModelCode", $matCode) | Out-Null
            
            $dtModel = New-Object System.Data.DataTable
            $adapterModel = New-Object System.Data.SqlClient.SqlDataAdapter($cmdModel)
            $adapterModel.Fill($dtModel) | Out-Null
            
            if ($dtModel.Rows.Count -gt 0) {
                Write-Host "Model Basic Configuration (STB_ModelBasicInfo):" -ForegroundColor Yellow
                Out-ConsoleTable -DataTable $dtModel -Columns @("ModelCode", "ModelName", "OqcType", "Voltage", "Farad", "AcEsr", "DcEsr", "LeakageCurrent") -Widths @(15, 12, 10, 10, 8, 8, 8, 12) -Headers @("Model Code", "Model Name", "OQC Type", "Volt", "Farad", "AC ESR", "DC ESR", "Leak Current")
            } else {
                Write-Host ("  [WARNING] Model " + $matCode + " is NOT configured in STB_ModelBasicInfo!") -ForegroundColor Red
            }
        }
        
        # 3. Query Scan History (STB_ProdRouteHist)
        Write-Host "Routing Scan History (STB_ProdRouteHist):" -ForegroundColor Yellow
        $cmdHist = $conn.CreateCommand()
        $cmdHist.CommandText = "
            SELECT CreateDateTime, RouteCode, LineCode, MachineCode, CreateUserID, ProdQty, JobDate
            FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
            WHERE ControlNo = @ControlNo
            ORDER BY CreateDateTime;"
        $cmdHist.Parameters.AddWithValue("@ControlNo", $controlNo) | Out-Null
        
        $dtHist = New-Object System.Data.DataTable
        $adapterHist = New-Object System.Data.SqlClient.SqlDataAdapter($cmdHist)
        $adapterHist.Fill($dtHist) | Out-Null
        
        if ($dtHist.Rows.Count -eq 0) {
            Write-Host ("  No routing scan history found for this ControlNo (" + $controlNo + ").") -ForegroundColor Gray
        } else {
            Out-ConsoleTable -DataTable $dtHist -Columns @("CreateDateTime", "RouteCode", "LineCode", "MachineCode", "CreateUserID") -Widths @(18, 12, 15, 18, 15) -Headers @("Scan Date/Time", "Route", "Line Code", "Machine Code", "User ID")
        }
        
        # 4. Query Raw Material Feeding History (STB_RawMaterialInputHist)
        Write-Host "Raw Material Feeding History (STB_RawMaterialInputHist):" -ForegroundColor Yellow
        $cmdFed = $conn.CreateCommand()
        $cmdFed.CommandText = "
            SELECT CreateDateTime, RouteCode, LotMaterialCode, RawMaterialBarcode, Qty, CreateUserID
            FROM SmartFactoryV2.dbo.STB_RawMaterialInputHist WITH(NOLOCK)
            WHERE Barcode = @Barcode OR MaterialLotNo = @Barcode
            ORDER BY CreateDateTime;"
        $cmdFed.Parameters.AddWithValue("@Barcode", $Barcode) | Out-Null
        
        $dtFed = New-Object System.Data.DataTable
        $adapterFed = New-Object System.Data.SqlClient.SqlDataAdapter($cmdFed)
        $adapterFed.Fill($dtFed) | Out-Null
        
        if ($dtFed.Rows.Count -eq 0) {
            Write-Host "  No raw material feeding logs found for this barcode." -ForegroundColor Gray
        } else {
            Out-ConsoleTable -DataTable $dtFed -Columns @("CreateDateTime", "RouteCode", "LotMaterialCode", "RawMaterialBarcode", "Qty", "CreateUserID") -Widths @(18, 8, 18, 22, 8, 15) -Headers @("Feed Date/Time", "Route", "Material Code", "Raw Material Lot", "Qty", "User ID")
        }
        
        # 5. Query PO Routing Definition
        if ($poNo) {
            Write-Host ("PO Routing Definition for " + $poNo + ":") -ForegroundColor Yellow
            $cmdPo = $conn.CreateCommand()
            $cmdPo.CommandText = "
                SELECT RouteIndex, RouteCode, IsInputRoute, IsOutputRoute, CompanyCode
                FROM SmartFactoryV2.dbo.STB_ProductionOrderRouting WITH(NOLOCK)
                WHERE PONo = @PONo
                ORDER BY RouteIndex;"
            $cmdPo.Parameters.AddWithValue("@PONo", $poNo) | Out-Null
            
            $dtPo = New-Object System.Data.DataTable
            $adapterPo = New-Object System.Data.SqlClient.SqlDataAdapter($cmdPo)
            $adapterPo.Fill($dtPo) | Out-Null
            
            if ($dtPo.Rows.Count -eq 0) {
                Write-Host "  No routing definition found for PO." -ForegroundColor Gray
            } else {
                Out-ConsoleTable -DataTable $dtPo -Columns @("RouteIndex", "RouteCode", "IsInputRoute", "IsOutputRoute", "CompanyCode") -Widths @(12, 12, 15, 15, 12) -Headers @("Route Index", "Route Code", "Input Route", "Output Route", "Company")
            }
        }
    }
}

# Case 4: Material Lot Tracing (STB_MaterialLotInfo)
if ($LotID) {
    Write-Host ("=== [TRACE] Tracing Material Lot: '" + $LotID + "' ===") -ForegroundColor Cyan
    
    # 1. Query STB_MaterialLotInfo
    $cmdLot = $conn.CreateCommand()
    $cmdLot.CommandText = "
        SELECT MaterialLotNo, LotID, MaterialCode, MaterialWarehouseCode, InitialQty, CurrentQty, VendorLotNo, CreateDateTime, CreateUserID
        FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
        WHERE LotID = @LotID OR MaterialLotNo = @LotID;"
    $cmdLot.Parameters.AddWithValue("@LotID", $LotID) | Out-Null
    
    $dtLot = New-Object System.Data.DataTable
    $adapterLot = New-Object System.Data.SqlClient.SqlDataAdapter($cmdLot)
    $adapterLot.Fill($dtLot) | Out-Null
    
    if ($dtLot.Rows.Count -eq 0) {
        $cmdLot2 = $conn.CreateCommand()
        $cmdLot2.CommandText = "
            SELECT MaterialDocNo, LotID, MaterialLotNo, MaterialCode, StockQty, MaterialLocationCode, CreateDateTime
            FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo WITH(NOLOCK)
            WHERE LotID = @LotID OR MaterialLotNo = @LotID;"
        $cmdLot2.Parameters.AddWithValue("@LotID", $LotID) | Out-Null
        
        $dtLot2 = New-Object System.Data.DataTable
        $adapterLot2 = New-Object System.Data.SqlClient.SqlDataAdapter($cmdLot2)
        $adapterLot2.Fill($dtLot2) | Out-Null
        
        if ($dtLot2.Rows.Count -eq 0) {
            Write-Host "No record found in STB_MaterialLotInfo or STB_MaterialDocLotInfo for LotID." -ForegroundColor Yellow
        } else {
            Write-Host "STB_MaterialDocLotInfo Record (Doc Lot):" -ForegroundColor Yellow
            Out-ConsoleTable -DataTable $dtLot2 -Columns @("MaterialDocNo", "LotID", "MaterialLotNo", "MaterialCode", "StockQty", "MaterialLocationCode", "CreateDateTime") -Widths @(15, 22, 16, 15, 12, 12, 18) -Headers @("Doc No", "Lot ID", "Mat Lot No", "Material Code", "Stock Qty", "Location", "Create Date/Time")
        }
    } else {
        Write-Host "STB_MaterialLotInfo Record:" -ForegroundColor Yellow
        Out-ConsoleTable -DataTable $dtLot -Columns @("MaterialLotNo", "LotID", "MaterialCode", "MaterialWarehouseCode", "InitialQty", "CurrentQty", "CreateDateTime") -Widths @(16, 22, 15, 15, 12, 12, 18) -Headers @("Mat Lot No", "Lot ID", "Material Code", "Warehouse", "Initial Qty", "Current Qty", "Create Date/Time")
        
        $matLotNo = $dtLot.Rows[0].MaterialLotNo
        $matCode = $dtLot.Rows[0].MaterialCode
        
        # 2. Query QC decision from STB_MaterialQcInfo
        $cmdQc = $conn.CreateCommand()
        $cmdQc.CommandText = "
            SELECT DecisionResult, DecisionDateTime, DecisionUserID
            FROM SmartFactoryV2.dbo.STB_MaterialQcInfo WITH(NOLOCK)
            WHERE VendorLotNo = @LotID OR IQCSampleLotList LIKE @LotIDPattern;"
        $cmdQc.Parameters.AddWithValue("@LotID", $dtLot.Rows[0].LotID) | Out-Null
        $cmdQc.Parameters.AddWithValue("@LotIDPattern", "%" + $dtLot.Rows[0].LotID + "%") | Out-Null
        
        $dtQc = New-Object System.Data.DataTable
        $adapterQc = New-Object System.Data.SqlClient.SqlDataAdapter($cmdQc)
        $adapterQc.Fill($dtQc) | Out-Null
        
        if ($dtQc.Rows.Count -gt 0) {
            Write-Host "QC Inspection Result (STB_MaterialQcInfo):" -ForegroundColor Yellow
            Out-ConsoleTable -DataTable $dtQc -Columns @("DecisionResult", "DecisionDateTime", "DecisionUserID") -Widths @(15, 18, 15) -Headers @("QC Decision", "Decision Date/Time", "QC User")
        } else {
            Write-Host "  No QC inspection result found in STB_MaterialQcInfo for this lot." -ForegroundColor Gray
        }
        
        # 3. Query Raw Material Usage History (Where this lot was fed - STB_RawMaterialInputHist)
        Write-Host "Raw Material Usage History (Where this lot was fed - STB_RawMaterialInputHist):" -ForegroundColor Yellow
        $cmdUsage = $conn.CreateCommand()
        $cmdUsage.CommandText = "
            SELECT CreateDateTime, Barcode AS TargetBarcode, RouteCode, LotMaterialCode, Qty, CreateUserID
            FROM SmartFactoryV2.dbo.STB_RawMaterialInputHist WITH(NOLOCK)
            WHERE RawMaterialBarcode = @LotID OR MaterialLotNo = @LotID OR MaterialLotNo = @MatLotNo
            ORDER BY CreateDateTime;"
        $cmdUsage.Parameters.AddWithValue("@LotID", $LotID) | Out-Null
        $cmdUsage.Parameters.AddWithValue("@MatLotNo", $matLotNo) | Out-Null
        
        $dtUsage = New-Object System.Data.DataTable
        $adapterUsage = New-Object System.Data.SqlClient.SqlDataAdapter($cmdUsage)
        $adapterUsage.Fill($dtUsage) | Out-Null
        
        if ($dtUsage.Rows.Count -eq 0) {
            Write-Host "  This lot has not been recorded as fed into any product barcode." -ForegroundColor Gray
        } else {
            Out-ConsoleTable -DataTable $dtUsage -Columns @("CreateDateTime", "TargetBarcode", "RouteCode", "LotMaterialCode", "Qty", "CreateUserID") -Widths @(18, 22, 8, 18, 8, 15) -Headers @("Usage Date/Time", "Target Barcode", "Route", "Material Code", "Qty", "User ID")
        }
        
        # 4. Query Model Configuration (STB_ModelBasicInfo)
        if ($matCode) {
            $cmdModel = $conn.CreateCommand()
            $cmdModel.CommandText = "
                SELECT ModelCode, ModelName, OqcType, InspectionType, InspectionLevel, MBIExtText01 AS [Voltage], MBIExtText02 AS [Farad], AcEsr, DcEsr, LeakageCurrent
                FROM SmartFactoryV2.dbo.STB_ModelBasicInfo WITH(NOLOCK)
                WHERE ModelCode = @ModelCode;"
            $cmdModel.Parameters.AddWithValue("@ModelCode", $matCode) | Out-Null
            
            $dtModel = New-Object System.Data.DataTable
            $adapterModel = New-Object System.Data.SqlClient.SqlDataAdapter($cmdModel)
            $adapterModel.Fill($dtModel) | Out-Null
            
            if ($dtModel.Rows.Count -gt 0) {
                Write-Host "Model Basic Configuration (STB_ModelBasicInfo):" -ForegroundColor Yellow
                Out-ConsoleTable -DataTable $dtModel -Columns @("ModelCode", "ModelName", "OqcType", "Voltage", "Farad", "AcEsr", "DcEsr", "LeakageCurrent") -Widths @(15, 12, 10, 10, 8, 8, 8, 12) -Headers @("Model Code", "Model Name", "OQC Type", "Volt", "Farad", "AC ESR", "DC ESR", "Leak Current")
            } else {
                Write-Host ("  [WARNING] Model " + $matCode + " is NOT configured in STB_ModelBasicInfo!") -ForegroundColor Red
            }
        }
        
        # 5. Query Material Master info
        $cmdMat = $conn.CreateCommand()
        $cmdMat.CommandText = "
            SELECT MaterialCode, MaterialName, MaterialSpec, MaterialUnit, MaterialTypeCode
            FROM SmartFactoryV2.dbo.STB_MaterialMaster WITH(NOLOCK)
            WHERE MaterialCode = @MaterialCode;"
        $cmdMat.Parameters.AddWithValue("@MaterialCode", $matCode) | Out-Null
        
        $dtMat = New-Object System.Data.DataTable
        $adapterMat = New-Object System.Data.SqlClient.SqlDataAdapter($cmdMat)
        $adapterMat.Fill($dtMat) | Out-Null
        
        if ($dtMat.Rows.Count -gt 0) {
            Write-Host "Material Master Info:" -ForegroundColor Yellow
            Out-ConsoleTable -DataTable $dtMat -Columns @("MaterialCode", "MaterialName", "MaterialSpec", "MaterialUnit", "MaterialTypeCode") -Widths @(15, 30, 20, 8, 10) -Headers @("Material Code", "Material Name", "Spec", "Unit", "Type")
        }
    }
}

$conn.Close()

# If OutFile is specified, export the styled HTML report and launch the browser
if ($OutFile) {
    $absolutePath = [System.IO.Path]::GetFullPath($OutFile)
    
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MES Diagnostic Report - $Barcode $LotID $TCode</title>
    <style>
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: #0f172a; color: #f1f5f9; padding: 2rem; margin: 0; line-height: 1.5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #334155; padding-bottom: 1rem; margin-bottom: 2rem; }
        .header h1 { margin: 0; color: #38bdf8; font-size: 2rem; }
        .header .meta { text-align: right; color: #94a3b8; font-size: 0.9rem; }
        .card { background: #1e293b; border-radius: 12px; padding: 1.5rem; margin-bottom: 2rem; border: 1px solid #334155; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .card h2 { margin-top: 0; color: #f472b6; border-bottom: 1px solid #334155; padding-bottom: 0.5rem; font-size: 1.3rem; }
        .grid-meta { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
        .meta-item { background: #0f172a; padding: 1rem; border-radius: 8px; border: 1px solid #334155; }
        .meta-item label { display: block; color: #94a3b8; font-size: 0.8rem; text-transform: uppercase; margin-bottom: 0.25rem; }
        .meta-item span { font-weight: 600; color: #f1f5f9; }
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th { background: #334155; text-align: left; padding: 0.75rem; color: #38bdf8; font-weight: 600; font-size: 0.9rem; }
        td { padding: 0.75rem; border-bottom: 1px solid #334155; font-size: 0.9rem; color: #cbd5e1; }
        tr:hover td { background: rgba(56, 189, 248, 0.03); color: #f1f5f9; }
        .badge { display: inline-block; padding: 0.25rem 0.5rem; border-radius: 4px; font-weight: bold; font-size: 0.75rem; }
        .badge-success { background: rgba(74, 222, 128, 0.1); color: #4ade80; border: 1px solid #4ade80; }
        .badge-danger { background: rgba(248, 113, 113, 0.1); color: #f87171; border: 1px solid #f87171; }
        .warning-card { background: rgba(248, 113, 113, 0.05); border: 1px solid #f87171; border-left: 6px solid #f87171; padding: 1rem; border-radius: 8px; color: #f87171; margin-bottom: 1.5rem; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>MES Diagnostic & Trace Report</h1>
                <div style="color: #94a3b8; margin-top: 0.25rem;">Target: $Barcode $LotID $TCode</div>
            </div>
            <div class="meta">
                <div>Generated: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))</div>
                <div>Server: dbserver.hycap.co.kr,5398</div>
            </div>
        </div>
"@

        if ($dtScreen -and $dtScreen.Rows.Count -gt 0) {
            $row = $dtScreen.Rows[0]
            $html += @"
        <div class="card">
            <h2>Screen Info (TCode: $TCode)</h2>
            <div class="grid-meta">
                <div class="meta-item"><label>Screen Name</label><span>$($row.Name)</span></div>
                <div class="meta-item"><label>Caption</label><span>$($row.Caption)</span></div>
                <div class="meta-item"><label>Parent Menu</label><span>$($row.ParentName)</span></div>
                <div class="meta-item"><label>Show In Menu</label><span>$($row.ShowInMenu)</span></div>
            </div>
        </div>
"@
        }

        if ($dtObjects -and $dtObjects.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>Registered Stored Procedures & UI Objects</h2>
            <table>
                <thead>
                    <tr><th>ObjectName</th><th>ObjectType</th><th>Caption</th></tr>
                </thead>
                <tbody>
"@
            foreach ($r in $dtObjects.Rows) {
                $html += "<tr><td>$($r.ObjectName)</td><td>$($r.ObjectType)</td><td>$($r.Caption)</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtRes -and $dtRes.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>Matched String Resources</h2>
            <table>
                <thead>
                    <tr><th>Name</th><th>Language</th><th>Value</th></tr>
                </thead>
                <tbody>
"@
            foreach ($r in $dtRes.Rows) {
                $html += "<tr><td>$($r.Name)</td><td>$($r.Language)</td><td>$($r.Value)</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtSps -and $dtSps.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>Referencing Stored Procedures</h2>
            <table>
                <thead>
                    <tr><th>Stored Procedure Name</th><th>Matched Key(s)</th></tr>
                </thead>
                <tbody>
"@
            foreach ($spRow in $dtSps.Rows) {
                $spName = $spRow.SPName
                $matchedKeys = @()
                foreach ($key in $keys) {
                    $cleanKey = $key.Replace("^", "")
                    if ($spRow.definition -match [regex]::Escape($key) -or $spRow.definition -match [regex]::Escape($cleanKey)) {
                        $matchedKeys += $key
                    }
                }
                $html += "<tr><td><strong>$spName</strong></td><td>$($matchedKeys -join ', ')</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtSet -and $dtSet.Rows.Count -gt 0) {
            $row = $dtSet.Rows[0]
            $qcBadge = if ($row.LotDecisionResult -eq 'Pass') { "<span class='badge badge-success'>PASS</span>" } else { "<span class='badge badge-danger'>$($row.LotDecisionResult)</span>" }
            $html += @"
        <div class="card">
            <h2>Barcode Info (STB_SetInfo)</h2>
            <div class="grid-meta">
                <div class="meta-item"><label>ControlNo</label><span>$($row.ControlNo)</span></div>
                <div class="meta-item"><label>PONo</label><span>$($row.PONo)</span></div>
                <div class="meta-item"><label>MaterialCode</label><span>$($row.MaterialCode)</span></div>
                <div class="meta-item"><label>SetSeq</label><span>$($row.SetSeq)</span></div>
                <div class="meta-item"><label>IsLineInput</label><span>$($row.IsLineInput)</span></div>
                <div class="meta-item"><label>QC Status</label><span>$qcBadge</span></div>
                <div class="meta-item"><label>Create DateTime</label><span>$($row.CreateDateTime)</span></div>
            </div>
        </div>
"@
        }

        if ($dtModel -and $dtModel.Rows.Count -gt 0) {
            $row = $dtModel.Rows[0]
            $html += @"
        <div class="card">
            <h2>Model Configuration (STB_ModelBasicInfo)</h2>
            <div class="grid-meta">
                <div class="meta-item"><label>ModelCode</label><span>$($row.ModelCode)</span></div>
                <div class="meta-item"><label>ModelName</label><span>$($row.ModelName)</span></div>
                <div class="meta-item"><label>OqcType</label><span>$($row.OqcType)</span></div>
                <div class="meta-item"><label>Voltage</label><span>$($row.Voltage)</span></div>
                <div class="meta-item"><label>Farad</label><span>$($row.Farad)</span></div>
                <div class="meta-item"><label>AC ESR</label><span>$($row.AcEsr)</span></div>
                <div class="meta-item"><label>DC ESR</label><span>$($row.DcEsr)</span></div>
                <div class="meta-item"><label>Leakage Current</label><span>$($row.LeakageCurrent)</span></div>
            </div>
        </div>
"@
        } elseif ($matCode) {
            $html += @"
        <div class="warning-card">
            <strong>[WARNING]</strong> Model $matCode is NOT configured in STB_ModelBasicInfo!
        </div>
"@
        }

        if ($dtHist -and $dtHist.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>Routing Scan History (STB_ProdRouteHist)</h2>
            <table>
                <thead>
                    <tr><th>CreateDateTime</th><th>RouteCode</th><th>LineCode</th><th>MachineCode</th><th>WorkerCode</th><th>ProdQty</th><th>JobDate</th></tr>
                </thead>
                <tbody>
"@
            foreach ($r in $dtHist.Rows) {
                $html += "<tr><td>$($r.CreateDateTime)</td><td><strong>$($r.RouteCode)</strong></td><td>$($r.LineCode)</td><td>$($r.MachineCode)</td><td>$($r.WorkerCode)</td><td>$($r.ProdQty)</td><td>$($r.JobDate)</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtFed -and $dtFed.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>Raw Material Feeding History (STB_RawMaterialInputHist)</h2>
            <table>
                <thead>
                    <tr><th>CreateDateTime</th><th>RouteCode</th><th>LotMaterialCode</th><th>RawMaterialBarcode</th><th>MaterialLotNo</th><th>Qty</th><th>MachineCode</th></tr>
                </thead>
                <tbody>
"@
            foreach ($r in $dtFed.Rows) {
                $html += "<tr><td>$($r.CreateDateTime)</td><td>$($r.RouteCode)</td><td>$($r.LotMaterialCode)</td><td>$($r.RawMaterialBarcode)</td><td>$($r.MaterialLotNo)</td><td>$($r.Qty)</td><td>$($r.MachineCode)</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtPo -and $dtPo.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>PO Routing Definition</h2>
            <table>
                <thead>
                    <tr><th>RouteIndex</th><th>RouteCode</th><th>IsInputRoute</th><th>IsOutputRoute</th><th>CompanyCode</th></tr>
                </thead>
                <tbody>
"@
            foreach ($r in $dtPo.Rows) {
                $html += "<tr><td>$($r.RouteIndex)</td><td><strong>$($r.RouteCode)</strong></td><td>$($r.IsInputRoute)</td><td>$($r.IsOutputRoute)</td><td>$($r.CompanyCode)</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtLot -and $dtLot.Rows.Count -gt 0) {
            $row = $dtLot.Rows[0]
            $html += @"
        <div class="card">
            <h2>Material Lot Info (STB_MaterialLotInfo)</h2>
            <div class="grid-meta">
                <div class="meta-item"><label>MaterialLotNo</label><span>$($row.MaterialLotNo)</span></div>
                <div class="meta-item"><label>LotID</label><span>$($row.LotID)</span></div>
                <div class="meta-item"><label>MaterialCode</label><span>$($row.MaterialCode)</span></div>
                <div class="meta-item"><label>Warehouse</label><span>$($row.MaterialWarehouseCode)</span></div>
                <div class="meta-item"><label>Initial Qty</label><span>$($row.InitialQty)</span></div>
                <div class="meta-item"><label>Current Qty</label><span>$($row.CurrentQty)</span></div>
                <div class="meta-item"><label>Vendor Lot No</label><span>$($row.VendorLotNo)</span></div>
                <div class="meta-item"><label>Create DateTime</label><span>$($row.CreateDateTime)</span></div>
            </div>
        </div>
"@
        }

        if ($dtQc -and $dtQc.Rows.Count -gt 0) {
            $row = $dtQc.Rows[0]
            $badgeClass = if ($row.DecisionResult -eq 'PASS' -or $row.DecisionResult -eq 'Pass') { "badge-success" } else { "badge-danger" }
            $html += @"
        <div class="card">
            <h2>QC Inspection Result (STB_MaterialQcInfo)</h2>
            <div class="grid-meta">
                <div class="meta-item"><label>Decision Result</label><span class="badge $badgeClass">$($row.DecisionResult)</span></div>
                <div class="meta-item"><label>Decision DateTime</label><span>$($row.DecisionDateTime)</span></div>
                <div class="meta-item"><label>Decision User</label><span>$($row.DecisionUserID)</span></div>
            </div>
        </div>
"@
        }

        if ($dtUsage -and $dtUsage.Rows.Count -gt 0) {
            $html += @"
        <div class="card">
            <h2>Raw Material Usage History (Where Fed)</h2>
            <table>
                <thead>
                    <tr><th>CreateDateTime</th><th>TargetBarcode</th><th>RouteCode</th><th>LotMaterialCode</th><th>Qty</th><th>MachineCode</th></tr>
                </thead>
                <tbody>
"@
            foreach ($r in $dtUsage.Rows) {
                $html += "<tr><td>$($r.CreateDateTime)</td><td><strong>$($r.TargetBarcode)</strong></td><td>$($r.RouteCode)</td><td>$($r.LotMaterialCode)</td><td>$($r.Qty)</td><td>$($r.MachineCode)</td></tr>"
            }
            $html += "</tbody></table></div>"
        }

        if ($dtMat -and $dtMat.Rows.Count -gt 0) {
            $row = $dtMat.Rows[0]
            $html += @"
        <div class="card">
            <h2>Material Master Info (STB_MaterialMaster)</h2>
            <div class="grid-meta">
                <div class="meta-item"><label>MaterialCode</label><span>$($row.MaterialCode)</span></div>
                <div class="meta-item"><label>MaterialName</label><span>$($row.MaterialName)</span></div>
                <div class="meta-item"><label>Spec</label><span>$($row.MaterialSpec)</span></div>
                <div class="meta-item"><label>Unit</label><span>$($row.MaterialUnit)</span></div>
                <div class="meta-item"><label>Type</label><span>$($row.MaterialTypeCode)</span></div>
            </div>
        </div>
"@
        }

        $html += @"
    </div>
</body>
</html>
"@

    $html | Out-File -FilePath $absolutePath -Encoding utf8
    Write-Host "[OK] Styled HTML report generated at: $absolutePath" -ForegroundColor Green
    Start-Process $absolutePath
}
