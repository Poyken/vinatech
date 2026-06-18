<# 
  search_kb.ps1 - Tim kiem thong minh trong KB
  
  Cach dung:
    .\search_kb.ps1 "gop box"         → Tim file nao chua CA HAI tu "gop" VA "box"
    .\search_kb.ps1 "B523 loi"        → Tim file chua "B523" VA "loi"  
    .\search_kb.ps1 "trigger kho"     → Tim file chua "trigger" VA "kho"
    .\search_kb.ps1 "SetInfo"         → Tim file chua "SetInfo"
#>

param([string]$SearchTerms)

if (-not $SearchTerms) {
    Write-Host "Cach dung: .\search_kb.ps1 `"tu khoa 1 tu khoa 2`"" -ForegroundColor Yellow
    Write-Host "Vi du:     .\search_kb.ps1 `"gop box loi`"" -ForegroundColor Yellow
    exit
}

$kbDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$words = $SearchTerms.Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)

Write-Host "`n=== TIM KIEM KB: [$($words -join ' + ')] ===" -ForegroundColor Cyan
Write-Host ""

$results = @()

Get-ChildItem "$kbDir\KB_*.md" | ForEach-Object {
    $file = $_
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check if ALL words are found in the file
    $allFound = $true
    foreach ($w in $words) {
        if ($content -notmatch [regex]::Escape($w)) {
            $allFound = $false
            break
        }
    }
    
    if ($allFound) {
        # Find matching lines for context
        $lines = Get-Content $file.FullName -Encoding UTF8
        $matchLines = @()
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            $lineMatch = $true
            foreach ($w in $words) {
                if ($line -notmatch [regex]::Escape($w)) {
                    $lineMatch = $false
                    # Check if ANY word matches (for context)
                    $anyMatch = $false
                    foreach ($w2 in $words) {
                        if ($line -match [regex]::Escape($w2)) { $anyMatch = $true; break }
                    }
                    if (-not $anyMatch) { $lineMatch = $false }
                    break
                }
            }
            # Show lines that contain at least one search word
            $hasAny = $false
            foreach ($w in $words) {
                if ($line -match [regex]::Escape($w)) { $hasAny = $true; break }
            }
            if ($hasAny -and $line.Trim().Length -gt 5) {
                $matchLines += [PSCustomObject]@{ LineNum = ($i + 1); Text = $line.Trim().Substring(0, [Math]::Min(120, $line.Trim().Length)) }
            }
        }
        
        $results += [PSCustomObject]@{
            File = $file.Name
            Lines = $matchLines
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "Khong tim thay ket qua. Thu voi tu khoa khac." -ForegroundColor Red
} else {
    Write-Host "Tim thay $($results.Count) file:" -ForegroundColor Green
    Write-Host ""
    
    foreach ($r in $results) {
        Write-Host "  $($r.File)" -ForegroundColor Yellow
        $shown = 0
        foreach ($ml in $r.Lines) {
            if ($shown -ge 5) { 
                Write-Host "      ... (con $($r.Lines.Count - 5) dong nua)" -ForegroundColor DarkGray
                break 
            }
            Write-Host "      L$($ml.LineNum): $($ml.Text)" -ForegroundColor Gray
            $shown++
        }
        Write-Host ""
    }
}
