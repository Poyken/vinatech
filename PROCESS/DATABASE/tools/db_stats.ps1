<#
.SYNOPSIS
    Bao cao thong ke chuyen sau tren tung CSDL hoac toan bo 15 CSDL.
#>
param (
    [string]$Profile,
    [switch]$All
)

. "$PSScriptRoot\db_shared.ps1"

$config = Get-DBConfig

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  VINATECH DATABASE DEEP METRICS & STATISTICS" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

if ($Profile) {
    Write-Host "THONG KE CHUYEN SAU DATABASE: '$Profile'..." -ForegroundColor Yellow
    $dbObj = Get-DBConnection -Profile $Profile
    $conn = $dbObj.Connection

    try {
        # 1. Tong quan
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = @"
SELECT 
    (SELECT COUNT(*) FROM sys.tables WITH(NOLOCK)) AS TableCount,
    (SELECT COUNT(*) FROM sys.views WITH(NOLOCK)) AS ViewCount,
    (SELECT COUNT(*) FROM sys.procedures WITH(NOLOCK)) AS SPCount,
    (SELECT COUNT(*) FROM sys.foreign_keys WITH(NOLOCK)) AS FKCount
"@
        $reader = $cmd.ExecuteReader()
        if ($reader.Read()) {
            Write-Host "  * Ten CSDL   : $($dbObj.Database)" -ForegroundColor Green
            Write-Host "  * So bang    : $($reader['TableCount']) tables"
            Write-Host "  * So view    : $($reader['ViewCount']) views"
            Write-Host "  * So SP      : $($reader['SPCount']) stored procedures"
            Write-Host "  * So FK      : $($reader['FKCount']) foreign keys"
        }
        $reader.Close()

        # 2. Phan bo tien to (Prefix Distribution)
        Write-Host "`n  * PHAN BO TIEN TO MODULE:" -ForegroundColor Cyan
        $cmd.CommandText = @"
SELECT TOP 10
    CASE 
        WHEN name LIKE '%[_]%' THEN SUBSTRING(name, 1, CHARINDEX('_', name))
        ELSE 'OTHER'
    END AS Prefix,
    COUNT(*) AS TableCount
FROM sys.tables WITH(NOLOCK)
GROUP BY 
    CASE 
        WHEN name LIKE '%[_]%' THEN SUBSTRING(name, 1, CHARINDEX('_', name))
        ELSE 'OTHER'
    END
ORDER BY TableCount DESC;
"@
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $ds.Tables[0] | Format-Table -AutoSize

        # 3. Top bang lon nhat (Top 10)
        Write-Host "  * TOP 10 BANG LON NHAT (Theo so dong):" -ForegroundColor Magenta
        $cmd.CommandText = @"
SELECT TOP 10
    t.name AS TableName,
    p.rows AS [RowCount]
FROM sys.tables t WITH(NOLOCK)
INNER JOIN sys.indexes i WITH(NOLOCK) ON t.object_id = i.object_id
INNER JOIN sys.partitions p WITH(NOLOCK) ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE t.is_ms_shipped = 0 AND i.index_id <= 1
GROUP BY t.name, p.rows
ORDER BY p.rows DESC;
"@
        $ds2 = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds2)
        $ds2.Tables[0] | Format-Table -AutoSize

    } finally {
        $conn.Close()
    }
} else {
    Write-Host "THONG KE TOAN BO 15 CO SO DU LIEU TREN SERVER: $($config.Server)..." -ForegroundColor Yellow
    $report = @()

    foreach ($p in $config.Profiles.PSObject.Properties) {
        $pName = $p.Name
        $dbName = $p.Value.Database
        try {
            $c = Get-DBConnection -Profile $pName
            $conn = $c.Connection

            $cmd = $conn.CreateCommand()
            $cmd.CommandText = @"
SELECT 
    (SELECT COUNT(*) FROM sys.tables WITH(NOLOCK)) AS TableCount,
    (SELECT COUNT(*) FROM sys.views WITH(NOLOCK)) AS ViewCount,
    (SELECT COUNT(*) FROM sys.procedures WITH(NOLOCK)) AS SPCount,
    (SELECT COUNT(*) FROM sys.foreign_keys WITH(NOLOCK)) AS FKCount
"@
            $cmd.CommandTimeout = 10
            $reader = $cmd.ExecuteReader()
            if ($reader.Read()) {
                $report += [PSCustomObject]@{
                    Profile    = $pName
                    Database   = $dbName
                    Tables     = $reader["TableCount"]
                    Views      = $reader["ViewCount"]
                    StoredProc = $reader["SPCount"]
                    FKCount    = $reader["FKCount"]
                }
            }
            $reader.Close()
            $conn.Close()
        } catch {
            $report += [PSCustomObject]@{
                Profile    = $pName
                Database   = $dbName
                Tables     = "ERR"
                Views      = "ERR"
                StoredProc = "ERR"
                FKCount    = "ERR"
            }
        }
    }
    $report | Format-Table -AutoSize
}
Write-Host "================================================================================" -ForegroundColor Cyan
