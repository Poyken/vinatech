# Step 1: Get existing screen IDs from KB_SCREEN_BUG_REF.md
$existingScreens = @()
$lines = Get-Content -Path "KB_SCREEN_BUG_REF.md" -Encoding UTF8
foreach ($line in $lines) {
    if ($line -match '^## ([A-Z]\d{3})') {
        $existingScreens += $Matches[1]
    }
}
$existingScreens = $existingScreens | Sort-Object -Unique
Write-Host "=== EXISTING SCREENS IN KB_SCREEN_BUG_REF.md ($($existingScreens.Count) total) ==="
$existingScreens | ForEach-Object { Write-Host $_ }

# Step 2: Find ALL screen IDs mentioned across all KB_*.md files (except KB_SCREEN_BUG_REF.md itself)
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
Write-Host ""
Write-Host "=== ALL SCREEN IDS FOUND IN OTHER KB FILES ($($allScreens.Count) total) ==="
$allScreens | ForEach-Object { Write-Host $_ }

# Step 3: Find missing screens
$missing = $allScreens | Where-Object { $existingScreens -notcontains $_ }
Write-Host ""
Write-Host "=== MISSING SCREENS (not in KB_SCREEN_BUG_REF.md) ($($missing.Count) total) ==="
$missing | ForEach-Object { Write-Host $_ }
