# ==============================================================================
# unlock_machine.ps1 — 1-Shot Machine Unlock Engine for POP Kiosk (VINATECH_POP)
# Tự động tìm, hiển thị trạng thái và giải phóng máy bị kẹt ACTIVE trên POP Kiosk
# Author: vanduc (EA Team)
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Machine,
    
    [string]$Line = '',
    [switch]$Deploy,
    [switch]$Force
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$sw = [System.Diagnostics.Stopwatch]::StartNew()

$conn = Get-DbConnection -Profile 'POP'
if ($null -eq $conn) {
    Write-Host "LOI: Khong the ket noi toi CSDL VINATECH_POP!" -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     [POP UNLOCK] GIAI PHONG THIET BI POP KIOSK (1-SHOT)" -ForegroundColor Yellow
Write-Host "     Tu khoa may: '$Machine'" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Tìm bản ghi thiết bị
$cleanMachine = $Machine.Replace("'", "''").Trim()
$lineFilter = ""
if (![string]::IsNullOrWhiteSpace($Line)) {
    $cleanLine = $Line.Replace("'", "''").Trim()
    $lineFilter = "AND LINE_CODE = '$cleanLine'"
}

$sqlSearch = @"
SELECT 
    MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, 
    MAPPING_STATUS, MAPPED_BY, MAPPED_AT, RELEASED_AT, RELEASE_REASON
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
WHERE (EQUIPMENT_NAME LIKE '%$cleanMachine%' OR EQUIPMENT_ID LIKE '%$cleanMachine%')
  $lineFilter
ORDER BY MAPPED_AT DESC;
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sqlSearch
$cmd.CommandTimeout = 15
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null

if ($dt.Rows.Count -eq 0) {
    Write-Host "(!) KHONG TIM THAY THIET BI nao khop voi tu khoa: '$Machine'" -ForegroundColor Red
    $conn.Close()
    exit 0
}

Write-Host "Tim thay $($dt.Rows.Count) ban ghi thiet bi:" -ForegroundColor Cyan
$format = "{0,-10} | {1,-14} | {2,-10} | {3,-10} | {4,-12} | {5,-18} | {6,-10}"
Write-Host ([string]::Format($format, "MappingID", "DayPlanNo", "LineCode", "Route", "EquipID", "EquipName", "Status")) -ForegroundColor Yellow
Write-Host ('-' * 95) -ForegroundColor Gray

foreach ($row in $dt.Rows) {
    $stColor = if ($row["MAPPING_STATUS"] -eq 'ACTIVE') { "Red" } else { "Green" }
    Write-Host ([string]::Format($format, $row["MAPPING_ID"], $row["DAY_PLAN_NO"], $row["LINE_CODE"], $row["ROUTE_CODE"], $row["EQUIPMENT_ID"], $row["EQUIPMENT_NAME"], $row["MAPPING_STATUS"])) -ForegroundColor $stColor
}
Write-Host ('-' * 95) -ForegroundColor Gray

# Lọc các máy đang bị khóa ACTIVE
$activeRows = $dt.Select("MAPPING_STATUS = 'ACTIVE' OR MAPPING_STATUS = 'AUTO_MAPPED'")

if ($activeRows.Count -eq 0) {
    Write-Host ""
    Write-Host "[OK] Tat ca may tren deu da o trang thai RELEASED (San sang su dung). Khong can mo khoa!" -ForegroundColor Green
    $conn.Close()
    exit 0
}

$targetMappingIds = ($activeRows | ForEach-Object { $_["MAPPING_ID"] }) -join ","
$targetEquipNames = ($activeRows | ForEach-Object { "$($_['EQUIPMENT_NAME']) ($($_['EQUIPMENT_ID']))" }) -join ", "

Write-Host ""
Write-Host "CANH BAO: Phat hien $($activeRows.Count) thiet bi dang bi KHOA (ACTIVE): $targetEquipNames" -ForegroundColor Red
Write-Host "Mapping ID: $targetMappingIds" -ForegroundColor Yellow

# Nếu có tham số -Deploy hoặc -Force -> Thực thi cập nhật ngay
if ($Deploy -or $Force) {
    Write-Host ""
    Write-Host "[THUC THI] Dang giai phong thiet bi..." -ForegroundColor Yellow
    
    $whereClause = "MAPPING_ID IN ($targetMappingIds) AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')"
    Export-PreflightSnapshot -TableName "VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING" -WhereClause $whereClause -Profile "POP" -Reason "unlock_machine" | Out-Null

    $sqlUpdate = @"
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING
    SET MAPPING_STATUS      = 'RELEASED',
        RELEASED_AT         = GETDATE(),
        RELEASE_REASON      = N'IT unlock machine by CLI (vanduc)',
        NO_EMP_MODIFYER     = 'vanduc',
        CD_COMPANY_MODIFYER = 'VINA'
    WHERE MAPPING_ID IN ($targetMappingIds)
      AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

    DECLARE @Rows INT = @@ROWCOUNT;
    COMMIT TRANSACTION;
    SELECT @Rows AS UpdatedRows;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
"@

    $cmdUpdate = $conn.CreateCommand()
    $cmdUpdate.CommandText = $sqlUpdate
    $updated = $cmdUpdate.ExecuteScalar()

    $sw.Stop()
    Write-Host ""
    Write-Host "DA GIAI PHONG THANH CONG: $updated thiet bi trong $($sw.ElapsedMilliseconds) ms!" -ForegroundColor Green
    Write-Host "Cac may [$targetEquipNames] hien da san sang de OP chon tren Kiosk POP." -ForegroundColor Cyan
} else {
    $sw.Stop()
    Write-Host ""
    Write-Host "[DRY-RUN] Thoi gian tra cuu: $($sw.ElapsedMilliseconds) ms. Du lieu chua thay doi." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "DE THUC THI GIAI PHONG NGAY, CHAY LENH:" -ForegroundColor Cyan
    Write-Host "  .\mes.ps1 unlock `"$Machine`" -Deploy" -ForegroundColor Green
    Write-Host ""
    Write-Host "HOAC COPY SCRIPT SQL HOTFIX CHUAN (Author: vanduc):" -ForegroundColor Cyan
    Write-Host @"
USE VINATECH_POP;
BEGIN TRANSACTION;
UPDATE dbo.VINA_EQUIPMENT_MAPPING
SET MAPPING_STATUS      = 'RELEASED',
    RELEASED_AT         = GETDATE(),
    RELEASE_REASON      = N'IT unlock machine by CLI (vanduc)',
    NO_EMP_MODIFYER     = 'vanduc',
    CD_COMPANY_MODIFYER = 'VINA'
WHERE MAPPING_ID IN ($targetMappingIds);
-- COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;
"@ -ForegroundColor Gray
}

$conn.Close()
