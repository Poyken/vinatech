# ==============================================================================
# find_kb.ps1 — Fast Knowledge Base Finder for Vinatech MES Ecosystem
# Tra cuu sieu toc trong 12+ KB files, 90+ Screens, 15 DBs, Groupware, POP
#
# Cach dung:
#   .\find_kb.ps1 "B530"
#   .\find_kb.ps1 "Sanmina" -Category MES
#   .\find_kb.ps1 "USP_B523_SET_INFO_GET"
#   .\find_kb.ps1 "loi tem"
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Query,
    [ValidateSet("ALL", "MES", "DB", "GW", "POP", "SYS", "CONFIG")]
    [string]$Category = "ALL",
    [int]$Limit = 15
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetDirs = @()
switch ($Category) {
    "MES"    { $targetDirs += Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE" }
    "DB"     { $targetDirs += Join-Path $PSScriptRoot "DATABASE_KNOWLEDGE_BASE" }
    "GW"     { $targetDirs += Join-Path $PSScriptRoot "GROUPWARE_KNOWLEDGE_BASE" }
    "POP"    { $targetDirs += Join-Path $PSScriptRoot "POP_KNOWLEDGE_BASE" }
    "SYS"    { $targetDirs += Join-Path $PSScriptRoot "SYSTEM_ARCHITECTURE" }
    "CONFIG" { $targetDirs += Join-Path $PSScriptRoot "AI_AGENT_CONFIG" }
    default  {
        $targetDirs += Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "DATABASE_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "GROUPWARE_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "POP_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "SYSTEM_ARCHITECTURE"
        $targetDirs += Join-Path $PSScriptRoot "AI_AGENT_CONFIG"
    }
}

$files = @()
foreach ($dir in $targetDirs) {
    if (Test-Path $dir) {
        $files += Get-ChildItem -Path $dir -Filter "*.md" -Recurse
    }
}

if ($Category -eq "ALL") {
    $files += Get-ChildItem -Path $PSScriptRoot -Filter "*.md" -File
}

Write-Host ""
Write-Host "(*) DANG TRA CUU TRI THUC CHO TU KHOA: '$Query' (Phan loai: $Category, Tong file quet: $($files.Count))..." -ForegroundColor Cyan
Write-Host ""

$totalMatches = 0
$fileMatchDict = [ordered]@{}

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $relPath = $file.FullName.Replace($PSScriptRoot, ".").Replace("\", "/")
    $matchesInFile = @()
    $currentHeader = ""
    $lineIdx = 1

    foreach ($line in $content) {
        if ($line -match "^#{1,4}\s+(.+)$") {
            $currentHeader = $matches[1].Trim()
        }

        if ($line -match [regex]::Escape($Query)) {
            $trimmed = $line.Trim()
            if ($trimmed.Length -gt 3 -and $trimmed -notmatch "^[#\-\s\=\|]+$") {
                $matchesInFile += @{
                    LineNumber = $lineIdx
                    Header     = $currentHeader
                    Text       = $trimmed
                }
                $totalMatches++
            }
        }

        if ($totalMatches -ge $Limit) { break }
        $lineIdx++
    }

    if ($matchesInFile.Count -gt 0) {
        $fileMatchDict[$relPath] = $matchesInFile
    }

    if ($totalMatches -ge $Limit) { break }
}

if ($fileMatchDict.Keys.Count -eq 0) {
    Write-Host "(-) Khong tim thay tai lieu nao chua tu khoa '$Query'." -ForegroundColor Gray
    Write-Host "Goi y: Kiem tra chinh ta hoac thu tra cuu bang Screen ID (VD: B530, B540), ten SP hoac ma loi." -ForegroundColor Yellow
} else {
    foreach ($fPath in $fileMatchDict.Keys) {
        Write-Host "File: $fPath" -ForegroundColor Green
        foreach ($m in $fileMatchDict[$fPath]) {
            $headerTag = if ($m.Header) { " [" + $m.Header + "]" } else { "" }
            Write-Host ("   Line " + $m.LineNumber + $headerTag) -ForegroundColor DarkCyan
            Write-Host ("   -> " + $m.Text) -ForegroundColor White
            Write-Host ""
        }
    }
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Tim thay $totalMatches ket qua phu hop. (Toi da hien thi: $Limit)" -ForegroundColor Cyan
}
