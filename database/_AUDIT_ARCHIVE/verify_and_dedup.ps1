$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database'
$exportDir = Join-Path $baseDir 'schema_export'
$removedDir = Join-Path $baseDir '_Removed_NonCore_Workspace\Duplicates'

if (!(Test-Path $removedDir)) { New-Item -Path $removedDir -ItemType Directory -Force | Out-Null }

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " 1. VERIFYING EXPORT COMPLETENESS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

foreach ($db in @('SmartFactoryV2', 'SmartFramework')) {
    $summaryPath = Join-Path $exportDir "$db\EXPORT_SUMMARY.md"
    if (Test-Path $summaryPath) {
        Write-Host "`n>> $db EXPORT STATUS:" -ForegroundColor Yellow
        $content = Get-Content $summaryPath
        $content | ForEach-Object { 
            if ($_ -match "Tables:|Stored Procedures:|Functions:|Views:|Triggers:|TOTAL") {
                Write-Host "  $_"
            }
        }
        
        # Verify if folders actually have files
        $dbDir = Join-Path $exportDir $db
        $actualFiles = (Get-ChildItem -Path $dbDir -Recurse -Filter "*.sql" | Measure-Object).Count
        Write-Host "  Actual .sql files generated: $actualFiles" -ForegroundColor Green
    } else {
        Write-Host "`n>> $db SUMMARY NOT FOUND - Export might have failed!" -ForegroundColor Red
    }
}


Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host " 2. CLEANING UP DUPLICATE OLD FILES" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Get all real-time files we just exported
$realtimeFiles = Get-ChildItem -Path $exportDir -Recurse -Filter "*.sql" | Where-Object { $_.Name -notmatch "ALL_" }

$duplicateCount = 0

Write-Host "Scanning for duplicates in other folders (keeping only realtime files from schema_export)..."

# Get all SQL files in the workspace EXCLUDING schema_export and _Removed_NonCore_Workspace
$allOtherFiles = Get-ChildItem -Path $baseDir -Recurse -Filter "*.sql" | Where-Object {
    $_.FullName -notmatch 'schema_export' -and 
    $_.FullName -notmatch '_Removed_NonCore'
}

# Create a hashtable for fast lookup of exported filenames
$realtimeDict = @{}
foreach ($f in $realtimeFiles) {
    $realtimeDict[$f.Name.ToLower()] = $true
}

foreach ($otherFile in $allOtherFiles) {
    $nameLower = $otherFile.Name.ToLower()
    if ($realtimeDict.ContainsKey($nameLower)) {
        # This is a duplicate of a file we just pulled from the DB
        $targetDir = Join-Path $removedDir $otherFile.Directory.Name
        if (!(Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory -Force | Out-Null }
        
        Move-Item -Path $otherFile.FullName -Destination $targetDir -Force
        Write-Host "  Removed duplicate: $($otherFile.FullName)" -ForegroundColor DarkGray
        $duplicateCount++
    }
}

Write-Host "`nCleanup Complete! Removed $duplicateCount old duplicate files." -ForegroundColor Green
