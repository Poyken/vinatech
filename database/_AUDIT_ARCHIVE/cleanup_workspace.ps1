$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database'
$removedDir = Join-Path $baseDir '_Removed_NonCore_Workspace'

if (!(Test-Path $removedDir)) { New-Item -Path $removedDir -ItemType Directory -Force | Out-Null }

$patternsToMove = @(
    # Old Date Backups (SQL, TXT, MD)
    "*_201*.*", "*_202*.*", "*_21*.sql", "*_22*.sql", "*_23*.sql",
    
    # Test, Backup, Temp
    "*_test*.*", "*_backup*.*", "*_bak*.*", "*_back*.*", "*temp*.*", "*tmp*.*",
    
    # Obsolete tables and system tables
    "DDLChangeLog*.*", "AspNet*.*", "__EFMigrationsHistory.*", "tbl_*.*", "CheckTable.*", "*_Hist_*.*"
)

$count = 0
Write-Host "Scanning ENTIRE WORKSPACE for non-core files..." -ForegroundColor Cyan

# Recursively get all files but exclude the Removed directories
$files = Get-ChildItem -Path $baseDir -Recurse -File | Where-Object { 
    $_.DirectoryName -notmatch '_Removed_NonCore' -and 
    $_.DirectoryName -notmatch '\.gemini' -and
    $_.DirectoryName -notmatch '\.git'
}

foreach ($file in $files) {
    $isMatch = $false
    foreach ($pattern in $patternsToMove) {
        if ($file.Name -like $pattern) {
            # Extra safety: Don't move specific files we know are good even if they match (like meeting notes 202*?)
            if ($file.Name -match "^Meeting_.*202") { continue }
            if ($file.Name -match "^Checklist_.*") { continue }
            
            $isMatch = $true
            break
        }
    }

    if ($isMatch) {
        # Preserve directory structure inside the removed folder
        $relativePath = $file.DirectoryName.Substring($baseDir.Length).TrimStart('\')
        $targetDir = Join-Path $removedDir $relativePath
        if (!(Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory -Force | Out-Null }
        
        Move-Item -Path $file.FullName -Destination $targetDir -Force
        Write-Host "  Moved: $($file.Name) (from $relativePath)" -ForegroundColor DarkGray
        $count++
    }
}

Write-Host "`nWorkspace Cleanup Complete! Moved $count non-core files to: $removedDir" -ForegroundColor Green
