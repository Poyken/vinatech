-- ==============================================================================
-- HOTFIX SCRIPT: B782_MOVE_4LOTS_DATE_17_TO_18
-- Mục đích: Chuyển ngày ghi nhận sản xuất của 4 Lot trên màn hình B782 từ ngày 17 sang 18
-- Barcodes: VVQR153R825706, VVQR153R825707, VVQR153R825712, VVQR153R825714
-- ControlNos: 20260915000223, 20260915000224, 20260915000618, 20260915000620
-- Công đoạn điều chỉnh: V-23_HY (Rubber/Riveting), V-24_HY (Curling)
-- Tham chiếu: KB_03_01_OVERVIEW.md § 5.2, KB_09_SCREEN_BUG_FIXBOOK.md § [B782]
-- Pre-flight Backup: tools/backups/preflight_20260919_020445_STB_ProdRouteHist_backup_b782_move_date_17_to_18.json
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Cập nhật ProdDateTime và JobDate cho công đoạn V-23_HY (Lắp cao su/Rivet)
UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 10:05:00',
    JobDate = '2026-09-18',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260915000223', '20260915000224', '20260915000618', '20260915000620')
  AND RouteCode = 'V-23_HY';

-- 2. Cập nhật ProdDateTime và JobDate cho công đoạn V-24_HY (Cuốn mép)
UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 10:06:00',
    JobDate = '2026-09-18',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260915000223', '20260915000224', '20260915000618', '20260915000620')
  AND RouteCode = 'V-24_HY';

-- 3. Đồng bộ thời gian tạo phế NG trong STB_DefectRepairInfo cho V-23_HY
UPDATE STB_DefectRepairInfo 
SET CreateDateTime = '2026-09-18 10:05:00',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260915000223', '20260915000224', '20260915000618', '20260915000620')
  AND FindRouteCode = 'V-23_HY';

-- 4. Xác minh dữ liệu trong Transaction
SELECT ControlNo, RouteCode, ProdDateTime, JobDate, CompleteRoute 
FROM STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo IN ('20260915000223', '20260915000224', '20260915000618', '20260915000620')
  AND RouteCode IN ('V-23_HY', 'V-24_HY');

SELECT ControlNo, FindRouteCode, DefectQty, CreateDateTime 
FROM STB_DefectRepairInfo WITH(NOLOCK) 
WHERE ControlNo IN ('20260915000223', '20260915000224', '20260915000618', '20260915000620')
  AND FindRouteCode = 'V-23_HY';

COMMIT TRANSACTION;
GO
