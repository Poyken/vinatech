# ==============================================================================
# find_kb.ps1 — 2-Tier Knowledge Base Finder for Vinatech Groupware Ecosystem
# Tier 1: L1 Ultra-Fast JSON Cache (<0.001s, ~150 tokens)
# Tier 2: Deep Markdown Archive (12+ KB files & Integrations)
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Query,
    [ValidateSet('ALL', 'FORMS', 'INTEGRATIONS', 'CONFIG')]
    [string]$Category = 'ALL',
    [int]$Limit = 15
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$matrixFile = Join-Path $rootDir 'AI_AGENT_CONFIG\GW_FORM_MATRIX.json'
$foundInL1 = $false

# 1. TIER 1: KIEM TRA L1 QUICK MATRIX TRUOC
if (Test-Path $matrixFile) {
    try {
        $matrixJson = Get-Content -Path $matrixFile -Encoding UTF8 -Raw | ConvertFrom-Json
        $qUpper = $Query.ToUpper().Trim()

        # 1.1 Match Chinh Xac Form ID
        if ($matrixJson.forms.$qUpper) {
            $form = $matrixJson.forms.$qUpper
            Write-Host ''
            Write-Host '======================================================================' -ForegroundColor Green
            Write-Host ('  [L1 CACHE HIT] BIEU MAU: ' + $qUpper + ' - ' + $form.name) -ForegroundColor Yellow
            Write-Host '======================================================================' -ForegroundColor Green
            Write-Host ('  * Phan He     : ' + $form.module) -ForegroundColor White
            Write-Host ('  * Bang CSDL   : ' + ($form.tables -join ', ')) -ForegroundColor Cyan
            Write-Host ('  * Bang ERP    : ' + ($form.erp_tables -join ', ')) -ForegroundColor Magenta
            Write-Host ('  * Man Hinh MES: ' + ($form.mes_screens -join ', ')) -ForegroundColor Green
            Write-Host ('  * Tuyen Duyet : ' + $form.approval_line) -ForegroundColor White
            Write-Host '  * Cac loi thuong gap:' -ForegroundColor Yellow
            foreach ($prop in $form.common_errors.PSObject.Properties) {
                Write-Host ('    - ' + $prop.Name + ' : ' + $prop.Value) -ForegroundColor Gray
            }
            if ($form.diagnostic_query) {
                Write-Host ('  * Truy van Mau: ' + $form.diagnostic_query) -ForegroundColor Cyan
            }
            Write-Host '======================================================================' -ForegroundColor Green
            $foundInL1 = $true
        } else {
            # 1.2 Match Theo Tu Khoa trong L1
            $matchedForms = @()
            foreach ($prop in $matrixJson.forms.PSObject.Properties) {
                $fCode = $prop.Name
                $fObj = $prop.Value
                $hit = $false
                $hitReason = ''

                if ($fObj.name -match "(?i)$([regex]::Escape($Query))") {
                    $hit = $true
                    $hitReason = "Ten bieu mau: $($fObj.name)"
                } elseif ($fObj.module -match "(?i)$([regex]::Escape($Query))") {
                    $hit = $true
                    $hitReason = "Phan he: $($fObj.module)"
                } else {
                    foreach ($errProp in $fObj.common_errors.PSObject.Properties) {
                        if ($errProp.Name -match "(?i)$([regex]::Escape($Query))" -or $errProp.Value -match "(?i)$([regex]::Escape($Query))") {
                            $hit = $true
                            $hitReason = "Loi: $($errProp.Name) -> $($errProp.Value)"
                            break
                        }
                    }
                }

                if ($hit) {
                    $matchedForms += [PSCustomObject]@{
                        Code   = $fCode
                        Name   = $fObj.name
                        Module = $fObj.module
                        Tables = ($fObj.tables -join ', ')
                        Reason = $hitReason
                    }
                }
            }

            if ($matchedForms.Count -gt 0) {
                Write-Host ''
                Write-Host ('  [L1 CACHE MATCH] Tim thay ' + $matchedForms.Count + ' bieu mau phu hop trong L1 Matrix:') -ForegroundColor Green
                $matchedForms | Format-Table -Property Code, Name, Module, Reason -AutoSize
                $foundInL1 = $true
            }
        }
    } catch {
        Write-Warning "Khong the phan tich GW_FORM_MATRIX.json: $_"
    }
}

# 2. TIER 2: DEEP SCAN TAI LIEU MARKDOWN (Neu chua thoa man hoac can chi tiet)
Write-Host ''
Write-Host "--- TIER 2: QUET CHUYEN SAU TRONG TAI LIEU GROUPWARE ---" -ForegroundColor Cyan
$kbDir = Join-Path $rootDir 'GROUPWARE_KNOWLEDGE_BASE'
$files = Get-ChildItem -Path $kbDir -Filter '*.md' -Recurse

$results = @()
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    $lineNum = 0
    foreach ($line in $content) {
        $lineNum++
        if ($line -match "(?i)$([regex]::Escape($Query))") {
            $relPath = $file.FullName.Replace($rootDir, '').TrimStart('\').TrimStart('/')
            $results += [PSCustomObject]@{
                File = $relPath
                Line = $lineNum
                Text = $line.Trim()
            }
            if ($results.Count -ge $Limit) { break }
        }
    }
    if ($results.Count -ge $Limit) { break }
}

if ($results.Count -gt 0) {
    Write-Host "Tim thay $($results.Count) ket qua trong tai lieu:" -ForegroundColor Green
    foreach ($res in $results) {
        Write-Host "[$($res.File):$($res.Line)] " -NoNewline -ForegroundColor Yellow
        Write-Host $res.Text -ForegroundColor White
    }
} else {
    if (-not $foundInL1) {
        Write-Host "Khong tim thay ket qua nao phu hop voi tu khoa: '$Query'" -ForegroundColor Gray
    }
}
Write-Host ''
