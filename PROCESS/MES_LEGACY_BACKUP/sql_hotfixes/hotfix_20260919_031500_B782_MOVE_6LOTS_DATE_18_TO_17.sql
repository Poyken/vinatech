-- ==============================================================================
-- HOTFIX SCRIPT: B782_MOVE_6LOTS_DATE_18_TO_17
-- Mục đích: Chuyển ngày ghi nhận sản xuất của 6 Lot trên màn hình B782 từ ngày 18 về ngày 17
-- Barcodes: VVQR173R825701, VVQR173R825702, VVQR173R825703, VVQR173R825704, VVQR173R825705, VVQR173R825706
-- ControlNos: 20260917000445, 20260917000446, 20260917000447, 20260917000448, 20260917000449, 20260917000450
-- Công đoạn điều chỉnh: V-22_HY (Winding - Cuốn tại Hưng Yên VVT_F5)
-- Tham chiếu: KB_03_01_OVERVIEW.md § 5.2, KB_09_SCREEN_BUG_FIXBOOK.md § [B782], HOTFIX_LOG.md § ID_50
-- Pre-flight Backup:
--   - tools/backups/preflight_20260919_031122_STB_ProdRouteHist_backup_b782_move_date_18_to_17.json
--   - tools/backups/preflight_20260919_031123_STB_DefectRepairInfo_backup_b782_move_date_18_to_17.json
--   - tools/backups/preflight_20260919_031123_STB_SetInfo_backup_b782_move_date_18_to_17.json
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Cập nhật ProdDateTime và JobDate cho công đoạn V-22_HY (Quấn cuộn)
UPDATE STB_ProdRouteHist 
SET ProdDateTime = DATEADD(DAY, -1, ProdDateTime),
    JobDate = '2026-09-17',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')
  AND RouteCode = 'V-22_HY';

-- 2. Đồng bộ thời gian tạo phế NG trong STB_DefectRepairInfo cho V-22_HY
UPDATE STB_DefectRepairInfo 
SET CreateDateTime = DATEADD(DAY, -1, CreateDateTime),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')
  AND FindRouteCode = 'V-22_HY';

-- 3. Đồng bộ ngày nhập chuyền trong STB_SetInfo
UPDATE STB_SetInfo 
SET InputDateTime = DATEADD(DAY, -1, InputDateTime),
    InputJobDate = '2026-09-17',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450');

-- 4. Xác minh dữ liệu trong Transaction
SELECT ControlNo, RouteCode, ProdDateTime, JobDate, CompleteRoute 
FROM STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')
  AND RouteCode = 'V-22_HY';

SELECT ControlNo, FindRouteCode, DefectQty, CreateDateTime 
FROM STB_DefectRepairInfo WITH(NOLOCK) 
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')
  AND FindRouteCode = 'V-22_HY';

COMMIT TRANSACTION;
GO
