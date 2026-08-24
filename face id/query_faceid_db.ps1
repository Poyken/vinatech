# ==============================================================================
# SCRIPT TRA CỨU DATABASE FACE ID / CHẤM CÔNG HIKCENTRAL (HCP_DATA)
# Server: 192.168.184.250 | Database: HCP_DATA | User: hikcentral
# ==============================================================================

param(
    [string]$Query = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$server = "192.168.184.250,1433"
$database = "HCP_DATA"
$user = "hikcentral"
$password = "vinatech@2026"

$connStr = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Host ">>> KET NOI THANH CONG TOI DATABASE FACE ID ($database @ $server)" -ForegroundColor Green
} catch {
    Write-Host "LOI KET NOI: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

function Execute-Query([string]$sql) {
    if ([string]::IsNullOrWhiteSpace($sql)) { return }
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 60
        $cmd.CommandText = $sql
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $null = $adapter.Fill($dt)
        if ($dt.Rows.Count -eq 0) {
            Write-Host "(0 ban ghi)" -ForegroundColor Gray
        } else {
            Write-Host "`nKet qua ($($dt.Rows.Count) dong):" -ForegroundColor Green
            $dt | Format-Table -AutoSize | Out-String -Width 4000
        }
    } catch {
        Write-Host "LOI SQL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($Query -ne "") {
    Execute-Query -sql $Query
    $conn.Close()
    exit
}

Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "CHE DO TRA CUU DU LIEU FACE ID (Go 'exit' de thoat)" -ForegroundColor Yellow
Write-Host "Gợi ý: SELECT TOP 10 EmployeeID, PersonName, AccessDateTime, DeviceName FROM dbo.HCP_AccessRecord ORDER BY AccessDateTime DESC" -ForegroundColor Gray
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Yellow

while ($true) {
    $userSql = Read-Host "SQL"
    if ($userSql -eq "exit" -or $userSql -eq "quit" -or $userSql -eq "q") { break }
    Execute-Query -sql $userSql
}

$conn.Close()
Write-Host "Da ngat ket noi CSDL." -ForegroundColor Cyan
