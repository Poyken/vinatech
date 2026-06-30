param (
    [string]$TCode,
    [string]$ErrorMsg,
    [string]$Barcode,
    [string]$LotID
)

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

if ([string]::IsNullOrEmpty($TCode) -and [string]::IsNullOrEmpty($ErrorMsg) -and [string]::IsNullOrEmpty($Barcode) -and [string]::IsNullOrEmpty($LotID)) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -TCode B523" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -ErrorMsg 'chua duoc dua vao tuyen'" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -Barcode 'K16418106262500772'" -ForegroundColor Yellow
    Write-Host "  .\debug_screen.ps1 -LotID 'WRHI00-002'" -ForegroundColor Yellow
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
            $dtObjects | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
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
        $dtRes | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        
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
        $dtSet | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        
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
                $dtModel | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
            } else {
                Write-Host ("  [WARNING] Model " + $matCode + " is NOT configured in STB_ModelBasicInfo!") -ForegroundColor Red
            }
        }
        
        # 3. Query Scan History (STB_ProdRouteHist)
        Write-Host "Routing Scan History (STB_ProdRouteHist):" -ForegroundColor Yellow
        $cmdHist = $conn.CreateCommand()
        $cmdHist.CommandText = "
            SELECT CreateDateTime, RouteCode, LineCode, MachineCode, WorkerCode, ProdQty, JobDate, ShiftCode, CreateUserID
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
            $dtHist | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        }
        
        # 4. Query Raw Material Feeding History (STB_RawMaterialInputHist)
        Write-Host "Raw Material Feeding History (STB_RawMaterialInputHist):" -ForegroundColor Yellow
        $cmdFed = $conn.CreateCommand()
        $cmdFed.CommandText = "
            SELECT CreateDateTime, RouteCode, LotMaterialCode, RawMaterialBarcode, MaterialLotNo, Qty, MachineCode, CreateUserID
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
            $dtFed | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
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
                $dtPo | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
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
            $dtLot2 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        }
    } else {
        Write-Host "STB_MaterialLotInfo Record:" -ForegroundColor Yellow
        $dtLot | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        
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
            $dtQc | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        } else {
            Write-Host "  No QC inspection result found in STB_MaterialQcInfo for this lot." -ForegroundColor Gray
        }
        
        # 3. Query Raw Material Usage History (Where this lot was fed - STB_RawMaterialInputHist)
        Write-Host "Raw Material Usage History (Where this lot was fed - STB_RawMaterialInputHist):" -ForegroundColor Yellow
        $cmdUsage = $conn.CreateCommand()
        $cmdUsage.CommandText = "
            SELECT CreateDateTime, Barcode AS TargetBarcode, RouteCode, LotMaterialCode, Qty, MachineCode, CreateUserID
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
            $dtUsage | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
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
                $dtModel | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
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
            $dtMat | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        }
    }
}

$conn.Close()
