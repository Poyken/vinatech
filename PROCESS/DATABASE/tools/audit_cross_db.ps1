<#
.SYNOPSIS
    Kiem toan toan bo cac phu thuoc lien co so du lieu (Cross-Database Dependencies).
.DESCRIPTION
    Quet sys.sql_modules trong tung CSDL de tim ra tat ca cac Stored Procedures, Views, Triggers,
    va Functions co chua cau lenh goi truc tiep sang cac CSDL khac hoac Linked Servers.
#>
param (
    [string]$Profile = "SmartFactoryV2",
    [switch]$AllDatabases
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  CROSS-DATABASE DEPENDENCY AUDITOR" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$config = Get-DBConfig
$knownDBs = @(
    'NEOE', 'DZICUBE', 'SmartFactoryV2', 'SmartFramework', 'VINATECH_POP',
    'VINATECH_GROUP', 'AndonDB', 'erpdb', 'WCMS_STANDARD_NEW',
    'SmartFactoryIncubator', 'VINATECH_DATA_KSOX', 'streamdocs',
    'VINATECH_SPREADSHEET', 'VINATECH_WEBSOCKET', 'VINATECH_RESTFUL',
    'ERPSVR', 'OLDNAISSVR', 'CMS_VINA_LINK'
)

$profilesToScan = if ($AllDatabases) {
    @('SmartFactoryV2', 'SmartFramework', 'Groupware', 'ERP', 'Bizbox', 'POP', 'Andon')
} else {
    @($Profile)
}

$allResults = @()

foreach ($p in $profilesToScan) {
    Write-Host "Quet phu thuoc trong Profile '$p'..." -ForegroundColor Yellow
    try {
        $dbObj = Get-DBConnection -Profile $p
        $conn = $dbObj.Connection
        $currentDB = $dbObj.Database

        # Build search patterns for all OTHER known DBs
        $searchTerms = $knownDBs | Where-Object { $_ -ine $currentDB }
        
        $whereClauses = @()
        foreach ($db in $searchTerms) {
            $whereClauses += "m.definition LIKE '%$db.%' OR m.definition LIKE '%[$db].%'"
        }
        $whereSQL = $whereClauses -join " OR "

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = @"
SELECT 
    '$currentDB' AS SourceDB,
    OBJECT_SCHEMA_NAME(d.referencing_id) AS [Schema],
    OBJECT_NAME(d.referencing_id) AS ObjectName,
    o.type_desc AS ObjectType,
    o.modify_date AS ModifyDate,
    ISNULL(d.referenced_server_name + '.', '') + d.referenced_database_name AS ReferencedDB
FROM sys.sql_expression_dependencies d WITH(NOLOCK)
JOIN sys.objects o WITH(NOLOCK) ON d.referencing_id = o.object_id
WHERE d.referenced_database_name IS NOT NULL
GROUP BY d.referencing_id, o.type_desc, o.modify_date, d.referenced_server_name, d.referenced_database_name
ORDER BY o.modify_date DESC;
"@
        $cmd.CommandTimeout = 15
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $tableRes = $ds.Tables[0]

        foreach ($row in $tableRes.Rows) {
            $allResults += [PSCustomObject]@{
                SourceDB     = $row.SourceDB
                Schema       = $row.Schema
                ObjectName   = $row.ObjectName
                ObjectType   = $row.ObjectType
                ModifyDate   = $row.ModifyDate
                ReferencedDB = $row.ReferencedDB
            }
        }

        $conn.Close()
        $conn.Dispose()
    } catch {
        Write-Warning "Loi khi quet CSDL Profile '$p': $($_.Exception.Message)"
    }
}

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "KET QUA KIEM TOAN LIEN CSDL: Phat hien $($allResults.Count) doi tuong co Cross-DB references" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray

if ($allResults.Count -gt 0) {
    $allResults | Format-Table -AutoSize
} else {
    Write-Host "Khong phat hien cross-database reference nao." -ForegroundColor Yellow
}

Write-Host "================================================================================" -ForegroundColor Cyan
