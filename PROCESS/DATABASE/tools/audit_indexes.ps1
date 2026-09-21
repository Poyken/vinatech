<#
.SYNOPSIS
    Kiem toan Index, kich thuoc dung luong, do phan manh va de xuat thieu Index tu SQL Server DMVs.
.DESCRIPTION
    Cho phep phan tich chuyen sau index cua mot bang bat ky tren 15 CSDL Vinatech.
    Dac biet quan trong cho cac bang tren 10 trieu rows (nhu STB_VVT_ESRDATA 423M, STB_ProductStockInfo 69M).
#>
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Table,
    [string]$Profile = "SmartFactoryV2",
    [switch]$MissingIndexRecommendations
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  INDEX & PERFORMANCE AUDITOR: Table '$Table' (Profile: $Profile)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$dbObj = Get-DBConnection -Profile $Profile
$conn = $dbObj.Connection

$targetTable = $Table
$targetSchema = "dbo"
if ($Table.Contains(".")) {
    $parts = $Table.Split(".")
    $targetSchema = $parts[0]
    $targetTable = $parts[1]
}

try {
    # 1. Kiem tra danh sach Index hien tai
    Write-Host "1. DANH SACH INDEX HIEN TAI:" -ForegroundColor Yellow
    $cleanTable = $targetTable.Replace("'", "''")
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
SELECT 
    i.index_id AS IndexId,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    CASE WHEN i.is_primary_key = 1 THEN 'YES' ELSE 'NO' END AS IsPK,
    CASE WHEN i.is_unique = 1 THEN 'YES' ELSE 'NO' END AS IsUnique,
    STUFF((
        SELECT ', ' + c.name + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
        FROM sys.index_columns ic WITH(NOLOCK)
        JOIN sys.columns c WITH(NOLOCK) ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') AS KeyColumns,
    ISNULL(STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic WITH(NOLOCK)
        JOIN sys.columns c WITH(NOLOCK) ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        FOR XML PATH('')
    ), 1, 2, ''), 'None') AS IncludedColumns
FROM sys.indexes i WITH(NOLOCK)
JOIN sys.tables t WITH(NOLOCK) ON i.object_id = t.object_id
JOIN sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
WHERE t.name = '$cleanTable' AND s.name = '$targetSchema'
ORDER BY i.index_id;
"@
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    [void]$adapter.Fill($ds)
    $idxTable = $ds.Tables[0]
    $idxTable | Format-Table -AutoSize

    # 2. Dung luong va so luong ban ghi (Space Used)
    Write-Host "2. DUNG LUONG VA SO LUONG BAN GHI (SPACE USED):" -ForegroundColor Yellow
    $cmdSpace = $conn.CreateCommand()
    $cmdSpace.CommandText = @"
SELECT 
    t.name AS TableName,
    p.rows AS TotalRows,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM sys.tables t WITH(NOLOCK)
JOIN sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
JOIN sys.indexes i WITH(NOLOCK) ON t.object_id = i.object_id
JOIN sys.partitions p WITH(NOLOCK) ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units a WITH(NOLOCK) ON p.partition_id = a.container_id
WHERE t.name = '$cleanTable' AND s.name = '$targetSchema' AND i.index_id <= 1
GROUP BY t.name, p.rows;
"@
    $adapterSpace = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSpace)
    $dsSpace = New-Object System.Data.DataSet
    [void]$adapterSpace.Fill($dsSpace)
    if ($dsSpace.Tables[0].Rows.Count -gt 0) {
        $dsSpace.Tables[0] | Format-Table -AutoSize
    }

    # 3. De xuat thieu Index tu SQL Server DMVs
    Write-Host "3. DE XUAT THIEU INDEX (MISSING INDEXES TU SQL SERVER DMV):" -ForegroundColor Yellow
    $cmdMissing = $conn.CreateCommand()
    $cmdMissing.CommandText = @"
SELECT TOP 5
    CAST(migs.user_seeks * migs.avg_total_user_cost * (migs.avg_user_impact * 0.01) AS NUMERIC(20,2)) AS ImprovementScore,
    migs.user_seeks AS UserSeeks,
    migs.avg_user_impact AS AvgImpactPercent,
    mid.equality_columns AS EqualityColumns,
    mid.inequality_columns AS InequalityColumns,
    mid.included_columns AS IncludedColumns
FROM sys.dm_db_missing_index_groups mig WITH(NOLOCK)
JOIN sys.dm_db_missing_index_group_stats migs WITH(NOLOCK) ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid WITH(NOLOCK) ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID() AND mid.object_id = OBJECT_ID('$targetSchema.$cleanTable')
ORDER BY ImprovementScore DESC;
"@
    $adapterMissing = New-Object System.Data.SqlClient.SqlDataAdapter($cmdMissing)
    $dsMissing = New-Object System.Data.DataSet
    [void]$adapterMissing.Fill($dsMissing)
    if ($dsMissing.Tables[0].Rows.Count -gt 0) {
        $dsMissing.Tables[0] | Format-Table -AutoSize
    } else {
        Write-Host "Khong co de xuat thieu index nao tu DMV cho bang nay." -ForegroundColor Green
    }
} finally {
    if ($conn.State -eq [System.Data.ConnectionState]::Open) {
        $conn.Close()
        $conn.Dispose()
    }
}
Write-Host "================================================================================" -ForegroundColor Cyan
