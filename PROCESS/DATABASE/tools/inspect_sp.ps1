<#
.SYNOPSIS
    Tra cuu va doc ma nguon Stored Procedure tren 15 CSDL Vinatech.
#>
param (
    [Parameter(Position=0)]
    [string]$Search,

    [string]$Profile = "SmartFactoryV2",
    [string]$Name,
    [switch]$Definition
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  STORED PROCEDURE INSPECTOR (Profile: $Profile)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$dbObj = Get-DBConnection -Profile $Profile
$conn = $dbObj.Connection

try {
    if ($Definition -and $Name) {
        Write-Host "DOC MA NGUON STORED PROCEDURE: '$Name'..." -ForegroundColor Yellow
        $cmd = $conn.CreateCommand()
        $cleanName = $Name.Replace("'", "''")
        $cmd.CommandText = @"
SELECT TOP 1 m.definition 
FROM sys.sql_modules m WITH(NOLOCK)
JOIN sys.objects o WITH(NOLOCK) ON m.object_id = o.object_id
JOIN sys.schemas s WITH(NOLOCK) ON o.schema_id = s.schema_id
WHERE o.name = '$cleanName' OR (s.name + '.' + o.name) = '$cleanName'
"@
        $cmd.CommandTimeout = 20
        $def = $cmd.ExecuteScalar()

        if ($def) {
            Write-Host "--- BEGIN STORED PROCEDURE DEFINITION ---" -ForegroundColor Green
            Write-Host $def
            Write-Host "--- END STORED PROCEDURE DEFINITION ---" -ForegroundColor Green
        } else {
            Write-Host "Khong tim thay dinh nghia cho Stored Procedure: '$Name'" -ForegroundColor Red
        }
    } else {
        $term = if ($Search) { $Search } else { $Name }
        Write-Host "TIM KIEM STORED PROCEDURE: '$term'..." -ForegroundColor Yellow

        $cmd = $conn.CreateCommand()
        $cleanTerm = $term.Replace("'", "''")
        $cmd.CommandText = @"
SELECT TOP 25
    s.name AS SchemaName,
    p.name AS SPName,
    p.create_date AS CreateDate,
    p.modify_date AS ModifyDate
FROM sys.procedures p WITH(NOLOCK)
JOIN sys.schemas s WITH(NOLOCK) ON p.schema_id = s.schema_id
WHERE p.name LIKE '%$cleanTerm%'
ORDER BY p.modify_date DESC;
"@
        $cmd.CommandTimeout = 15
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $table = $ds.Tables[0]

        if ($table.Rows.Count -gt 0) {
            Write-Host "Tim thay $($table.Rows.Count) Stored Procedures phu hop:" -ForegroundColor Green
            $table | Format-Table -AutoSize
            Write-Host "Meo: Chay '.\db.ps1 sp -Profile $Profile -Name <SPName> -Definition' de doc ma nguon SQL." -ForegroundColor DarkCyan
        } else {
            Write-Host "Khong tim thay Stored Procedure nao khop voi tu khoa '$term'." -ForegroundColor Yellow
        }
    }
} finally {
    if ($conn.State -eq [System.Data.ConnectionState]::Open) {
        $conn.Close()
    }
}
Write-Host "================================================================================" -ForegroundColor Cyan
