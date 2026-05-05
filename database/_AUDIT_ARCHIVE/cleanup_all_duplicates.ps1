$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database'
$archiveDir = Join-Path $baseDir '_AUDIT_ARCHIVE\Duplicates_By_Content'

if (!(Test-Path $archiveDir)) { New-Item -Path $archiveDir -ItemType Directory -Force | Out-Null }

Write-Host "Scanning for ALL CONTENT DUPLICATES (SQL, PS1, MD, etc.) across workspace..." -ForegroundColor Cyan

# Define extensions to scan
$extensions = @("*.sql", "*.ps1", "*.ps", "*.bat", "*.cmd", "*.md", "*.txt", "*.xml", "*.json")

$allFiles = @()
foreach ($ext in $extensions) {
    $allFiles += Get-ChildItem -Path $baseDir -Recurse -File -Filter $ext | Where-Object { 
        $_.FullName -notmatch '_AUDIT_ARCHIVE' -and 
        $_.FullName -notmatch '\.gemini'
    }
}

$hashTable = @{}
$duplicateCount = 0

# Prioritize: 1. schema_export, 2. Root database, 3. source_from_db, 4. Others
$sortedFiles = $allFiles | Sort-Object `
    @{Expression={$_.FullName -match 'schema_export'}; Descending=$true}, `
    @{Expression={$_.DirectoryName -eq $baseDir}; Descending=$true}, `
    @{Expression={$_.FullName -match 'source_from_db'}; Descending=$true}, `
    @{Expression={$_.LastWriteTime}; Descending=$true}

foreach ($file in $sortedFiles) {
    try {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        
        if ($hashTable.ContainsKey($hash)) {
            $keepFile = $hashTable[$hash]
            
            # Additional check: If it's a script in root we want to keep, don't move it if it's the one we are keeping
            if ($file.FullName -eq $keepFile.FullName) { continue }

            $targetSubDir = Join-Path $archiveDir $file.Directory.Name
            if (!(Test-Path $targetSubDir)) { New-Item -Path $targetSubDir -ItemType Directory -Force | Out-Null }
            
            Move-Item -Path $file.FullName -Destination $targetSubDir -Force
            Write-Host "  Moved duplicate content: $($file.Name) ($($file.Extension)) -> Matches $($keepFile.Name)" -ForegroundColor DarkGray
            $duplicateCount++
        } else {
            $hashTable[$hash] = $file
        }
    } catch {
        Write-Host "  Error processing $($file.FullName)" -ForegroundColor Red
    }
}

Write-Host "`nUniversal Cleanup Complete! Moved $duplicateCount duplicate files to: $archiveDir" -ForegroundColor Green
