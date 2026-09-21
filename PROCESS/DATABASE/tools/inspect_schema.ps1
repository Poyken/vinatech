<#
.SYNOPSIS
    Tra cứu cấu trúc cột, kiểu dữ liệu, và khóa chính của bảng (Data Dictionary).
#>
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Table,
    [string]$Profile = "SmartFactoryV2"
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  SCHEMA AND DATA DICTIONARY: Table '$Table' (Profile: $Profile)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$targetTable = $Table
$targetSchema = $null
if ($Table.Contains(".")) {
    $parts = $Table.Split(".")
    $targetSchema = $parts[0]
    $targetTable = $parts[1]
}

$cleanTable = $targetTable.Replace("'", "''")
$schemaFilter = ""
if ($targetSchema) {
    $cleanSchema = $targetSchema.Replace("'", "''")
    $schemaFilter = "AND c.TABLE_SCHEMA = '$cleanSchema'"
}

$rawSql = @"
SELECT 
    c.TABLE_SCHEMA AS [Schema],
    c.ORDINAL_POSITION AS [No],
    c.COLUMN_NAME AS [ColumnName],
    c.DATA_TYPE AS [DataType],
    CASE 
        WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'max'
        WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
        WHEN c.NUMERIC_PRECISION IS NOT NULL THEN CAST(c.NUMERIC_PRECISION AS VARCHAR(5)) + ',' + CAST(ISNULL(c.NUMERIC_SCALE, 0) AS VARCHAR(5))
        ELSE ''
    END AS [Length/Prec],
    c.IS_NULLABLE AS [Null],
    ISNULL(pk.IsPK, 'NO') AS [IsPK],
    CAST(ep.value AS NVARCHAR(250)) AS [Description]
FROM INFORMATION_SCHEMA.COLUMNS c
LEFT JOIN (
    SELECT ku.TABLE_SCHEMA, ku.TABLE_NAME, ku.COLUMN_NAME, 'YES' AS IsPK
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
        ON tc.CONSTRAINT_TYPE = 'PRIMARY KEY' 
        AND tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
        AND tc.TABLE_SCHEMA = ku.TABLE_SCHEMA
    WHERE ku.TABLE_NAME = '$cleanTable'
) pk ON c.TABLE_SCHEMA = pk.TABLE_SCHEMA AND c.COLUMN_NAME = pk.COLUMN_NAME
LEFT JOIN sys.tables t ON t.name = c.TABLE_NAME
LEFT JOIN sys.schemas s ON s.schema_id = t.schema_id AND s.name = c.TABLE_SCHEMA
LEFT JOIN sys.columns sc ON sc.object_id = t.object_id AND sc.name = c.COLUMN_NAME
LEFT JOIN sys.extended_properties ep ON ep.major_id = t.object_id AND ep.minor_id = sc.column_id AND ep.name = 'MS_Description'
WHERE c.TABLE_NAME = '$cleanTable' $schemaFilter
ORDER BY c.TABLE_SCHEMA, c.ORDINAL_POSITION;
"@

$res = Invoke-SafeSelect -Query $rawSql -Profile $Profile -MaxRows 200

if ($res.Success -and $res.RowCount -gt 0) {
    Write-Host "Table '$Table' in database '$($res.Database)': $($res.RowCount) columns found." -ForegroundColor Green
    $res.Data | Format-Table -AutoSize
} else {
    Write-Host "Khong tim thay bang '$Table' trong database cua Profile '$Profile'." -ForegroundColor Yellow
}
Write-Host "================================================================================" -ForegroundColor Cyan
