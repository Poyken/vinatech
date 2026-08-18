param (
    [Parameter(Mandatory=$true)]
    [string]$TCode,
    [Parameter(Mandatory=$true)]
    [string]$Symptom,
    [Parameter(Mandatory=$true)]
    [string]$Cause,
    [Parameter(Mandatory=$true)]
    [string]$SQLPatch,
    [string]$ReferenceKB = ""
)

# 1. Get workspace paths
$mesRoot = $PSScriptRoot
$bootstrapPath = Join-Path $mesRoot "AI_AGENT_CONFIG\BOOTSTRAP.md"
$hotfixLogPath = Join-Path $mesRoot "AI_AGENT_CONFIG\HOTFIX_LOG.md"
$fixbookPath = Join-Path $mesRoot "MES_MASTER_KNOWLEDGE_BASE\KB_09_SCREEN_BUG_FIXBOOK.md"
$kbIndexPath = Join-Path $mesRoot "MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md"

# 2. Get Next Hotfix ID and update BOOTSTRAP.md
$hotfixId = "UNKNOWN"
if (Test-Path $bootstrapPath) {
    $bootstrapContent = [System.IO.File]::ReadAllText($bootstrapPath, [System.Text.Encoding]::UTF8)
    if ($bootstrapContent -match '-\s+\*\*Hotfix\s+ti.p\s+theo:\*\*\s+ID\s+=\s+\*\*(\d+)\*\*') {
        $hotfixId = $Matches[1]
        $nextId = [int]$hotfixId + 1
        $oldLine = $Matches[0]
        $newLine = $oldLine -replace '\d+', $nextId
        $updatedBootstrap = $bootstrapContent.Replace($oldLine, $newLine)
        [System.IO.File]::WriteAllText($bootstrapPath, $updatedBootstrap, [System.Text.Encoding]::UTF8)
        Write-Host "[OK] Incremented Next Hotfix ID to $nextId in BOOTSTRAP.md" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Could not find 'Hotfix ti.p theo' pattern in BOOTSTRAP.md" -ForegroundColor Yellow
    }
}

# 3. Retrieve Screen Name
$screenName = "Chua xac dinh"
if (Test-Path $kbIndexPath) {
    $indexContent = Get-Content $kbIndexPath -Encoding UTF8
    foreach ($line in $indexContent) {
        if ($line -match "\|\s*$TCode\s*\|\s*\*\*([^\*]+)\*\*") {
            $screenName = $Matches[1].Trim()
            break
        }
    }
}
Write-Host ("[INFO] Screen Name identified for " + $TCode + ": " + $screenName) -ForegroundColor Cyan

# 4. Append entry to AI_AGENT_CONFIG/HOTFIX_LOG.md
if (Test-Path $hotfixLogPath) {
    $today = Get-Date -Format "yyyy-MM-dd"
    $cleanSqlPatch = $SQLPatch.Trim()
    
    $logContent = [System.IO.File]::ReadAllText($hotfixLogPath, [System.Text.Encoding]::UTF8)
    # Match the placeholder using dots to avoid raw accented characters
    $placeholder = "\*\(Ch.a c. b.n ghi m.i trong phi.n n.y.*H.y b.t d.u ghi ch.p.*!\)\*"
    if ($logContent -match $placeholder) {
        $logContent = $logContent -replace $placeholder, ""
    }
    
    $shortSymptom = if ($Symptom.Length -gt 60) { $Symptom.SubString(0, 60) + "..." } else { $Symptom }
    $pin = [char]0xD83D + [char]0xDCCD
    
    $newEntry = "`n### " + $pin + " ID_" + $hotfixId + " - " + $TCode + " - " + $shortSymptom + "`n" +
                '* **Ngay sua:** `' + $today + '`' + "`n" +
                '* **Man hinh lien quan (TCode):** `' + $TCode + ' - ' + $screenName + '`' + "`n" +
                '* **Trieu chung loi:** ' + $Symptom + "`n" +
                '* **Nguyen nhan goc (Root Cause):** ' + $Cause + "`n" +
                "* **Phuong an sua loi (SQL Patch / Action):**`n" +
                '  ```sql' + "`n" +
                $cleanSqlPatch + "`n" +
                '  ```'
                
    if ($ReferenceKB) {
        $newEntry += "`n* **Tham chieu KB:** $ReferenceKB"
    }
    $newEntry += "`n"
    
    [System.IO.File]::WriteAllText($hotfixLogPath, $logContent + $newEntry, [System.Text.Encoding]::UTF8)
    Write-Host "[OK] Added entry ID_$hotfixId to HOTFIX_LOG.md" -ForegroundColor Green
}

# 5. Insert entry into KB_09_SCREEN_BUG_FIXBOOK.md
if (Test-Path $fixbookPath) {
    $fixbookLines = [System.Collections.Generic.List[string]]::new()
    $fixbookLines.AddRange([System.IO.File]::ReadAllLines($fixbookPath, [System.Text.Encoding]::UTF8))
    
    $foundTCodeHeader = $false
    $headerIndex = -1
    $tableStartIndex = -1
    $lastRowIndex = -1
    
    # Try to locate the TCode section
    for ($i = 0; $i -lt $fixbookLines.Count; $i++) {
        $line = $fixbookLines[$i]
        if ($line -match "^###\s+$TCode\b") {
            $foundTCodeHeader = $true
            $headerIndex = $i
            continue
        }
        if ($foundTCodeHeader) {
            if ($line -match "^##") {
                break
            }
            # Search using wildcard characters to avoid accented compilation issues
            if ($line -match "^\|\s*#\s*\|\s*Tri.u ch.ng") {
                $tableStartIndex = $i + 2
                continue
            }
            if ($tableStartIndex -ne -1 -and $line -match "^\|\s*\d+\s*\|") {
                $lastRowIndex = $i
            }
        }
    }
    
    $cleanSymptom = $Symptom.Replace("|", "I").Replace("`n", " ").Replace("`r", " ").Trim()
    $cleanCause = $Cause.Replace("|", "I").Replace("`n", " ").Replace("`r", " ").Trim()
    $cleanPatch = $SQLPatch.Replace("|", "I").Replace("`r`n", " ").Replace("`n", " ").Replace("`r", " ").Replace("  ", " ").Trim()
    if ($cleanPatch.Length -gt 150) {
        $cleanPatch = $cleanPatch.SubString(0, 150) + "..."
    }
    $cleanPatch = "``$cleanPatch``"
    
    if ($foundTCodeHeader -and $tableStartIndex -ne -1) {
        $nextRowId = 1
        if ($lastRowIndex -ne -1) {
            $lastRow = $fixbookLines[$lastRowIndex]
            if ($lastRow -match "^\|\s*(\d+)\s*\|") {
                $nextRowId = [int]$Matches[1] + 1
            }
            $insertAt = $lastRowIndex + 1
        } else {
            $insertAt = $tableStartIndex
        }
        
        $newTableRow = "| $nextRowId | $cleanSymptom | $cleanCause | $cleanPatch |"
        $fixbookLines.Insert($insertAt, $newTableRow)
        [System.IO.File]::WriteAllLines($fixbookPath, $fixbookLines, [System.Text.Encoding]::UTF8)
        Write-Host "[OK] Inserted hotfix into existing TCode section $TCode in KB_09" -ForegroundColor Green
    } else {
        Write-Host "[INFO] TCode section $TCode not found in KB_09. Creating it..." -ForegroundColor Cyan
        $seriesPrefix = $TCode.SubString(0, 1).ToUpper()
        
        $seriesHeadingPattern = ""
        switch ($seriesPrefix) {
            "A" { $seriesHeadingPattern = "^## A-Series:" }
            "B" { $seriesHeadingPattern = "^## B-Series:" }
            "C" { $seriesHeadingPattern = "^## C-Series:" }
            "D" { $seriesHeadingPattern = "^## D-Series:" }
            "F" { $seriesHeadingPattern = "^## F-Series:" }
            "G" { $seriesHeadingPattern = "^## G-Series:" }
            "H" { $seriesHeadingPattern = "^## H-Series:" }
            "K" { $seriesHeadingPattern = "^## K-Series:" }
            "P" { $seriesHeadingPattern = "^## P-Series:" }
            "Z" { $seriesHeadingPattern = "^## Z-Series:" }
            Default { $seriesHeadingPattern = "^## Bugs C" }
        }
        
        $seriesIndex = -1
        for ($i = 0; $i -lt $fixbookLines.Count; $i++) {
            if ($fixbookLines[$i] -match $seriesHeadingPattern) {
                $seriesIndex = $i
                break
            }
        }
        
        if ($seriesIndex -eq -1) {
            $seriesIndex = $fixbookLines.Count - 1
        }
        
        $insertAt = -1
        for ($i = $seriesIndex + 1; $i -lt $fixbookLines.Count; $i++) {
            if ($fixbookLines[$i] -match "^##\s+") {
                $insertAt = $i
                break
            }
        }
        if ($insertAt -eq -1) {
            $insertAt = $fixbookLines.Count
        }
        
        $newSection = @(
            ""
            "### $TCode"
            "**Ten:** $screenName"
            ""
            "| # | Trieu chung | Nguyen nhan | Fix |"
            "|---|---|---|---|"
            "| 1 | $cleanSymptom | $cleanCause | $cleanPatch |"
        )
        
        $idx = $insertAt
        foreach ($line in $newSection) {
            $fixbookLines.Insert($idx, $line)
            $idx++
        }
        [System.IO.File]::WriteAllLines($fixbookPath, $fixbookLines, [System.Text.Encoding]::UTF8)
        Write-Host "[OK] Created new TCode section and added hotfix to KB_09" -ForegroundColor Green
    }
}

