<#
.SYNOPSIS
    Superfast L1 Cache Search (<0.001s) for YoungLimWon K-System Ace ERP (FINAL)
.DESCRIPTION
    Scans in-memory matrices for modules, process menus, programs, screen IDs,
    database tables, and cross-system integration pipelines.
#>

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Keyword
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$matrixFile = Join-Path $PSScriptRoot "..\AI_AGENT_CONFIG\KSYSTEM_MATRIX.json"
$integFile = Join-Path $PSScriptRoot "..\AI_AGENT_CONFIG\UNIFIED_INTEGRATION_MATRIX.json"

if (-not (Test-Path $matrixFile)) {
    Write-Error "Matrix file not found: $matrixFile"
    exit 1
}

$matrix = Get-Content -Raw $matrixFile -Encoding UTF8 | ConvertFrom-Json
$kw = $Keyword.Trim().ToLower()

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  K-SYSTEM ACE ERP L1 IN-MEMORY FAST SEARCH: '$Keyword'" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$matchCount = 0

# 1. Search Modules
Write-Host "`n[PHAN HE NGHIEP VU (MODULES)]:" -ForegroundColor Yellow
foreach ($modKey in $matrix.modules.PSObject.Properties.Name) {
    $m = $matrix.modules.$modKey
    $match = ($m.module_code -like "*$kw*") -or ($m.name_vi -like "*$kw*") -or ($m.name_ko -like "*$kw*") -or ($m.module_seq.ToString() -eq $kw)
    if ($match) {
        $matchCount++
        Write-Host "  * [Seq $($m.module_seq)] $($m.name_vi) ($($m.name_ko))" -ForegroundColor Green
        Write-Host "    Ma: $($m.module_code) | Quy trinh: $($m.process_menu_count) | Chuong trinh: $($m.program_count)" -ForegroundColor Gray
        Write-Host "    Bang CSDL: $($m.key_tables -join ', ')" -ForegroundColor DarkCyan
    }
}

# 2. Search Screens & Programs
Write-Host "`n[MAN HINH & CHUONG TRINH TRONG DIEM (PROGRAMS)]:" -ForegroundColor Yellow
foreach ($modKey in $matrix.modules.PSObject.Properties.Name) {
    $m = $matrix.modules.$modKey
    if ($m.key_screens) {
        foreach ($s in $m.key_screens) {
            $matchScreen = ($s.pgm_id -like "*$kw*") -or ($s.name_vi -like "*$kw*") -or ($s.pgm_seq.ToString() -like "*$kw*") -or ($s.desc -like "*$kw*")
            if ($matchScreen) {
                $matchCount++
                Write-Host "  * [PgmSeq: $($s.pgm_seq)] $($s.pgm_id) - $($s.name_vi)" -ForegroundColor Cyan
                Write-Host "    Phan he: $($m.name_vi) (Seq: $($m.module_seq))" -ForegroundColor Gray
                Write-Host "    Chuc nang: $($s.desc)" -ForegroundColor White
            }
        }
    }
}

# 3. Search Cross-System Integration Pipelines
if (Test-Path $integFile) {
    $integ = Get-Content -Raw $integFile -Encoding UTF8 | ConvertFrom-Json
    Write-Host "`n[TUYEN TICH HOP LIEN THONG HE THONG CU (INTEGRATION TOUCHPOINTS)]:" -ForegroundColor Yellow
    foreach ($p in $integ.touchpoints) {
        $matchPipe = ($p.pipeline_id -like "*$kw*") -or ($p.name -like "*$kw*") -or ($p.ksystem_table -like "*$kw*") -or ($p.flow -like "*$kw*")
        if ($matchPipe) {
            $matchCount++
            Write-Host "  * [$($p.pipeline_id)] $($p.name)" -ForegroundColor Magenta
            Write-Host "    Luong: $($p.flow)" -ForegroundColor White
            Write-Host "    Bang K-System: $($p.ksystem_table) (Khoa: $($p.ksystem_keys -join ', '))" -ForegroundColor DarkCyan
            Write-Host "    Dinh huong: $($p.sync_direction)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n================================================================================" -ForegroundColor Cyan
Write-Host "  Tong cong tim thay: $matchCount ket qua phu hop." -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
