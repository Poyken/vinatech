# Script Tự Động Ghi Nhật Ký Hotfix & Cập Nhật Tri Thức
param(
    [Parameter(Mandatory=$true)]
    [string]$ScreenID,
    
    [Parameter(Mandatory=$true)]
    [string]$Issue,
    
    [Parameter(Mandatory=$true)]
    [string]$RootCause,
    
    [Parameter(Mandatory=$true)]
    [string]$FixSQL
)

$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$hotfixFile = "$baseDir\AI_AGENT_CONFIG\HOTFIX_LOG.md"
$kiFile = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\knowledge\vinatech_bug_fix_patterns\artifacts\bug_fix_patterns.md"

$dateStr = Get-Date -Format "yyyy-MM-dd HH:mm"

$logEntry = @"

### [$dateStr] [$ScreenID] — $Issue
* **Nguyên nhân gốc:** $RootCause
* **Script SQL Fix:**
```sql
$FixSQL
```
"@

# Append to HOTFIX_LOG.md
Add-Content -Path $hotfixFile -Value $logEntry -Encoding UTF8
Write-Host "Appended new entry to HOTFIX_LOG.md"

# Append to KI bug_fix_patterns if exists
if (Test-Path $kiFile) {
    Add-Content -Path $kiFile -Value $logEntry -Encoding UTF8
    Write-Host "Appended new entry to Knowledge Item vinatech_bug_fix_patterns"
}
