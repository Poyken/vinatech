Write-Host "=== [AUDIT] Running Agent Self-Improvement & Workspace Audit ===" -ForegroundColor Cyan

$mesRoot = $PSScriptRoot
$procDir = Join-Path $mesRoot "sql\procedures"
$hotfixLog = Join-Path $mesRoot "AI_AGENT_CONFIG\HOTFIX_LOG.md"

$hasWarnings = $false

# 1. Check for temporary Stored Procedure files
if (Test-Path $procDir) {
    $tempSps = Get-ChildItem -Path $procDir -Filter "*.sql"
    if ($tempSps.Count -gt 0) {
        Write-Host "[WARNING] Temporary stored procedure files found in sql/procedures/:" -ForegroundColor Yellow
        foreach ($sp in $tempSps) {
            Write-Host "  - $($sp.Name)" -ForegroundColor Yellow
        }
        Write-Host "--> Action: Run '.\db_sync_tool.ps1 -Clean' to clean them up before ending your task." -ForegroundColor Yellow
        $hasWarnings = $true
    }
}

# 2. Check Git status for unrecorded fixes
try {
    $gitStatus = git status --porcelain 2>&1
    if ($LASTEXITCODE -eq 0 -and $gitStatus) {
        $modifiedFiles = @()
        foreach ($line in $gitStatus) {
            if ($line -match '^\s*[MADRCU?]+\s+(.*)$') {
                $modifiedFiles += $Matches[1].Trim()
            }
        }
        
        $hasSqlChanges = $false
        $hasHotfixUpdate = $false
        
        foreach ($file in $modifiedFiles) {
            if ($file -match '\.sql$') {
                if ($file -notmatch 'validate_sql|deploy_tool|db_sync_tool|run_query|db_shared|record_hotfix|self_improve|debug_screen') {
                    $hasSqlChanges = $true
                }
            }
            if ($file -match 'HOTFIX_LOG\.md$') {
                $hasHotfixUpdate = $true
            }
        }
        
        if ($hasSqlChanges -and -not $hasHotfixUpdate) {
            Write-Host "[WARNING] You have modified SQL files or database objects, but you have NOT updated AI_AGENT_CONFIG/HOTFIX_LOG.md." -ForegroundColor Yellow
            Write-Host "--> Action: Please run '.\record_hotfix.ps1' to document your changes." -ForegroundColor Yellow
            $hasWarnings = $true
        }
    }
} catch {
    Write-Host "[INFO] Git not found or not in git repo. Skipping Git-based hotfix checks." -ForegroundColor Gray
}

# 3. Check rule enforcement checklist
Write-Host "Checking rules compliance..." -ForegroundColor Cyan
Write-Host "  [ ] SELECT-ONLY applied? (No direct INSERT/UPDATE/DELETE/ALTER on production DB)" -ForegroundColor Gray
Write-Host "  [ ] NOLOCK used? (Are all queries using WITH(NOLOCK) on transactional tables?)" -ForegroundColor Gray
Write-Host "  [ ] Did you run search_kb.ps1 first? (Or verified proactive search outputs?)" -ForegroundColor Gray

Write-Host "--------------------------------------------------" -ForegroundColor Gray
if (-not $hasWarnings) {
    Write-Host "[OK] Self-audit passed! Workspace is clean and compliant." -ForegroundColor Green
} else {
    Write-Host "[ATTENTION] Workspace has outstanding audit warnings. Please resolve them." -ForegroundColor Red
}
