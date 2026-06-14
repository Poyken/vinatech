# Step 1: Get ALL ## headers in KB_SCREEN_BUG_REF.md
Write-Host "=== CURRENT ## HEADERS ==="
$lines = Get-Content -Path "KB_SCREEN_BUG_REF.md" -Encoding UTF8
foreach ($line in $lines) {
    if ($line -match '^## ') {
        Write-Host $line
    }
}

# Step 2: Extract individual screen IDs already covered
Write-Host "`n=== SCREEN IDS ALREADY COVERED (including combined headers) ==="
$covered = @()
foreach ($line in $lines) {
    if ($line -match '^## ') {
        $ids = [regex]::Matches($line, '\b([A-Z]\d{3})\b')
        foreach ($m in $ids) {
            $covered += $m.Groups[1].Value
        }
    }
}
$covered = $covered | Sort-Object -Unique
$covered | ForEach-Object { Write-Host $_ }
Write-Host "Total covered: $($covered.Count)"

# Step 3: Find ALL screen IDs in other KB files
$allScreens = @()
$kbFiles = Get-ChildItem -Path "." -Filter "KB_*.md" | Where-Object { $_.Name -ne "KB_SCREEN_BUG_REF.md" }
foreach ($file in $kbFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $matches2 = [regex]::Matches($content, '\b([A-Z]\d{3})\b')
    foreach ($m in $matches2) {
        $allScreens += $m.Groups[1].Value
    }
}
$allScreens = $allScreens | Sort-Object -Unique
Write-Host "`n=== ALL SCREEN IDS IN KB FILES: $($allScreens.Count) ==="

# Step 4: Screens that DON'T have their own dedicated ## header
# Check which screens appear in combined headers but not as standalone ## ScreenID
$standaloneHeaders = @()
foreach ($line in $lines) {
    if ($line -match '^## ([A-Z]\d{3})\b') {
        $standaloneHeaders += $Matches[1]
    }
}
$standaloneHeaders = $standaloneHeaders | Sort-Object -Unique

$needsOwnHeader = $allScreens | Where-Object { $standaloneHeaders -notcontains $_ }
Write-Host "`n=== SCREENS NEEDING OWN ## HEADER ($($needsOwnHeader.Count) total) ==="
$needsOwnHeader | ForEach-Object { Write-Host $_ }
