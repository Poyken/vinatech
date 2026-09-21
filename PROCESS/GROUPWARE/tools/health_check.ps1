# ==============================================================================
# health_check.ps1 — Morning & Real-time Health Check for Groupware Ecosystem
# ==============================================================================

param(
    [switch]$Detail
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '          VINATECH GROUPWARE MORNING HEALTH CHECK' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan

# 1. KIEM TRA KET NOI CSDL
Write-Host ''
Write-Host '[1/4] Kiem tra ket noi den cac CSDL thanh phan...' -ForegroundColor Green
$profiles = @('Groupware', 'ERP', 'SmartFactoryV2', 'SSO')
foreach ($p in $profiles) {
    try {
        $conn = Get-DbConnection -Profile $p -Silent
        if ($conn -ne $null) {
            $dbName = $conn.Database
            Write-Host ('  [OK]   ' + $p.PadRight(15) + ' -> DB: ' + $dbName) -ForegroundColor Green
            $conn.Close()
        } else {
            Write-Host ('  [FAIL] ' + $p.PadRight(15) + ' -> KHONG THE KET NOI') -ForegroundColor Red
        }
    } catch {
        Write-Host ('  [FAIL] ' + $p.PadRight(15) + ' -> Loi: ' + $_.Exception.Message) -ForegroundColor Red
    }
}

# 2. KIEM TRA CAC VAN BAN CHUA DUYET (STATE = 002)
Write-Host ''
Write-Host '[2/4] Thong ke van ban dang trinh duyet (State = 002)...' -ForegroundColor Green
$sqlPending = "SELECT DOCUMENT_SAVE_STATE, COUNT(1) AS TOTAL_DOCS, SUM(CASE WHEN DATEDIFF(hour, DOCUMENT_SAVE_REG_DATE, GETDATE()) > 48 THEN 1 ELSE 0 END) AS STUCK_OVER_48H FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH (NOLOCK) WHERE DOCUMENT_SAVE_STATE = '002' GROUP BY DOCUMENT_SAVE_STATE;"

$pending = Invoke-DbQuery -Profile 'Groupware' -Query $sqlPending
if ($pending -and $pending.Rows.Count -gt 0) {
    $total = $pending.Rows[0]['TOTAL_DOCS']
    $stuck = $pending.Rows[0]['STUCK_OVER_48H']
    Write-Host ('  * Tong so van ban dang cho duyet: ' + $total) -ForegroundColor Yellow
    if ($stuck -gt 0) {
        Write-Host ('  [CANH BAO] Co ' + $stuck + ' van ban dang bi ket qua 48 gio chua duyet!') -ForegroundColor Red
    } else {
        Write-Host '  [OK] Khong co van ban nao bi ket qua 48h.' -ForegroundColor Green
    }
} else {
    Write-Host '  [OK] Hien tai khong co van ban nao dang cho duyet.' -ForegroundColor Green
}

# 3. PHAN BO VAN BAN THEO LOAI TRONG 30 NGAY QUA
Write-Host ''
Write-Host '[3/4] Phan bo van ban khoi tao trong 30 ngay qua...' -ForegroundColor Green
$sqlTypes = "SELECT TOP 8 DOCUMENT_TYPE_ID, COUNT(1) AS DOC_COUNT FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH (NOLOCK) WHERE DOCUMENT_SAVE_REG_DATE >= DATEADD(day, -30, GETDATE()) GROUP BY DOCUMENT_TYPE_ID ORDER BY DOC_COUNT DESC;"
$types = Invoke-DbQuery -Profile 'Groupware' -Query $sqlTypes
if ($types -and $types.Rows.Count -gt 0) {
    $types | Format-Table -AutoSize
}

# 4. DANH SACH VAN BAN DANG BI KET (CHI TIET NEU -Detail)
if ($Detail) {
    Write-Host ''
    Write-Host '[4/4] Danh sach top 10 van ban cho duyet lau nhat:' -ForegroundColor Yellow
    $sqlStuckList = "SELECT TOP 10 DOCUMENT_SAVE_CODE, DOCUMENT_TYPE_ID, NO_EMP_WRITER, DOCUMENT_SAVE_SUBJECT, DATEDIFF(hour, DOCUMENT_SAVE_REG_DATE, GETDATE()) AS HOURS_WAITING, CONVERT(varchar(16), DOCUMENT_SAVE_REG_DATE, 120) AS REG_DATE FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH (NOLOCK) WHERE DOCUMENT_SAVE_STATE = '002' ORDER BY DOCUMENT_SAVE_REG_DATE ASC;"
    $stuckList = Invoke-DbQuery -Profile 'Groupware' -Query $sqlStuckList
    if ($stuckList -and $stuckList.Rows.Count -gt 0) {
        $stuckList | Format-Table -AutoSize
    } else {
        Write-Host '  Khong co van ban nao ton dong.' -ForegroundColor Gray
    }
} else {
    Write-Host ''
    Write-Host '[4/4] Dung lenh ".\gw.ps1 health -Detail" de xem chi tiet danh sach phieu cho duyet.' -ForegroundColor Gray
}

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '                HOAN TAT KIEM TRA SUC KHOE HE THONG' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
