$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database'
$archiveDir = Join-Path $baseDir '_AUDIT_ARCHIVE\Duplicates_By_Content'

if (!(Test-Path $archiveDir)) { New-Item -Path $archiveDir -ItemType Directory -Force | Out-Null }

Write-Host "Scanning for CONTENT DUPLICATES across workspace..." -ForegroundColor Cyan

# 1. First, remove the empty "ALL_" aggregate files that failed to populate
Write-Host "  Removing empty aggregate files..."
Get-ChildItem -Path $baseDir -Recurse -Filter "ALL_*.sql" | Where-Object { $_.Length -lt 100 } | Remove-Item -Force

# 2. Get all SQL files (excluding Archive)
$allFiles = Get-ChildItem -Path $baseDir -Recurse -File -Filter "*.sql" | Where-Object { 
    $_.FullName -notmatch '_AUDIT_ARCHIVE' -and 
    $_.FullName -notmatch '\.gemini'
}

$hashTable = @{}
$duplicateCount = 0

# Sort files so that files in 'schema_export' are processed FIRST (to be kept)
$sortedFiles = $allFiles | Sort-Object @{Expression={$_.FullName -match 'schema_export'}; Descending=$true}, @{Expression={$_.LastWriteTime}; Descending=$true}

foreach ($file in $sortedFiles) {
    try {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        
        if ($hashTable.ContainsKey($hash)) {
            # This is a duplicate content!
            $keepFile = $hashTable[$hash]
            
            # If the current file is NOT in schema_export but the keepFile IS, or if both aren't, move the current one
            $targetSubDir = Join-Path $archiveDir $file.Directory.Name
            if (!(Test-Path $targetSubDir)) { New-Item -Path $targetSubDir -ItemType Directory -Force | Out-Null }
            
            Move-Item -Path $file.FullName -Destination $targetSubDir -Force
            Write-Host "  Moved duplicate content: $($file.Name) (Matches $($keepFile.Name))" -ForegroundColor DarkGray
            $duplicateCount++
        } else {
            # First time seeing this content, mark it to keep
            $hashTable[$hash] = $file
        }
    } catch {
        Write-Host "  Error processing $($file.FullName)" -ForegroundColor Red
    }
}

Write-Host "`nContent Cleanup Complete! Moved $duplicateCount duplicate-content files to: $archiveDir" -ForegroundColor Green
