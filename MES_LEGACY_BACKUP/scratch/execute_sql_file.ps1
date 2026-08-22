param(
    [string]$SqlPath
)

if (-not (Test-Path $SqlPath)) {
    Write-Error "File not found: $SqlPath"
    exit 1
}

$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)

try {
    $conn.Open()
    Write-Host "Connected to SQL Server: $($cfg.Server) ($($cfg.Database))" -ForegroundColor Cyan
    
    $sqlText = [System.IO.File]::ReadAllText((Resolve-Path $SqlPath).Path, [System.Text.Encoding]::UTF8)
    
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sqlText, $conn)
    $cmd.CommandTimeout = 120
    
    # Handle print/info messages
    $conn.add_InfoMessage([System.Data.SqlClient.SqlInfoMessageEventHandler]{
        param($sender, $event)
        Write-Host $event.Message -ForegroundColor Yellow
    })
    
    $cmd.ExecuteNonQuery() | Out-Null
    Write-Host "Execution completed successfully for $SqlPath!" -ForegroundColor Green
} catch {
    Write-Error "Execution failed for $SqlPath : $_"
    exit 1
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
