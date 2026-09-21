<#
.SYNOPSIS
    Kiem tra va bóc tach toàn bo SQL Server Agent Jobs tren he thong.
.DESCRIPTION
    Liet ke danh sach jobs, trang thai enable, lich trinh chay, buoc thuc thi (TSQL/SSIS) va ket qua lan chay gan nhat.
#>
param (
    [string]$Search,
    [string]$Name,
    [switch]$ActiveOnly,
    [switch]$Detail
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  SQL SERVER AGENT JOBS AUDITOR (Server: dbserver.hycap.co.kr,5398)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$dbObj = Get-DBConnection -CustomDB "msdb"
$conn = $dbObj.Connection

try {
    if ($Detail -and $Name) {
        Write-Host "DOC CHI TIET CAC BUOC CUA JOB: '$Name'..." -ForegroundColor Yellow
        $cmd = $conn.CreateCommand()
        $cleanName = $Name.Replace("'", "''")
        $cmd.CommandText = @"
SELECT 
    s.step_id AS Step,
    s.step_name AS StepName,
    s.subsystem AS Subsystem,
    s.database_name AS TargetDB,
    s.on_success_action AS OnSuccess,
    s.on_fail_action AS OnFail,
    s.command AS Command
FROM msdb.dbo.sysjobs j WITH(NOLOCK)
JOIN msdb.dbo.sysjobsteps s WITH(NOLOCK) ON j.job_id = s.job_id
WHERE j.name = '$cleanName'
ORDER BY s.step_id;
"@
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $steps = $ds.Tables[0]

        if ($steps.Rows.Count -gt 0) {
            foreach ($row in $steps.Rows) {
                Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
                Write-Host "Step $($row.Step): $($row.StepName) [Subsystem: $($row.Subsystem) | Target DB: $($row.TargetDB)]" -ForegroundColor Green
                Write-Host "Command:" -ForegroundColor DarkYellow
                Write-Host $row.Command
            }
        } else {
            Write-Host "Khong tim thay buoc nao cho Job: '$Name'" -ForegroundColor Red
        }
    } else {
        $filter = "WHERE 1=1"
        if ($ActiveOnly) {
            $filter += " AND j.enabled = 1"
        }
        if ($Search) {
            $cleanSearch = $Search.Replace("'", "''")
            $filter += " AND j.name LIKE '%$cleanSearch%'"
        }

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = @"
SELECT 
    j.name AS JobName,
    CASE j.enabled WHEN 1 THEN 'ENABLED' ELSE 'DISABLED' END AS Status,
    ISNULL(jh.run_status_desc, 'NEVER RUN') AS LastStatus,
    jh.last_run_time AS LastRunTime,
    s.step_count AS TotalSteps,
    j.description AS Description
FROM msdb.dbo.sysjobs j WITH(NOLOCK)
LEFT JOIN (
    SELECT job_id, COUNT(*) AS step_count 
    FROM msdb.dbo.sysjobsteps WITH(NOLOCK) 
    GROUP BY job_id
) s ON j.job_id = s.job_id
OUTER APPLY (
    SELECT TOP 1 
        CASE run_status 
            WHEN 0 THEN 'FAILED' 
            WHEN 1 THEN 'SUCCESS' 
            WHEN 2 THEN 'RETRY' 
            WHEN 3 THEN 'CANCELLED' 
            ELSE 'UNKNOWN' 
        END AS run_status_desc,
        CAST(run_date AS VARCHAR(8)) + ' ' + RIGHT('000000' + CAST(run_time AS VARCHAR(6)), 6) AS last_run_time
    FROM msdb.dbo.sysjobhistory h WITH(NOLOCK)
    WHERE h.job_id = j.job_id AND h.step_id = 0
    ORDER BY instance_id DESC
) jh
$filter
ORDER BY j.enabled DESC, j.name;
"@
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$adapter.Fill($ds)
        $table = $ds.Tables[0]

        Write-Host "Tim thay $($table.Rows.Count) SQL Server Agent Jobs:" -ForegroundColor Green
        $table | Format-Table -AutoSize
        Write-Host "Meo: Chay '.\db.ps1 jobs -Name <JobName> -Detail' de xem ma lenh chi tiet cac buoc." -ForegroundColor DarkCyan
    }
} finally {
    if ($conn.State -eq [System.Data.ConnectionState]::Open) {
        $conn.Close()
        $conn.Dispose()
    }
}
Write-Host "================================================================================" -ForegroundColor Cyan
