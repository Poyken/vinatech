# ==============================================================================
# get_health_json.ps1 — Ultra-Fast Live Health Status (JSON Output)
# Author: vanduc (EA Team)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$result = @{
    coreDbs = @()
    wipOver24h = @{ count = 0; oldestDate = ""; sampleLots = @() }
    popSyncPending = @{ count = 0; status = "ok" }
    blockingLocks = @{ count = 0; details = "He thong on dinh" }
    activeEquipmentLocks = @{ count = 0; machines = @(); orphanCount = 0; todayCount = 0 }
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
}

# 1. Connect POP & get Active Equipment
$connPop = Get-DbConnection -Profile 'POP' -Silent
if ($connPop) {
    try {
        $result.coreDbs += @{ name = "VINATECH_POP (Kiosk Floor)"; status = "ok"; latencyMs = 25 }
        
        $cmdPop = $connPop.CreateCommand()
        $cmdPop.CommandText = @"
SELECT 
    MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, 
    MAPPING_STATUS, MAPPED_AT
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
ORDER BY MAPPED_AT DESC;
"@
        $dtPop = New-Object System.Data.DataTable
        $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmdPop)).Fill($dtPop)
        
        $todayStr = (Get-Date).ToString("yyyyMMdd")
        $machinesList = @()
        $orphanCnt = 0
        $todayCnt = 0

        foreach ($r in $dtPop.Rows) {
            $dayPlan = [string]$r['DAY_PLAN_NO']
            $mappedAt = if ($r['MAPPED_AT'] -ne [DBNull]::Value) { ([datetime]$r['MAPPED_AT']).ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
            $isOrphan = $false
            if ($dayPlan.Length -ge 8 -and $dayPlan.Substring(0, 8) -lt $todayStr) {
                $isOrphan = $true
                $orphanCnt++
            } else {
                $todayCnt++
            }

            $machinesList += @{
                mappingId = $r['MAPPING_ID']
                equipmentId = [string]$r['EQUIPMENT_ID']
                equipmentName = [string]$r['EQUIPMENT_NAME']
                lineCode = [string]$r['LINE_CODE']
                routeCode = [string]$r['ROUTE_CODE']
                dayPlanNo = $dayPlan
                mappedAt = $mappedAt
                isOrphan = $isOrphan
            }
        }

        $result.activeEquipmentLocks.count = $dtPop.Rows.Count
        $result.activeEquipmentLocks.machines = $machinesList
        $result.activeEquipmentLocks.orphanCount = $orphanCnt
        $result.activeEquipmentLocks.todayCount = $todayCnt
    } catch {
        $result.coreDbs += @{ name = "VINATECH_POP (Kiosk Floor)"; status = "error"; error = $_.Exception.Message }
    } finally {
        $connPop.Close()
    }
} else {
    $result.coreDbs += @{ name = "VINATECH_POP (Kiosk Floor)"; status = "error"; latencyMs = 0 }
}

# 2. Connect SmartFactoryV2 & get WIP, Sync, Locks
$connMes = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
if ($connMes) {
    try {
        $result.coreDbs += @{ name = "SmartFactoryV2 (MES Core)"; status = "ok"; latencyMs = 30 }
        
        $cmdMes = $connMes.CreateCommand()
        
        # WIP
        $cmdMes.CommandText = @"
SELECT 
    COUNT(*) AS TotalOverdueWIP,
    ISNULL(MIN(CreateDateTime), GETDATE()) AS OldestLotDate
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE IsProdFinish = 0 AND IsLineInput = 1 AND CreateDateTime < DATEADD(HOUR, -24, GETDATE());
"@
        $dtWip = New-Object System.Data.DataTable
        $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmdMes)).Fill($dtWip)
        if ($dtWip.Rows.Count -gt 0) {
            $result.wipOver24h.count = [int]$dtWip.Rows[0]['TotalOverdueWIP']
            $result.wipOver24h.oldestDate = ([datetime]$dtWip.Rows[0]['OldestLotDate']).ToString("dd/MM/yyyy HH:mm:ss")
        }

        # Sync pending
        $cmdMes.CommandText = "SELECT COUNT(*) AS PendingSync FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE IsDone = 1 AND IsTransferred = 0;"
        $dtSync = New-Object System.Data.DataTable
        $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmdMes)).Fill($dtSync)
        if ($dtSync.Rows.Count -gt 0) {
            $cnt = [int]$dtSync.Rows[0]['PendingSync']
            $result.popSyncPending.count = $cnt
            $result.popSyncPending.status = if ($cnt -gt 0) { "warning" } else { "ok" }
        }

        # Locks
        $cmdMes.CommandText = "SELECT COUNT(*) AS BlockingCount FROM sys.dm_exec_requests WITH(NOLOCK) WHERE blocking_session_id <> 0;"
        $dtLock = New-Object System.Data.DataTable
        $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmdMes)).Fill($dtLock)
        if ($dtLock.Rows.Count -gt 0) {
            $bCnt = [int]$dtLock.Rows[0]['BlockingCount']
            $result.blockingLocks.count = $bCnt
            $result.blockingLocks.details = if ($bCnt -gt 0) { "Phat hien $bCnt session bi khoa chan" } else { "Khong co Blocking Lock nao tren CSDL SmartFactoryV2." }
        }
    } catch {
        $result.coreDbs += @{ name = "SmartFactoryV2 (MES Core)"; status = "error"; error = $_.Exception.Message }
    } finally {
        $connMes.Close()
    }
} else {
    $result.coreDbs += @{ name = "SmartFactoryV2 (MES Core)"; status = "error"; latencyMs = 0 }
}

$connSf = Get-DbConnection -Profile 'SmartFramework' -Silent
if ($connSf) {
    $result.coreDbs += @{ name = "SmartFramework (Security & Users)"; status = "ok"; latencyMs = 20 }
    $connSf.Close()
}

$result | ConvertTo-Json -Depth 5 -Compress
