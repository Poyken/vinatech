# Export all routines from VINATECH_GROUP to sql/routines/
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
. "$scriptDir\db_shared.ps1"

$targetDir = "$rootDir\sql\routines"
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

$conn = Get-DbConnection -ProfileName "Groupware"
$query = "SELECT ROUTINE_NAME, ROUTINE_TYPE, OBJECT_DEFINITION(OBJECT_ID(ROUTINE_NAME)) AS DEF FROM INFORMATION_SCHEMA.ROUTINES ORDER BY ROUTINE_TYPE, ROUTINE_NAME"
$dt = Invoke-DbQuery -Connection $conn -Query $query

foreach ($row in $dt.Rows) {
    $name = $row["ROUTINE_NAME"]
    $type = $row["ROUTINE_TYPE"]
    $def = $row["DEF"]
    $filePath = "$targetDir\$name.sql"
    $header = "-- =====================================================================`r`n-- Routine Name: $name`r`n-- Type: $type`r`n-- Source DB: VINATECH_GROUP`r`n-- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n-- =====================================================================`r`n`r`n"
    [System.IO.File]::WriteAllText($filePath, $header + $def, [System.Text.Encoding]::UTF8)
    Write-Host "[OK] Exported $type $name -> $filePath"
}

# Export Views
$viewsDir = "$rootDir\sql\views"
if (-not (Test-Path $viewsDir)) {
    New-Item -ItemType Directory -Force -Path $viewsDir | Out-Null
}

$viewQuery = "SELECT TABLE_NAME, OBJECT_DEFINITION(OBJECT_ID(TABLE_NAME)) AS DEF FROM INFORMATION_SCHEMA.VIEWS ORDER BY TABLE_NAME"
$dtViews = Invoke-DbQuery -Connection $conn -Query $viewQuery

foreach ($row in $dtViews.Rows) {
    $name = $row["TABLE_NAME"]
    $def = $row["DEF"]
    $filePath = "$viewsDir\$name.sql"
    $header = "-- =====================================================================`r`n-- View Name: $name`r`n-- Type: VIEW`r`n-- Source DB: VINATECH_GROUP`r`n-- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n-- =====================================================================`r`n`r`n"
    [System.IO.File]::WriteAllText($filePath, $header + $def, [System.Text.Encoding]::UTF8)
    Write-Host "[OK] Exported VIEW $name -> $filePath"
}

$conn.Close()
Write-Host "All routines and views exported successfully."
