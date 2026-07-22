$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$mdFiles = Get-ChildItem -Path $baseDir -Filter "*.md" -Recurse

Write-Host "================ WORKSPACE REDUNDANCY AUDIT ================"

foreach ($file in $mdFiles) {
    $lines = Get-Content -Path $file.FullName -Encoding UTF8
    $relPath = $file.FullName.Substring($baseDir.Length + 1)
    
    # 1. Check duplicate headers
    $headers = @{}
    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        if ($line -match '^(#+)\s+(.+)$') {
            $hText = $matches[2].Trim()
            if ($headers.ContainsKey($hText)) {
                Write-Host "[DUPLICATE HEADER] $relPath (L$lineNum): '$hText' (First seen L$($headers[$hText]))"
            } else {
                $headers[$hText] = $lineNum
            }
        }
    }
    
    # 2. Check obsolete KB references
    $obsoleteKBs = @("KB_14", "KB_19", "KB_25", "KB_26", "KB_31", "KB_32", "KB_33", "KB_36", "KB_37")
    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        foreach ($obs in $obsoleteKBs) {
            if ($line -match "\b$obs\b") {
                Write-Host "[OBSOLETE KB REF] $relPath (L$lineNum): '$obs' -> $line"
            }
        }
    }
}

Write-Host "================ AUDIT COMPLETE ================"
