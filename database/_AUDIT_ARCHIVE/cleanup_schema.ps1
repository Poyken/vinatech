$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\schema_export'
$removedDir = Join-Path $baseDir '_Removed_NonCore'

if (!(Test-Path $removedDir)) { New-Item -Path $removedDir -ItemType Directory -Force | Out-Null }

$patternsToMove = @(
    "*_201*.sql", "*_202*.sql", "*_21*.sql", "*_22*.sql", "*_23*.sql", # Backup dates (e.g., _20220407, _210121)
    "*_test*.sql", "*_backup*.sql", "*_bak*.sql", "*_back*.sql",       # Test and backup files
    "*temp*.sql", "*tmp*.sql",                                         # Temporary tables/SPs
    "DDLChangeLog*.sql",                                               # Schema change logs
    "AspNet*.sql", "__EFMigrationsHistory.sql",                        # .NET Identity/EF boilerplate
    "tbl_*.sql",                                                       # Old obsolete table format
    "CheckTable.sql", "*_Hist_*.sql"                                   # Other junk
)

$count = 0
Write-Host "Cleaning up non-core files..." -ForegroundColor Cyan

foreach ($db in @('SmartFactoryV2', 'SmartFramework')) {
    $dbDir = Join-Path $baseDir $db
    if (Test-Path $dbDir) {
        $files = Get-ChildItem -Path $dbDir -Recurse -File
        foreach ($file in $files) {
            $isMatch = $false
            foreach ($pattern in $patternsToMove) {
                if ($file.Name -like $pattern) {
                    $isMatch = $true
                    break
                }
            }

            if ($isMatch) {
                $targetDir = Join-Path $removedDir $file.Directory.Name
                if (!(Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory -Force | Out-Null }
                
                Move-Item -Path $file.FullName -Destination $targetDir -Force
                Write-Host "  Moved: $($file.Name)" -ForegroundColor DarkGray
                $count++
            }
        }
    }
}

Write-Host "`nCleanup Complete! Moved $count non-core files to: $removedDir" -ForegroundColor Green
