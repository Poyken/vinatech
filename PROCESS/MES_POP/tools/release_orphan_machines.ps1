# ==============================================================================
# release_orphan_machines.ps1 — Auto Release Orphan Machine Locks in POP DB
# Giải phóng máy bị kẹt ACTIVE ở DayPlan cũ trên Kiosk POP
# Tham chiếu: POP_KB_03 § Template 10, POP_KB_06 § 2.2
# ==============================================================================

param(
    [string]$Target = '',
    [switch]$Force
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$conn = Get-DbConnection -Profile 'POP'
if ($null -eq $conn) {
    Write-Host "LOI: Khong the ket noi toi CSDL VINATECH_POP!" -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     GIAI PHONG KHOA MAY TREO (AUTO RELEASE ORPHAN LOCKS)" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan

$lineFilter = ""
if (-not [string]::IsNullOrWhiteSpace($Target)) {
    $lineFilter = "AND LINE_CODE = '$Target'"
    Write-Host "Dang loc theo Line: $Target" -ForegroundColor Gray
}

# 1. Tìm các bản ghi bị kẹt
$sqlSurvey = @"
SELECT 
    MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS, MAPPED_AT
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
  $lineFilter
  AND (
      LEFT(DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112)
      OR MAPPED_AT < DATEADD(HOUR, -12, GETDATE())
  )
ORDER BY LINE_CODE, MAPPED_AT;
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sqlSurvey
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null

$count = $dt.Rows.Count
$color = if ($count -gt 0) { "Yellow" } else { "Green" }
Write-Host "Phat hien: $count thiet bi bi treo khoa o ke hoach cu." -ForegroundColor $color

if ($count -eq 0) {
    Write-Host "He thong sach se. Khong co may nao can giai phong." -ForegroundColor Green
    $conn.Close()
    exit 0
}

# In bảng
$format = "{0,-10} | {1,-14} | {2,-10} | {3,-8} | {4,-12} | {5,-20}"
Write-Host ([string]::Format($format, "MappingID", "DayPlanNo", "LineCode", "Route", "EquipmentID", "MappedAt")) -ForegroundColor Cyan
Write-Host ('-' * 85) -ForegroundColor Gray

foreach ($row in $dt.Rows) {
    Write-Host ([string]::Format($format, $row["MAPPING_ID"], $row["DAY_PLAN_NO"], $row["LINE_CODE"], $row["ROUTE_CODE"], $row["EQUIPMENT_ID"], $row["MAPPED_AT"])) -ForegroundColor White
}
Write-Host ('-' * 85) -ForegroundColor Gray

if (-not $Force) {
    Write-Host ''
    Write-Host '[DRY-RUN] Day la che do khao sat an toan. Chua co du lieu nao bi thay doi.' -ForegroundColor Yellow
    Write-Host 'De thuc thi giai phong cac may tren, chay:' -ForegroundColor Cyan
    $targetFlag = if ($Target) { "-Target $Target " } else { '' }
    Write-Host "  .\mes.ps1 release-machines $targetFlag-Force" -ForegroundColor Green
    $conn.Close()
    exit 0
}

# 2. Thực thi giải phóng (nếu có -Force)
Write-Host ''
Write-Host "Dang thuc thi giai phong thiet bi..." -ForegroundColor Yellow

$whereClause = "MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED') $lineFilter AND (LEFT(DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112) OR MAPPED_AT < DATEADD(HOUR, -12, GETDATE()))"
Export-PreflightSnapshot -TableName "VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING" -WhereClause $whereClause -Profile "POP" -Reason "release_orphan_machines"

$sqlUpdate = @"
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING
    SET MAPPING_STATUS      = 'RELEASED',
        RELEASED_AT         = GETDATE(),
        RELEASE_REASON      = N'Auto-release orphan lock (CLI)',
        NO_EMP_MODIFYER     = 'mes_cli',
        CD_COMPANY_MODIFYER = 'VINA'
    WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
      $lineFilter
      AND (
          LEFT(DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112)
          OR MAPPED_AT < DATEADD(HOUR, -12, GETDATE())
      );

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

Write-Host "DA GIAI PHONG THANH CONG: $updated thiet bi!" -ForegroundColor Green
Write-Host "Cac may nay hien da san sang duoc chon tren Kiosk POP ca moi." -ForegroundColor Cyan

$conn.Close()
