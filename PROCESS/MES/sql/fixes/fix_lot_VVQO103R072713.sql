-- =============================================
-- Fix: Lot VVQO103R072713 - Xóa V-28_BG + Reset CompleteRoute V-26_BG
-- ControlNo: 20260610000149
-- Ngày: 2026-06-19
-- =============================================

BEGIN TRAN

-- 1. Kiểm tra trước
PRINT '=== TRƯỚC KHI FIX ==='
SELECT ProdRouteHistNo, RouteCode, ProdQty, CompleteRoute, CreateDateTime
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo = '20260610000149'
ORDER BY RouteCode

-- 2. Xóa V-28_BG
DELETE FROM STB_ProdRouteHist
WHERE ProdRouteHistNo = '20260616000608'
  AND ControlNo = '20260610000149'
  AND RouteCode = 'V-28_BG'

PRINT '=== Đã xóa ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record V-28_BG ==='

-- 3. Update CompleteRoute V-26_BG về NULL
UPDATE STB_ProdRouteHist
SET CompleteRoute = NULL,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin'
WHERE ProdRouteHistNo = '20260616000190'
  AND ControlNo = '20260610000149'
  AND RouteCode = 'V-26_BG'

PRINT '=== Đã update ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record V-26_BG ==='

-- 4. Kiểm tra sau
PRINT '=== SAU KHI FIX ==='
SELECT ProdRouteHistNo, RouteCode, ProdQty, CompleteRoute, CreateDateTime
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo = '20260610000149'
ORDER BY RouteCode

-- ĐỔI THÀNH COMMIT TRAN KHI ĐÃ KIỂM TRA OK
ROLLBACK TRAN
