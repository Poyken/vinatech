<#
.SYNOPSIS
    Tra cuu sieu toc L1 Cache va Thu vien tri thuc 15 CSDL Vinatech.
#>
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Keyword
)

$rootDir = Split-Path -Parent $PSScriptRoot
$matrixPath = "$rootDir\AI_AGENT_CONFIG\DATABASE_MATRIX.json"
$kbDir = "$rootDir\DATABASE_KNOWLEDGE_BASE"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  TRA CUU TRI THUC CSDL: '$Keyword'" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

# 1. Tra cuu L1 Cache (DATABASE_MATRIX.json)
if (Test-Path $matrixPath) {
    $matrix = Get-Content -Raw $matrixPath -Encoding UTF8 | ConvertFrom-Json
    $foundL1 = @()

    foreach ($db in $matrix.Databases) {
        $matched = $false
        $matchedTables = @()

        if ($db.Database -match $Keyword -or $db.Profile -match $Keyword -or $db.Description -match $Keyword) {
            $matched = $true
        }

        foreach ($tbl in $db.CoreTables) {
            if ($tbl.Table -match $Keyword -or $tbl.Role -match $Keyword -or $tbl.PK -match $Keyword) {
                $matched = $true
                $matchedTables += "$($tbl.Table) [PK: $($tbl.PK)] - $($tbl.Role)"
            }
        }

        if ($matched) {
            $foundL1 += [PSCustomObject]@{
                Id          = $db.Id
                Database    = $db.Database
                Profile     = $db.Profile
                Pillar      = $db.Pillar
                CoreMatches = ($matchedTables -join "; ")
                Desc        = $db.Description
            }
        }
    }

    if ($foundL1.Count -gt 0) {
        Write-Host "L1 CACHE MATCHES ($($foundL1.Count) CSDL):" -ForegroundColor Green
        foreach ($item in $foundL1) {
            Write-Host "  [$($item.Id)] $($item.Database) (Profile: $($item.Profile) - Pillar: $($item.Pillar))" -ForegroundColor Yellow
            Write-Host "      Mo ta: $($item.Desc)"
            if ($item.CoreMatches) {
                Write-Host "      Bang lien quan: $($item.CoreMatches)" -ForegroundColor Cyan
            }
        }
        Write-Host ""
    }
}

# 2. Tra cuu trong file KB Markdown
$kbFiles = Get-ChildItem -Path $kbDir -Filter "*.md" -Recurse
$kbMatches = @()

foreach ($f in $kbFiles) {
    $lines = Get-Content -Path $f.FullName -Encoding UTF8
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match [regex]::Escape($Keyword)) {
            $snippet = $lines[$i].Trim()
            if ($snippet.Length -gt 100) { $snippet = $snippet.Substring(0, 100) + "..." }
            $kbMatches += [PSCustomObject]@{
                File    = $f.Name
                Line    = ($i + 1)
                Snippet = $snippet
            }
            if ($kbMatches.Count -ge 10) { break }
        }
    }
    if ($kbMatches.Count -ge 10) { break }
}

if ($kbMatches.Count -gt 0) {
    Write-Host "TAI LIEU KNOWLEDGE BASE LIEN QUAN:" -ForegroundColor Magenta
    $kbMatches | Format-Table -AutoSize -Property File, Line, Snippet
}

Write-Host "================================================================================" -ForegroundColor Cyan
