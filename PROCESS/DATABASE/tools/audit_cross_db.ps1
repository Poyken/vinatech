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
    s.name AS [Schema],
    o.name AS ObjectName,
    o.type_desc AS ObjectType,
    o.modify_date AS ModifyDate,
    m.definition AS Definition
FROM sys.sql_modules m WITH(NOLOCK)
JOIN sys.objects o WITH(NOLOCK) ON m.object_id = o.object_id
JOIN sys.schemas s WITH(NOLOCK) ON o.schema_id = s.schema_id
WHERE ($whereSQL)
ORDER BY o.modify_date DESC;
"@
        $cmd.CommandTimeout = 60
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $tableRes = $ds.Tables[0]

        foreach ($row in $tableRes.Rows) {
            # Find which external DBs were referenced
            $referencedDBs = @()
            foreach ($db in $searchTerms) {
                if ($row.Definition -match "(?i)\b$db\b\.|\b\[$db\]\b") {
                    $referencedDBs += $db
                }
            }

            $allResults += [PSCustomObject]@{
                SourceDB     = $row.SourceDB
                Schema       = $row.Schema
                ObjectName   = $row.ObjectName
                ObjectType   = $row.ObjectType
                ModifyDate   = $row.ModifyDate
                ReferencedDB = ($referencedDBs | Select-Object -Unique) -join ", "
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
