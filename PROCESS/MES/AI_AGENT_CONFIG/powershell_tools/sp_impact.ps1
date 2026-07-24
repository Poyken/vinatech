# Script Phân Tích Mức Độ Ảnh Hưởng SP (Dependency & Screen Usage Analyzer)
param(
    [Parameter(Mandatory=$true)]
    [string]$SPName
)

$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$runQueryScript = "$baseDir\run_query.ps1"

$cleanSP = $SPName.Trim()

Write-Host "Analyzing impact and dependencies for Stored Procedure [$cleanSP]..."

# 1. Query dependencies in SQL Server
$sqlDep = @"
SELECT 
    OBJECT_NAME(referencing_id) AS ReferencingObject,
    o.type_desc AS ObjectType
FROM sys.sql_expression_dependencies d
JOIN sys.objects o ON d.referencing_id = o.object_id
WHERE d.referenced_entity_name = '$cleanSP'
ORDER BY o.type_desc, OBJECT_NAME(referencing_id);
"@

Write-Host "=== 1. DEPENDENT SQL OBJECTS ==="
& "$runQueryScript" -Query $sqlDep

# 2. Query ScreenInfo in SmartFramework
$sqlScreen = @"
SELECT Name AS ScreenName, TCode, Caption 
FROM SmartFramework.dbo.STB_ScreenInfo WITH(NOLOCK)
WHERE Name LIKE '%$cleanSP%' OR TCode LIKE '%$cleanSP%';
"@

Write-Host "=== 2. MAPPED MES SCREENS ==="
& "$runQueryScript" -Query $sqlScreen

