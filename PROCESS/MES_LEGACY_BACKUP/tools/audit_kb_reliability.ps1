# ==============================================================================
# audit_kb_reliability.ps1 — Automated KB Reliability & Schema Drift Auditor
# Kiem tra do tin cay cua toan bo tai lieu trong source vs CSDL Thuc te
# ==============================================================================

param(
    [switch]$ExportReport = $true
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$scriptDir = $rootDir
. (Join-Path $PSScriptRoot 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '     VINATECH MES - AUTOMATED KB RELIABILITY & DRIFT AUDITOR' -ForegroundColor Yellow
Write-Host ('Thoi gian chay: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''

# 1. KET NOI & THU THAP SCHEMA TU CAC CO SO DU LIEU LIVE
Write-Host '1. DANG THU THAP SCHEMA THUC TE TU CAC CSDL...' -ForegroundColor Cyan

$dbObjects = @{
    Tables = @{}
    SPs    = @{}
}

$scanProfiles = @('SmartFactoryV2', 'SmartFramework', 'Groupware', 'POP', 'Andon')

foreach ($pName in $scanProfiles) {
    $conn = Get-DbConnection -Profile $pName -Silent -ConnectTimeoutSeconds 5
    if ($conn -ne $null) {
        $dbName = $conn.Database
        Write-Host ('  [OK] Dang doc metadata tu CSDL: ' + $dbName.PadRight(18) + ' (Profile: ' + $pName + ')') -ForegroundColor Green
        
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = 30
            $cmd.CommandText = 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES'
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $tName = $rdr.GetString(0).ToUpper()
                if (-not $dbObjects.Tables.ContainsKey($tName)) {
                    $dbObjects.Tables[$tName] = @()
                }
                $dbObjects.Tables[$tName] += $dbName
            }
            $rdr.Close()

            $cmd.CommandText = "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE'"
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $spName = $rdr.GetString(0).ToUpper()
                if (-not $dbObjects.SPs.ContainsKey($spName)) {
                    $dbObjects.SPs[$spName] = @()
                }
                $dbObjects.SPs[$spName] += $dbName
            }
            $rdr.Close()
        } catch {
            Write-Host ('  [WARN] Khong the doc day du metadata tu ' + $dbName + ': ' + $_) -ForegroundColor Yellow
        } finally {
            $conn.Close()
        }
    } else {
        Write-Host ('  [FAIL] Khong the ket noi toi CSDL profile: ' + $pName) -ForegroundColor Red
    }
}

Write-Host ('-> Tong so Bieu bang thuc te tim thay: ' + $dbObjects.Tables.Count) -ForegroundColor Green
Write-Host ('-> Tong so Stored Procedure thuc te tim thay: ' + $dbObjects.SPs.Count) -ForegroundColor Green
Write-Host ''

# 2. QUET TOAN BO TAI LIEU MARKDOWN TRONG SOURCE
Write-Host '2. DANG PHAN TICH & DOI SOAT TAI LIEU TRONG SOURCE...' -ForegroundColor Cyan

$kbDirs = @(
    (Join-Path $scriptDir 'MES_MASTER_KNOWLEDGE_BASE'),
    (Join-Path $scriptDir 'DATABASE_KNOWLEDGE_BASE'),
    (Join-Path $scriptDir 'GROUPWARE_KNOWLEDGE_BASE'),
    (Join-Path $scriptDir 'SYSTEM_ARCHITECTURE'),
    (Join-Path $scriptDir 'AI_AGENT_CONFIG')
)

$kbFiles = @()
foreach ($d in $kbDirs) {
    if (Test-Path $d) {
        $kbFiles += Get-ChildItem -Path $d -Filter '*.md' -Recurse
    }
}
$kbFiles += Get-ChildItem -Path $scriptDir -Filter '*.md' -File

$auditResults = @()
$totalEntitiesMentioned = 0
$totalEntitiesVerified = 0

foreach ($file in $kbFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $fullText = $content -join "`n"

    $relPath = $file.FullName.Replace($scriptDir, '.').Replace('\', '/')

    # Extract Tables
    $tables = @()
    $tMatches = [regex]::Matches($fullText, '\b(?:STB|VVT|GW|DZ|POP|Andon)_[a-zA-Z0-9_]+\b')
    foreach ($m in $tMatches) { $tables += $m.Value }
    $tables = $tables | Select-Object -Unique

    # Extract SPs
    $sps = @()
    $spMatches = [regex]::Matches($fullText, '\b[uU][sS][pP]_[a-zA-Z0-9_]+\b')
    foreach ($m in $spMatches) { $sps += $m.Value }
    $sps = $sps | Select-Object -Unique

    $fileEntities = $tables.Count + $sps.Count
    if ($fileEntities -eq 0) { continue }

    $verifiedTables = @()
    $unverifiedTables = @()
    foreach ($t in $tables) {
        $tUpper = $t.ToUpper()
        if ($dbObjects.Tables.ContainsKey($tUpper)) {
            $verifiedTables += @{ Name = $t; DBs = ($dbObjects.Tables[$tUpper] -join ', ') }
        } else {
            $unverifiedTables += $t
        }
    }

    $verifiedSPs = @()
    $unverifiedSPs = @()
    foreach ($sp in $sps) {
        $spUpper = $sp.ToUpper()
        if ($dbObjects.SPs.ContainsKey($spUpper)) {
            $verifiedSPs += @{ Name = $sp; DBs = ($dbObjects.SPs[$spUpper] -join ', ') }
        } else {
            $unverifiedSPs += $sp
        }
    }

    $verifiedCount = $verifiedTables.Count + $verifiedSPs.Count
    $score = [math]::Round(($verifiedCount / $fileEntities) * 100, 1)

    $status = 'HIGH'
    if ($score -lt 70) {
        $status = 'LOW'
    } elseif ($score -lt 90) {
        $status = 'MEDIUM'
    }

    $auditResults += [PSCustomObject]@{
        FilePath         = $relPath
        TotalTables      = $tables.Count
        VerifiedTables   = $verifiedTables.Count
        TotalSPs         = $sps.Count
        VerifiedSPs      = $verifiedSPs.Count
        ReliabilityScore = $score
        Status           = $status
        UnverifiedTables = $unverifiedTables
        UnverifiedSPs    = $unverifiedSPs
    }

    $totalEntitiesMentioned += $fileEntities
    $totalEntitiesVerified += $verifiedCount
}

# 3. HIEN THI KET QUA AUDIT
Write-Host ''
Write-Host '======================================================================' -ForegroundColor Yellow
Write-Host '                    KET QUA AUDIT DO TIN CAY TAI LIEU' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Yellow
Write-Host ('{0,-50} | {1,-7} | {2,-7} | {3,-10} | {4}' -f 'Ten File Tai Lieu', 'Tables', 'SPs', 'Do Tin Cay', 'Trang Thai') -ForegroundColor Cyan
Write-Host ('-' * 85) -ForegroundColor Gray

foreach ($res in ($auditResults | Sort-Object ReliabilityScore -Descending)) {
    $color = 'Green'
    if ($res.Status -eq 'LOW') { $color = 'Red' }
    elseif ($res.Status -eq 'MEDIUM') { $color = 'Yellow' }

    $dispPath = if ($res.FilePath.Length -gt 48) { '...' + $res.FilePath.Substring($res.FilePath.Length - 45) } else { $res.FilePath }
    $tStat = "$($res.VerifiedTables)/$($res.TotalTables)"
    $spStat = "$($res.VerifiedSPs)/$($res.TotalSPs)"
    $scoreStr = "$($res.ReliabilityScore)%"

    Write-Host ('{0,-50} | {1,-7} | {2,-7} | {3,-10} | {4}' -f $dispPath, $tStat, $spStat, $scoreStr, $res.Status) -ForegroundColor $color
}

Write-Host ('-' * 85) -ForegroundColor Gray
$overallScore = if ($totalEntitiesMentioned -gt 0) { [math]::Round(($totalEntitiesVerified / $totalEntitiesMentioned) * 100, 1) } else { 100 }
Write-Host ('TONG QUAN HE THONG: ' + $totalEntitiesVerified + ' / ' + $totalEntitiesMentioned + ' doi tuong khop CSDL Live (' + $overallScore + '% Tin cay)') -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Yellow
Write-Host ''

# 4. XUAT FILE BAO CAO MARKDOWN
if ($ExportReport) {
    $reportPath = Join-Path $scriptDir 'KB_RELIABILITY_REPORT.md'
    
    $lines = @(
        '# BAO CAO DO TIN CAY TAI LIEU & SCHEMA DRIFT AUDIT',
        '',
        ('> **Cap nhat:** ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),
        ('> **Tong quan he thong:** **' + $overallScore + '%** doi tuong khop chinh xac voi Live DB (' + $totalEntitiesVerified + ' / ' + $totalEntitiesMentioned + ' doi tuong).'),
        '> **Muc dich:** Huong dan AI va Ky su xac dinh chinh xac muc do tin cay cua tung tai lieu truoc khi van hanh.',
        '',
        '---',
        '',
        '## 1. Tieu Chuan Phan Loai Do Tin Cay',
        '',
        '- **HIGH (>= 90%):** Tai lieu chuan xac cao, Bang & Stored Procedure da duoc verify voi CSDL thuc te. **Co the ap dung ngay logic nghiep vu.**',
        '- **MEDIUM (70% - 89%):** Tai lieu co do chinh xac kha, mot so SP/Bang thuoc DB phu (SmartFramework, VINATECH_GROUP) hoac co typo nho. Can kiem tra nhe truoc khi chay.',
        '- **LOW (< 70%):** Tai lieu co nhieu gia dinh hoac de cap SP chua trien khai tren Production. Bat buoc kiem tra ky CSDL.',
        '',
        '---',
        '',
        '## 2. Bang Danh Gia Chi Tiet Tung Tai Lieu',
        '',
        '| File Tai Lieu | Bang Khop | SP Khop | Do Tin Cay | Phan Loai |',
        '|:---|:---:|:---:|:---:|:---:|'
    )

    foreach ($res in ($auditResults | Sort-Object ReliabilityScore -Descending)) {
        $icon = '[HIGH]'
        if ($res.Status -eq 'LOW') { $icon = '[LOW]' }
        elseif ($res.Status -eq 'MEDIUM') { $icon = '[MEDIUM]' }

        $tStat = "$($res.VerifiedTables)/$($res.TotalTables)"
        $spStat = "$($res.VerifiedSPs)/$($res.TotalSPs)"
        $lines += "| [$($res.FilePath)](file:///$($res.FilePath)) | $tStat | $spStat | **$($res.ReliabilityScore)%** | $icon |"
    }

    $lines += @(
        '',
        '---',
        '',
        '## 3. Danh Sach Doi Tuong Can Luu Y (Unverified / Typos / Cross-DB)',
        ''
    )

    $hasNotes = $false
    foreach ($res in $auditResults) {
        if ($res.UnverifiedTables.Count -gt 0 -or $res.UnverifiedSPs.Count -gt 0) {
            $hasNotes = $true
            $lines += "### File: $($res.FilePath)"
            if ($res.UnverifiedTables.Count -gt 0) {
                $lines += '- **Bang chua tim thay trong Live DB:** ' + ($res.UnverifiedTables -join ', ')
            }
            if ($res.UnverifiedSPs.Count -gt 0) {
                $lines += '- **SP chua tim thay trong Live DB:** ' + ($res.UnverifiedSPs -join ', ')
            }
            $lines += ''
        }
    }

    if (-not $hasNotes) {
        $lines += '*Tat ca cac doi tuong trong tai lieu deu khop hoan toan voi CSDL.*'
    }

    $lines += @(
        '---',
        '*Bao cao duoc tao tu dong boi cong cu audit_kb_reliability.ps1.*'
    )

    $reportContent = $lines -join [Environment]::NewLine
    $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($reportPath, $reportContent, $utf8WithBom)

    Write-Host ('-> Da xuat bao cao chi tiet tai: ' + $reportPath) -ForegroundColor Green
}
