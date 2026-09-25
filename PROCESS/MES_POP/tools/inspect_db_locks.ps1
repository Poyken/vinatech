# ==============================================================================
# inspect_db_locks.ps1 — Real-Time Database Lock & Blocking Inspector
# Multi-DB Engine (SmartFactoryV2, SmartFramework, POP, etc.)
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Profile = 'SmartFactoryV2',
    [int]$ThresholdSec = 3
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "     [DB-LOCKS] KIEM TRA KHOA & TAC NGHEN CSDL (REAL-TIME LOCKS)" -ForegroundColor Yellow
Write-Host "     Database Profile: $Profile | Nguong canh bao: > $ThresholdSec giay" -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Cyan

$conn = Get-DbConnection -Profile $Profile -Silent
if ($null -eq $conn) {
    Write-Host "Loi: Khong the ket noi toi CSDL $Profile!" -ForegroundColor Red
    exit 1
}

$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SET NOCOUNT ON;

-- 1. Blocking Sessions (Dang chan cac session khac)
SELECT 
    r.session_id AS BlockedSpid,
    r.blocking_session_id AS BlockerSpid,
    r.wait_time / 1000.0 AS WaitTimeSec,
    r.wait_type AS WaitType,
    r.status AS Status,
    ISNULL(DB_NAME(r.database_id), '') AS DatabaseName,
    SUBSTRING(st.text, (r.statement_start_offset/2)+1, 
        ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) AS BlockedSql,
    s.login_name AS LoginName,
    s.host_name AS HostName,
    s.program_name AS ProgramName
FROM sys.dm_exec_requests r WITH(NOLOCK)
JOIN sys.dm_exec_sessions s WITH(NOLOCK) ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.blocking_session_id <> 0;

-- 2. Long Running Active Queries (> ThresholdSec)
SELECT 
    r.session_id AS Spid,
    r.total_elapsed_time / 1000.0 AS ElapsedSec,
    r.cpu_time AS CpuMs,
    r.reads AS PageReads,
    r.writes AS PageWrites,
    r.command AS Command,
    r.status AS Status,
    r.blocking_session_id AS BlockerSpid,
    ISNULL(DB_NAME(r.database_id), '') AS DatabaseName,
    SUBSTRING(st.text, (r.statement_start_offset/2)+1, 
        ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) AS SqlText,
    s.login_name AS LoginName,
    s.program_name AS ProgramName
FROM sys.dm_exec_requests r WITH(NOLOCK)
JOIN sys.dm_exec_sessions s WITH(NOLOCK) ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id <> @@SPID 
  AND s.is_user_process = 1
  AND r.total_elapsed_time >= ($ThresholdSec * 1000)
ORDER BY r.total_elapsed_time DESC;

-- 3. Top Active Lock Types (U-locks, X-locks, Range locks)
SELECT TOP 10
    tl.resource_type AS ResourceType,
    tl.request_mode AS LockMode,
    tl.request_status AS Status,
    COUNT(1) AS TotalLocks,
    tl.request_session_id AS Spid
FROM sys.dm_tran_locks tl WITH(NOLOCK)
WHERE tl.request_session_id <> @@SPID
GROUP BY tl.resource_type, tl.request_mode, tl.request_status, tl.request_session_id
HAVING COUNT(1) > 10
ORDER BY TotalLocks DESC;
"@

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null
$conn.Close()

# Render Kết quả
$blockedTable = $ds.Tables[0]
$runningTable = $ds.Tables[1]
$locksTable = $ds.Tables[2]

if ($blockedTable.Rows.Count -gt 0) {
    Write-Host "`n[!] CANH BAO: PHAT HIEN $($blockedTable.Rows.Count) SESSION DANG BI BLOCKING NGHEN DUONG TRUYEN!" -ForegroundColor Red
    $blockedTable | Format-Table BlockedSpid, BlockerSpid, WaitTimeSec, WaitType, DatabaseName, LoginName, ProgramName -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
    
    foreach ($r in $blockedTable.Rows) {
        Write-Host "   * [SPID $($r['BlockedSpid'])] bi chan boi [SPID $($r['BlockerSpid'])] cho $($r['WaitTimeSec'])s. SQL: $($r['BlockedSql'])" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[OK] KHONG CO BLOCKING LOCK NAO (Cac session luu thong thong suot)." -ForegroundColor Green
}

if ($runningTable.Rows.Count -gt 0) {
    Write-Host "`n[!] CO $($runningTable.Rows.Count) QUERY DANG CHAY LAU (>= $ThresholdSec s):" -ForegroundColor Yellow
    $runningTable | Format-Table Spid, ElapsedSec, PageReads, Command, Status, LoginName, ProgramName -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
    
    foreach ($r in $runningTable.Rows) {
        $sqlSnippet = if ($r['SqlText']) { $r['SqlText'].ToString().Trim().Replace("`r", " ").Replace("`n", " ") } else { "" }
        if ($sqlSnippet.Length -gt 150) { $sqlSnippet = $sqlSnippet.Substring(0, 150) + "..." }
        Write-Host "   * [SPID $($r['Spid'])] Chay: $($r['ElapsedSec'])s | Reads: $($r['PageReads']) trang | SQL: $sqlSnippet" -ForegroundColor White
    }
} else {
    Write-Host "`n[OK] KHONG CO QUERY NAO CHAY LAU (Tat ca query duoi $ThresholdSec s)." -ForegroundColor Green
}

if ($locksTable.Rows.Count -gt 0) {
    Write-Host "`n>>> TOP KHOA HE THONG (sys.dm_tran_locks):" -ForegroundColor Cyan
    $locksTable | Format-Table ResourceType, LockMode, Status, TotalLocks, Spid -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
}

Write-Host "======================================================================`n"
