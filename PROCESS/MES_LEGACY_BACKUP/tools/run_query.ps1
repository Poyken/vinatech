# ==============================================================================
# run_query.ps1 — SELECT-Only Query Tool for Vinatech MES
# Multi-DB Profile | Tự động dò Server | Chống Lock CSDL | UTF-8 Unicode
#
# Cách dùng 1 (Truyền SQL trực tiếp trên DB mặc định):
#   .\run_query.ps1 -Query "SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK)"
#
# Cách dùng 2 (Truyền Profile CSDL khác: Groupware, ERP, POP, SmartFramework):
#   .\run_query.ps1 -Profile "Groupware" -Query "SELECT TOP 5 * FROM GW_APPROVAL_DOC WITH(NOLOCK)"
#
# Cách dùng 3 (Chạy tương tác):
#   .\run_query.ps1 [-Profile "SmartFactoryV2"]
# ==============================================================================

param(
    [string]$Query = "",
    [string]$Profile = "SmartFactoryV2"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$sharedScript = Join-Path $PSScriptRoot "db_shared.ps1"
if (Test-Path $sharedScript) {
    . $sharedScript
} else {
    Write-Error "db_shared.ps1 not found."
    exit 1
}

$conn = Get-DbConnection -Profile $Profile
if ($conn -eq $null) {
    Write-Host "LOI: Khong the ket noi toi CSDL cho profile '$Profile'!" -ForegroundColor Red
    exit 1
}

function Execute-SelectQuery([string]$sqlText) {
    if ([string]::IsNullOrWhiteSpace($sqlText)) { return }

    # 1. Safety check: Read-Only rule
    $safety = Test-SqlReadOnlySafety -SqlText $sqlText
    if (-not $safety.IsValid) {
        Write-Host "CANH BAO: $($safety.Error)" -ForegroundColor Red
        return
    }

    # 2. Check for missing NOLOCK
    $warnings = Get-NoLockWarnings -SqlText $sqlText
    foreach ($w in $warnings) {
        Write-Host "(!) $w" -ForegroundColor Yellow
    }

    # 3. Trigger proactive KB suggestions
    Invoke-ProactiveKbSearch -SqlText $sqlText

    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 60
        $cmd.CommandText = $sqlText
        
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $null = $adapter.Fill($dt)

        if ($dt.Rows.Count -eq 0) {
            Write-Host "(0 rows returned)" -ForegroundColor Gray
        } else {
            Write-Host "`nKet qua ($($dt.Rows.Count) dong):" -ForegroundColor Green
            $dt | Format-Table -AutoSize | Out-String -Width 4000
        }
    } catch {
        Write-Host "LOI SQL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 1. Chay 1 cau lenh truyen qua tham so
if ($Query -ne "") {
    Execute-SelectQuery -sqlText $Query
    if ($conn.State -eq 'Open') { $conn.Close() }
    exit 0
}

# 2. Che do tuong tac lien tuc
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "CHE DO TRA CUU TUONG TAC (Profile: $($conn.Database))" -ForegroundColor Yellow
Write-Host "Go 'exit' hoac 'quit' de thoat" -ForegroundColor Yellow
Write-Host "Vi du: SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK)" -ForegroundColor Gray
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Yellow

while ($true) {
    $userSql = Read-Host "SQL"
    if ($userSql -eq "exit" -or $userSql -eq "quit" -or $userSql -eq "q") {
        break
    }
    Execute-SelectQuery -sqlText $userSql
}

if ($conn.State -eq 'Open') {
    $conn.Close()
}
Write-Host "Da ngat ket noi CSDL." -ForegroundColor Cyan
