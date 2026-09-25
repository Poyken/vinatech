# ==============================================================================
# find_kb.ps1 — 2-Tier Knowledge Base Finder for Vinatech MES Ecosystem
# Tier 1: L1 Ultra-Fast JSON Cache (<0.001s, ~200 tokens)
# Tier 2: Deep Markdown Archive (78+ files)
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Query,
    [ValidateSet('ALL', 'MES', 'POP', 'CONFIG', 'ARCHIVE')]
    [string]$Category = 'ALL',
    [int]$Limit = 15
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 1. TIER 1: KIEM TRA L1 QUICK MATRIX TRUOC
$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$matrixFile = Join-Path $rootDir 'AI_AGENT_CONFIG\QUICK_MATRIX.json'
$foundInL1 = $false

if (Test-Path $matrixFile) {
    try {
        $matrixJson = Get-Content -Path $matrixFile -Encoding UTF8 -Raw | ConvertFrom-Json
        $qUpper = $Query.ToUpper().Trim()

        # 1.1 Match Chinh Xac Screen ID
        if ($matrixJson.screens.$qUpper) {
            $sc = $matrixJson.screens.$qUpper
            Write-Host ''
            Write-Host '======================================================================' -ForegroundColor Green
            Write-Host ('  [L1 CACHE HIT] MAN HINH: ' + $qUpper + ' - ' + $sc.name) -ForegroundColor Yellow
            Write-Host '======================================================================' -ForegroundColor Green
            Write-Host ('  * Module      : ' + $sc.module) -ForegroundColor White
            Write-Host ('  * SP Search   : ' + $sc.sp_get) -ForegroundColor Cyan
            Write-Host ('  * SP Process  : ' + $sc.sp_iud) -ForegroundColor Cyan
            Write-Host ('  * Bang CSDL   : ' + ($sc.tables -join ', ')) -ForegroundColor Yellow
            Write-Host '  * Cac loi thuong gap:' -ForegroundColor White
            foreach ($prop in $sc.common_bugs.PSObject.Properties) {
                Write-Host ('    - ' + $prop.Name + ' : ' + $prop.Value) -ForegroundColor Gray
            }
            if ($sc.fix_template) {
                Write-Host ('  * Hotfix Mau  : ' + $sc.fix_template) -ForegroundColor Green
            }
            Write-Host '======================================================================' -ForegroundColor Green
            $foundInL1 = $true
        } else {
            # 1.2 Match Theo Trieu Chung / Tu Khoa trong L1
            $matchedScreens = @()
            foreach ($prop in $matrixJson.screens.PSObject.Properties) {
                $sCode = $prop.Name
                $sc = $prop.Value
                $hit = $false
                $hitReason = ''

                if ($sc.name -match "(?i)$([regex]::Escape($Query))") {
                    $hit = $true
                    $hitReason = "Ten man hinh: $($sc.name)"
                } else {
                    foreach ($bProp in $sc.common_bugs.PSObject.Properties) {
                        if ($bProp.Name -match "(?i)$([regex]::Escape($Query))" -or $bProp.Value -match "(?i)$([regex]::Escape($Query))") {
                            $hit = $true
                            $hitReason = "Loi: $($bProp.Name) -> $($bProp.Value)"
                            break
                        }
                    }
                }

                if ($hit) {
                    $matchedScreens += [PSCustomObject]@{
                        Code    = $sCode
                        Name    = $sc.name
                        Module  = $sc.module
                        SP      = $sc.sp_iud
                        Reason  = $hitReason
                        Fix     = $sc.fix_template
                    }
                }
            }

            if ($matchedScreens.Count -gt 0) {
                Write-Host ''
                Write-Host '======================================================================' -ForegroundColor Green
                Write-Host ('  [L1 CACHE HIT] TIM THAY ' + $matchedScreens.Count + " MAN HINH KHOP TRIEU CHUNG: '$Query'") -ForegroundColor Yellow
                Write-Host '======================================================================' -ForegroundColor Green
                foreach ($ms in ($matchedScreens | Select-Object -First 5)) {
                    Write-Host ('  [' + $ms.Code + '] ' + $ms.Name + ' (Module: ' + $ms.Module + ')') -ForegroundColor Cyan
                    Write-Host ('    * Chi tiet : ' + $ms.Reason) -ForegroundColor Gray
                    if ($ms.Fix) { Write-Host ('    * SQL Fix  : ' + $ms.Fix) -ForegroundColor Green }
                }
                Write-Host '======================================================================' -ForegroundColor Green
                $foundInL1 = $true
            }
        }

        # 1.2b Match Historical Precedents (Tien Le Van Hanh)
        if ($matrixJson.historical_precedents) {
            $matchedPrecedents = @()
            foreach ($pProp in $matrixJson.historical_precedents.PSObject.Properties) {
                $pCode = $pProp.Name
                $pObj = $pProp.Value
                if ($pCode -match "(?i)$([regex]::Escape($Query))" -or 
                    $pObj.title -match "(?i)$([regex]::Escape($Query))" -or 
                    $pObj.description -match "(?i)$([regex]::Escape($Query))" -or 
                    $pObj.screen -match "(?i)$([regex]::Escape($Query))" -or 
                    $pObj.solution -match "(?i)$([regex]::Escape($Query))") {
                    $matchedPrecedents += [PSCustomObject]@{
                        Code        = $pCode
                        Title       = $pObj.title
                        Screen      = $pObj.screen
                        Description = $pObj.description
                        Solution    = $pObj.solution
                        Tables      = ($pObj.tables -join ', ')
                    }
                }
            }
            if ($matchedPrecedents.Count -gt 0) {
                Write-Host ''
                Write-Host '======================================================================' -ForegroundColor Magenta
                Write-Host ('  [L1 PRECEDENT HIT] TIM THAY ' + $matchedPrecedents.Count + " TIEN LE VAN HANH: '$Query'") -ForegroundColor Yellow
                Write-Host '======================================================================' -ForegroundColor Magenta
                foreach ($mp in ($matchedPrecedents | Select-Object -First 3)) {
                    Write-Host ('  [' + $mp.Code + '] ' + $mp.Title + ' (Screen: ' + $mp.Screen + ')') -ForegroundColor Cyan
                    Write-Host ('    * Mo Ta     : ' + $mp.Description) -ForegroundColor Gray
                    Write-Host ('    * Bang CSDL : ' + $mp.Tables) -ForegroundColor Yellow
                    Write-Host ('    * Giai Phap : ' + $mp.Solution) -ForegroundColor Green
                }
                Write-Host '======================================================================' -ForegroundColor Magenta
                $foundInL1 = $true
            }
        }
    } catch {}
}

# 1.3 KIEM TRA L1 POP MATRIX (Line, Route, Top Error)
$popMatrixFile = Join-Path $rootDir 'AI_AGENT_CONFIG\POP_MATRIX.json'
if (Test-Path $popMatrixFile) {
    try {
        $popJson = Get-Content -Path $popMatrixFile -Encoding UTF8 -Raw | ConvertFrom-Json
        $qUpper = $Query.ToUpper().Trim()

        # Match Line Code
        if ($popJson.lines.$qUpper) {
            $ln = $popJson.lines.$qUpper
            Write-Host ''
            Write-Host '======================================================================' -ForegroundColor Green
            Write-Host ('  [L1 POP HIT] DAY CHUYEN: ' + $qUpper + ' (' + $ln.factory + ') - TRANG THAI: ' + $ln.status) -ForegroundColor Yellow
            Write-Host '======================================================================' -ForegroundColor Green
            Write-Host ('  * Che Do Nap  : ' + $ln.input_mode + ' | Che Do SX: ' + $ln.prod_mode) -ForegroundColor White
            Write-Host ('  * So Slot NVL : ' + $ln.total_slots + ' slots (W:' + $ln.winding_slots + ' A:' + $ln.assembly_slots + ' S:' + $ln.sleeving_slots + ')') -ForegroundColor Cyan
            Write-Host ('  * Ghi Chu     : ' + $ln.note) -ForegroundColor (if ($ln.status -eq 'PASS') { 'Green' } else { 'Yellow' })
            Write-Host ('  * CLI Hub     : .\mes.ps1 pop-readiness -Target ' + $qUpper) -ForegroundColor Gray
            Write-Host '======================================================================' -ForegroundColor Green
            $foundInL1 = $true
        }
        # Match Top Error
        elseif ($popJson.top_errors.$qUpper) {
            $err = $popJson.top_errors.$qUpper
            Write-Host ''
            Write-Host '======================================================================' -ForegroundColor Red
            Write-Host ('  [L1 POP ERROR HIT] ' + $qUpper + ': ' + $err.title) -ForegroundColor Yellow
            Write-Host '======================================================================' -ForegroundColor Red
            Write-Host ('  * Nguyen Nhan : ' + $err.root_cause) -ForegroundColor White
            Write-Host ('  * Cach Xu Ly  : ' + $err.fast_fix) -ForegroundColor Green
            Write-Host '======================================================================' -ForegroundColor Red
            $foundInL1 = $true
        }
        else {
            # Match Top Error theo trieu chung / tu khoa
            $matchedPopErrors = @()
            foreach ($prop in $popJson.top_errors.PSObject.Properties) {
                $eCode = $prop.Name
                $eObj = $prop.Value
                if ($eCode -match "(?i)$([regex]::Escape($Query))" -or $eObj.title -match "(?i)$([regex]::Escape($Query))" -or $eObj.root_cause -match "(?i)$([regex]::Escape($Query))" -or $eObj.fast_fix -match "(?i)$([regex]::Escape($Query))") {
                    $matchedPopErrors += [PSCustomObject]@{
                        Code  = $eCode
                        Title = $eObj.title
                        Cause = $eObj.root_cause
                        Fix   = $eObj.fast_fix
                    }
                }
            }
            if ($matchedPopErrors.Count -gt 0) {
                Write-Host ''
                Write-Host '======================================================================' -ForegroundColor Red
                Write-Host ('  [L1 POP ERROR HIT] TIM THAY ' + $matchedPopErrors.Count + " MA LOI POP KHOP TRIEU CHUNG: '$Query'") -ForegroundColor Yellow
                Write-Host '======================================================================' -ForegroundColor Red
                foreach ($me in ($matchedPopErrors | Select-Object -First 3)) {
                    Write-Host ('  [' + $me.Code + '] ' + $me.Title) -ForegroundColor Cyan
                    Write-Host ('    * Nguyen Nhan: ' + $me.Cause) -ForegroundColor White
                    Write-Host ('    * Cach Xu Ly : ' + $me.Fix) -ForegroundColor Green
                }
                Write-Host '======================================================================' -ForegroundColor Red
                $foundInL1 = $true
            }

            # Match Route
            foreach ($prop in $popJson.routes.PSObject.Properties) {
                $rPath = $prop.Name
                $rObj = $prop.Value
                if ($rPath -like "*$Query*" -or $rObj.name -match "(?i)$([regex]::Escape($Query))") {
                    Write-Host ''
                    Write-Host '======================================================================' -ForegroundColor Green
                    Write-Host ('  [L1 POP ROUTE HIT] ' + $rPath + ' - ' + $rObj.name) -ForegroundColor Yellow
                    Write-Host '======================================================================' -ForegroundColor Green
                    Write-Host ('  * Mo ta       : ' + $rObj.description) -ForegroundColor White
                    Write-Host ('  * Bang CSDL   : ' + ($rObj.tables -join ', ')) -ForegroundColor Cyan
                    Write-Host ('  * Tuong duong : ' + ($rObj.equivalent_winform -join ', ')) -ForegroundColor Gray
                    Write-Host '======================================================================' -ForegroundColor Green
                    $foundInL1 = $true
                    break
                }
            }
        }
    } catch {}
}

# 2. TIER 2: QUET DEEP MARKDOWN ARCHIVE
$targetDirs = @()
switch ($Category) {
    'MES'     { $targetDirs += Join-Path $rootDir 'MES_MASTER_KNOWLEDGE_BASE' }
    'POP'     { $targetDirs += Join-Path $rootDir 'POP_KNOWLEDGE_BASE' }
    'CONFIG'  { $targetDirs += Join-Path $rootDir 'AI_AGENT_CONFIG' }
    'ARCHIVE' { 
        $ext = 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS_ARCHIVE_BACKUP'
        if (Test-Path $ext) { $targetDirs += $ext }
    }
    'ALL'     { 
        $targetDirs += Join-Path $rootDir 'MES_MASTER_KNOWLEDGE_BASE'
        $targetDirs += Join-Path $rootDir 'POP_KNOWLEDGE_BASE'
        $targetDirs += Join-Path $rootDir 'AI_AGENT_CONFIG'
    }
    default   {
        $targetDirs += Join-Path $rootDir 'MES_MASTER_KNOWLEDGE_BASE'
        $targetDirs += Join-Path $rootDir 'POP_KNOWLEDGE_BASE'
        $targetDirs += Join-Path $rootDir 'AI_AGENT_CONFIG'
    }
}

$files = @()
foreach ($dir in $targetDirs) {
    if (Test-Path $dir) {
        $files += Get-ChildItem -Path $dir -Filter '*.md' -Recurse
    }
}

if (-not $foundInL1) {
    Write-Host ''
    Write-Host ('(*) DANG TRA CUU TRI THUC CHO TU KHOA: ' + "'$Query'" + ' (Phan loai: ' + $Category + ', Tong file quet: ' + $files.Count + ')...') -ForegroundColor Cyan
    Write-Host ''
}

$totalMatches = 0
$fileMatchDict = [ordered]@{}

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $relPath = $file.FullName.Replace($PSScriptRoot, '.').Replace('\', '/')
    $lines = @()
    $lineNo = 0
    $currentHeader = ''

    foreach ($line in $content) {
        $lineNo++
        if ($line -match '^#+\s+(.+)') {
            $currentHeader = $matches[1]
        }
        if ($line -match "(?i)$([regex]::Escape($Query))") {
            $lines += [PSCustomObject]@{
                LineNo = $lineNo
                Header = $currentHeader
                Text   = $line.Trim()
            }
        }
    }

    if ($lines.Count -gt 0) {
        $fileMatchDict[$relPath] = $lines
    }
}

$shownCount = 0
foreach ($relPath in $fileMatchDict.Keys) {
    if ($shownCount -ge $Limit) { break }

    Write-Host ('File: ' + $relPath) -ForegroundColor Green
    foreach ($m in $fileMatchDict[$relPath]) {
        if ($shownCount -ge $Limit) { break }
        $hdr = if ($m.Header) { ' [' + $m.Header + ']' } else { '' }
        $dispText = if ($m.Text.Length -gt 100) { $m.Text.Substring(0, 97) + '...' } else { $m.Text }
        Write-Host ('   Line ' + $m.LineNo + $hdr) -ForegroundColor Yellow
        Write-Host ('   -> ' + $dispText) -ForegroundColor Gray
        $shownCount++
    }
    Write-Host ''
}

$totalMatches = ($fileMatchDict.Values | Measure-Object -Property Count -Sum).Sum
if ($totalMatches -eq 0 -and -not $foundInL1) {
    Write-Host ('(-) Khong tim thay ket qua nao phu hop voi ' + "'$Query'" + ' trong ' + $Category + '.') -ForegroundColor Red
} elseif ($totalMatches -gt 0) {
    Write-Host '----------------------------------------------------------------------' -ForegroundColor Gray
    Write-Host ('Tim thay ' + $totalMatches + ' ket qua phu hop trong Markdown Archive. (Toi da hien thi: ' + $Limit + ')') -ForegroundColor Cyan
}
