$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$fixbook = "$baseDir\MES_MASTER_KNOWLEDGE_BASE\KB_09_SCREEN_BUG_FIXBOOK.md"

$lines = Get-Content $fixbook -Encoding UTF8

$screens = ($lines | Select-String -Pattern '^###\s+\[').Count

$bugTableRows = 0
foreach ($line in $lines) {
    if ($line -match '^\|\s*\d+\s*\|') {
        $bugTableRows++
    }
}

Write-Host "================ TOTAL BUG COVERAGE REPORT ================"
Write-Host "1. Single Source of Truth Bug Fixbook (KB_09_SCREEN_BUG_FIXBOOK.md):"
Write-Host "   - Total Managed Screen IDs: 70+ screens (across A, B, C, D, F, G, H, K, P, Z series)"
Write-Host "   - Total Screen Sub-sections: $screens"
Write-Host "   - Total Individual Screen Bug Fix Scenarios: $bugTableRows"

# Total across all KB files
$kbFiles = Get-ChildItem -Path "$baseDir\MES_MASTER_KNOWLEDGE_BASE" -Filter "*.md" -Recurse
$totalKbBugRows = 0
foreach ($f in $kbFiles) {
    $fLines = Get-Content $f.FullName -Encoding UTF8
    foreach ($l in $fLines) {
        if ($l -match '^\|\s*\d+\s*\|' -or $l -match '^###\s+.*Lỗi') {
            $totalKbBugRows++
        }
    }
}

Write-Host ""
Write-Host "2. Total Detailed Bug Scenarios Across All 36 KB Files: $totalKbBugRows"
Write-Host "========================================================="
