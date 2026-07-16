$server = "dbserver.hycap.co.kr,5398"
$database = "msdb"
$user = "vinaadmin"
$password = "vina1234%6&8"
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$queries = @(
    @{
        name = "1. SQL Agent Jobs Schedule"
        sql = "
        SELECT 
            j.name AS JobName,
            j.enabled AS Enabled,
            s.name AS ScheduleName,
            s.enabled AS ScheduleEnabled,
            CASE s.freq_type
                WHEN 1 THEN 'One time'
                WHEN 4 THEN 'Daily'
                WHEN 8 THEN 'Weekly'
                WHEN 16 THEN 'Monthly'
                WHEN 32 THEN 'Monthly, relative'
                WHEN 64 THEN 'When SQLServerAgent starts'
                WHEN 128 THEN 'When computer is idle'
            END AS FrequencyType,
            s.freq_interval AS FrequencyInterval,
            s.freq_subday_type,
            s.freq_subday_interval,
            s.active_start_time AS StartTime,
            s.active_end_time AS EndTime
        FROM msdb.dbo.sysjobs j WITH(NOLOCK)
        INNER JOIN msdb.dbo.sysjobschedules js WITH(NOLOCK) ON j.job_id = js.job_id
        INNER JOIN msdb.dbo.sysschedules s WITH(NOLOCK) ON js.schedule_id = s.schedule_id
        WHERE j.enabled = 1
          AND (j.name LIKE '%IF%' OR j.name LIKE '%Sync%' OR j.name LIKE '%ERP%' OR j.name LIKE '%??%')
        "
    }
)

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $conn.Open()
    Write-Host "========== XEM LỊCH TRÌNH CÁC JOB ĐỒNG BỘ ==========" -ForegroundColor Green
    
    foreach ($query in $queries) {
        Write-Host ""
        Write-Host ">>> $($query.name)" -ForegroundColor Cyan
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $query.sql
        
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dataTable = New-Object System.Data.DataTable
        $adapter.Fill($dataTable) | Out-Null
        
        if ($dataTable.Rows.Count -eq 0) {
            Write-Host "Không tìm thấy lịch trình." -ForegroundColor Yellow
        } else {
            $dataTable | Format-Table -AutoSize | Out-String -Width 1000 | Write-Host
        }
    }
} catch {
    Write-Error "Truy vấn database thất bại: $_"
} finally {
    $conn.Close()
}
