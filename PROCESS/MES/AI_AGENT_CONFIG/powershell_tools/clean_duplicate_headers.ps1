$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$mdFiles = Get-ChildItem -Path $baseDir -Filter "*.md" -Recurse

foreach ($file in $mdFiles) {
    $lines = Get-Content -Path $file.FullName -Encoding UTF8
    $skipIndices = @{}
    $changed = $false
    
    for ($i = 0; $i -lt $lines.Count - 2; $i++) {
        $l1 = $lines[$i].Trim()
        $l3 = $lines[$i + 2].Trim()
        
        if ($l1 -match '^###\s+\[([A-Z0-9]+)\]') {
            $code = $matches[1]
            if ($l3 -match "^###\s+.*\b$code\b") {
                $skipIndices[$i] = $true
                Write-Host "Found duplicate header at line $($i+1) in $($file.Name): '$l1'"
                $changed = $true
            }
        }
    }
    
    if ($changed) {
        $finalLines = @()
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if (-not $skipIndices.ContainsKey($i)) {
                $finalLines += $lines[$i]
            }
        }
        Set-Content -Path $file.FullName -Value $finalLines -Encoding UTF8
        Write-Host "Updated $($file.Name)"
    }
}
