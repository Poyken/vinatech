<#
.SYNOPSIS
    Kiem tra va doc ma nguon DML/DDL Triggers tren 15 CSDL Vinatech.
.DESCRIPTION
    Liet ke triggers theo bang, loai trigger (AFTER, INSTEAD OF), trang thai (ENABLED/DISABLED), va cho phep xem chi tiet ma nguon SQL.
#>
param (
    [string]$Profile = "SmartFactoryV2",
    [string]$Table,
    [string]$Name,
    [switch]$Definition
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  TRIGGER INSPECTOR (Profile: $Profile)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$dbObj = Get-DBConnection -Profile $Profile
$conn = $dbObj.Connection

try {
    if ($Definition -and $Name) {
        Write-Host "DOC MA NGUON TRIGGER: '$Name'..." -ForegroundColor Yellow
        $cmd = $conn.CreateCommand()
        $cleanName = $Name.Replace("'", "''")
        $cmd.CommandText = @"
SELECT TOP 1 m.definition 
FROM sys.sql_modules m WITH(NOLOCK)
JOIN sys.triggers t WITH(NOLOCK) ON m.object_id = t.object_id
WHERE t.name = '$cleanName';
"@
        $cmd.CommandTimeout = 20
        $def = $cmd.ExecuteScalar()

        if ($def) {
            Write-Host "--- BEGIN TRIGGER DEFINITION ---" -ForegroundColor Green
            Write-Host $def
            Write-Host "--- END TRIGGER DEFINITION ---" -ForegroundColor Green
        } else {
            Write-Host "Khong tim thay ma nguon cho Trigger: '$Name'" -ForegroundColor Red
        }
    } else {
        $filter = "WHERE 1=1"
        if ($Table) {
            $cleanTable = $Table.Replace("'", "''")
            $filter += " AND OBJECT_NAME(t.parent_id) = '$cleanTable'"
        }
        if ($Name) {
            $cleanName = $Name.Replace("'", "''")
            $filter += " AND t.name LIKE '%$cleanName%'"
        }

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = @"
SELECT 
    t.name AS TriggerName,
    OBJECT_SCHEMA_NAME(t.parent_id) AS [Schema],
    OBJECT_NAME(t.parent_id) AS TableName,
    CASE WHEN t.is_instead_of_trigger = 1 THEN 'INSTEAD OF' ELSE 'AFTER' END AS TriggerType,
    CASE WHEN t.is_disabled = 1 THEN 'DISABLED' ELSE 'ENABLED' END AS Status,
    t.create_date AS CreateDate,
    t.modify_date AS ModifyDate
FROM sys.triggers t WITH(NOLOCK)
$filter
ORDER BY OBJECT_NAME(t.parent_id), t.name;
"@
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $tableRes = $ds.Tables[0]

        if ($tableRes.Rows.Count -gt 0) {
            Write-Host "Tim thay $($tableRes.Rows.Count) Triggers trong database '$($dbObj.Database)':" -ForegroundColor Green
            $tableRes | Format-Table -AutoSize
            Write-Host "Meo: Chay '.\db.ps1 triggers -Profile $Profile -Name <TriggerName> -Definition' de doc ma nguon SQL." -ForegroundColor DarkCyan
        } else {
            Write-Host "Khong tim thay Trigger nao phu hop." -ForegroundColor Yellow
        }
    }
} finally {
    if ($conn.State -eq [System.Data.ConnectionState]::Open) {
        $conn.Close()
        $conn.Dispose()
    }
}
Write-Host "================================================================================" -ForegroundColor Cyan
