# backup_VE260914.ps1
. (Join-Path $PSScriptRoot "db_shared.ps1")
$backupDir = Join-Path $PSScriptRoot "backups"
$conn = Get-DbConnection -Profile "SmartFactoryV2" -Silent

# 1. Backup STB_DefectRepairInfo
$sql1 = "SELECT * FROM STB_DefectRepairInfo WITH(NOLOCK) WHERE ControlNo = '20260914000299' AND FindRouteCode = 'VE01'"
$da1 = New-Object System.Data.SqlClient.SqlDataAdapter($sql1, $conn)
$dt1 = New-Object System.Data.DataTable
$null = $da1.Fill($dt1)

# 2. Backup STB_CommInspDocItem
$sql2 = "SELECT * FROM STB_CommInspDocItem WITH(NOLOCK) WHERE CommInspDocNo = '20260915000294' AND RouteCode = 'VE01'"
$da2 = New-Object System.Data.SqlClient.SqlDataAdapter($sql2, $conn)
$dt2 = New-Object System.Data.DataTable
$null = $da2.Fill($dt2)

# 3. Backup STB_CommInspMeasureHist
$sql3 = "SELECT MH.* FROM STB_CommInspMeasureHist MH WITH(NOLOCK) JOIN STB_CommInspDocItem Item WITH(NOLOCK) ON MH.CommInspDocItemNo = Item.CommInspDocItemNo WHERE Item.CommInspDocNo = '20260915000294' AND Item.RouteCode = 'VE01'"
$da3 = New-Object System.Data.SqlClient.SqlDataAdapter($sql3, $conn)
$dt3 = New-Object System.Data.DataTable
$null = $da3.Fill($dt3)

$conn.Close()

function Convert-DtToDict($dt) {
    $list = @()
    foreach ($r in $dt.Rows) {
        $h = [ordered]@{}
        foreach ($c in $dt.Columns) {
            $h[$c.ColumnName] = if ($r[$c.ColumnName] -is [System.DBNull]) { $null } else { $r[$c.ColumnName] }
        }
        $list += $h
    }
    return $list
}

$fullData = [ordered]@{
    Meta = [ordered]@{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Barcode = "VE260914-002"
        ControlNo = "20260914000299"
        CommInspDocNo = "20260915000294"
        RouteCode = "VE01"
        Count_DefectRepairInfo = $dt1.Rows.Count
        Count_CommInspDocItem = $dt2.Rows.Count
        Count_CommInspMeasureHist = $dt3.Rows.Count
    }
    STB_DefectRepairInfo = Convert-DtToDict $dt1
    STB_CommInspDocItem = Convert-DtToDict $dt2
    STB_CommInspMeasureHist = Convert-DtToDict $dt3
}

$outFile = Join-Path $backupDir "backup_VE260914-002_pre_fix_20260915.json"
$json = $fullData | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText($outFile, $json, [System.Text.Encoding]::UTF8)

Write-Host "BACKUP_SUCCESS"
Write-Host "Saved STB_DefectRepairInfo: $($dt1.Rows.Count) rows"
Write-Host "Saved STB_CommInspDocItem: $($dt2.Rows.Count) rows"
Write-Host "Saved STB_CommInspMeasureHist: $($dt3.Rows.Count) rows"
Write-Host "File: $outFile"
