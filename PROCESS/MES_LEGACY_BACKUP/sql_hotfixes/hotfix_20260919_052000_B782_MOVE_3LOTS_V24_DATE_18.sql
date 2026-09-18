-- ==============================================================================
-- HOTFIX SCRIPT: B782_MOVE_3LOTS_V24_DATE_18
-- Mục đích: Chuyển "Ngày làm" (JobDate) của 3 Lot công đoạn V-24_HY (Curling) sang ngày 18/09/2026
-- Danh sách 3 Barcode: VVQR153R825705, VVQR153R825708, VVQR153R825713
-- Danh sách 3 ControlNo: 20260915000222, 20260915000225, 20260915000619
-- Tham chiếu: KB_03_01_OVERVIEW.md § 5.2, KB_09_SCREEN_BUG_FIXBOOK.md § [B782], HOTFIX_LOG.md § ID_50, ID_52
-- Pre-flight Backup:
--   - tools/backups/preflight_20260919_051811_STB_ProdRouteHist_backup_b782_3lots_v24_move_to_18.json (3 records)
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Cập nhật Ngày làm (JobDate) sang 2026-09-18 cho công đoạn V-24_HY
UPDATE STB_ProdRouteHist 
SET JobDate = '2026-09-18',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260915000222', '20260915000225', '20260915000619')
  AND RouteCode = 'V-24_HY';

-- 2. Xác minh dữ liệu sau cập nhật trong Transaction
SELECT ControlNo, RouteCode, JobDate, ShiftCode, ProdDateTime, ProdQty, CompleteRoute 
FROM STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo IN ('20260915000222', '20260915000225', '20260915000619')
  AND RouteCode = 'V-24_HY'
ORDER BY ProdDateTime;

COMMIT TRANSACTION;
GO
