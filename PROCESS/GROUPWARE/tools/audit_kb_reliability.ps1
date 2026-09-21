# ==============================================================================
# audit_kb_reliability.ps1 — Groupware Automated KB Reliability Auditor
# Kiem tra do tin cay cua tai lieu Groupware vs CSDL Thuc te (VINATECH_GROUP, ERP, MES)
# ==============================================================================

param(
    [switch]$Detailed = $false
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $PSScriptRoot 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '     VINATECH GROUPWARE - AUTOMATED KB RELIABILITY AUDITOR' -ForegroundColor Yellow
Write-Host ('     Thoi gian chay: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''

# 1. KET NOI & THU THAP METADATA TU CAC DATABASE
Write-Host '1. DANG THU THAP METADATA THUC TE TU CSDL...' -ForegroundColor Cyan

$dbObjects = @{
    Tables = @{}
    SPs    = @{}
    Views  = @{}
}

$scanProfiles = @('Groupware', 'ERP', 'SmartFactoryV2', 'SSO')

foreach ($pName in $scanProfiles) {
    $conn = Get-DbConnection -Profile $pName -Silent -ConnectTimeoutSeconds 5
    if ($conn -ne $null) {
        $dbName = $conn.Database
        Write-Host ('  [OK] Metadata: ' + $dbName.PadRight(18) + ' (Profile: ' + $pName + ')') -ForegroundColor Green
        
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = 30
            
            # Read Tables
            $cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $tName = $rdr.GetString(0).ToUpper()
                if (-not $dbObjects.Tables.ContainsKey($tName)) {
                    $dbObjects.Tables[$tName] = @()
                }
                $dbObjects.Tables[$tName] += $dbName
            }
            $rdr.Close()

            # Read Views
            $cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS"
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $vName = $rdr.GetString(0).ToUpper()
                if (-not $dbObjects.Views.ContainsKey($vName)) {
                    $dbObjects.Views[$vName] = @()
                }
                $dbObjects.Views[$vName] += $dbName
            }
            $rdr.Close()

            # Read SPs & Functions
            $cmd.CommandText = "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES"
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
            Write-Host ('  [WARN] Khong the doc toan bo metadata tu ' + $dbName + ': ' + $_.Exception.Message) -ForegroundColor Yellow
        } finally {
            $conn.Close()
        }
    } else {
        Write-Host ('  [FAIL] Khong the ket noi CSDL Profile: ' + $pName) -ForegroundColor Red
    }
}

Write-Host ('  -> Tim thay: ' + $dbObjects.Tables.Count + ' Tables | ' + $dbObjects.Views.Count + ' Views | ' + $dbObjects.SPs.Count + ' Routines.') -ForegroundColor Green
Write-Host ''

# 2. SCAN & VERIFY TAI LIEU GROUPWARE
Write-Host '2. DANG PHAN TICH DOI SOAT TAI LIEU GROUPWARE...' -ForegroundColor Cyan

$scanDirs = @(
    (Join-Path $rootDir 'GROUPWARE_KNOWLEDGE_BASE'),
    (Join-Path $rootDir 'AI_AGENT_CONFIG'),
    (Join-Path $rootDir 'docs')
)

$kbFiles = @()
foreach ($d in $scanDirs) {
    if (Test-Path $d) {
        $kbFiles += Get-ChildItem -Path $d -Filter '*.md' -Recurse
    }
}
$kbFiles += Get-ChildItem -Path $rootDir -Filter '*.md' -File

$totalFound = 0
$totalVerified = 0
$unmatched = @()

foreach ($file in $kbFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $fullText = $content -join "`n"

    # Extract VINA_%, A_DOCU%, PU_%, SA_%, STB_% tables
    $matches = [regex]::Matches($fullText, '\b(?:VINA|A_DOCU|PU|SA|MA|STB)_[a-zA-Z0-9_]+\b')
    $entities = @()
    foreach ($m in $matches) { $entities += $m.Value.ToUpper() }
    $entities = $entities | Select-Object -Unique

    foreach ($ent in $entities) {
        $totalFound++
        $isOk = $dbObjects.Tables.ContainsKey($ent) -or $dbObjects.Views.ContainsKey($ent) -or $dbObjects.SPs.ContainsKey($ent)
        if ($isOk) {
            $totalVerified++
        } else {
            $unmatched += [PSCustomObject]@{
                Entity = $ent
                File = $file.Name
            }
        }
    }
}

$score = if ($totalFound -gt 0) { [math]::Round(($totalVerified / $totalFound) * 100, 2) } else { 100 }

Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '                      KET QUA KIEM TOAN' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ('  Tong so thuc the CSDL duoc trich xuat: ' + $totalFound)
Write-Host ('  So thuc the khop 100% voi CSDL Live:  ' + $totalVerified) -ForegroundColor Green
Write-Host ('  DO TIN CAY TAI LIEU (RELIABILITY):    ' + $score + '%') -ForegroundColor $(if ($score -ge 90) { 'Green' } else { 'Yellow' })
Write-Host ''

if ($unmatched.Count -gt 0 -and $Detailed) {
    Write-Host 'DANH SACH THUC THE CHUA KHOP (Co the la bang phu hoac ERP chua sync):' -ForegroundColor Yellow
    $unmatched | Select-Object -Unique Entity, File | Format-Table -AutoSize
}
