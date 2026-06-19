-- =============================================
-- FIX: Xóa lỗi (defect) cho barcode K16418106262500772 trên màn B530
-- Barcode: K16418106262500772
-- ControlNo: 20260618000445
-- Ngày: 2026-06-19
-- =============================================

BEGIN TRAN

-- 1. Kiểm tra trước khi xóa
PRINT '=== TRƯỚC KHI XÓA ==='
SELECT DefectSummaryNo, ControlNo, DefectCode, DefectQty, RepairQty, LossQty, IsDelete, FindRouteCode, CreateDateTime, CreateUserID
FROM STB_DefectRepairInfo WITH(NOLOCK)
WHERE ControlNo = '20260618000445'
  AND IsDelete = '0'

-- 2. Xóa mềm (set IsDelete = 1) các bản ghi defect
UPDATE STB_DefectRepairInfo
SET IsDelete = '1',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'ducnv_fix'
WHERE ControlNo = '20260618000445'
  AND DefectSummaryNo IN ('20260619000834', '20260619000835')
  AND IsDelete = '0'

PRINT '=== Đã cập nhật ' + CAST(@@ROWCOUNT AS VARCHAR) + ' bản ghi ==='

-- 3. Kiểm tra sau khi xóa
PRINT '=== SAU KHI XÓA ==='
SELECT DefectSummaryNo, ControlNo, DefectCode, DefectQty, IsDelete, ChangeDateTime, ChangeUserID
FROM STB_DefectRepairInfo WITH(NOLOCK)
WHERE ControlNo = '20260618000445'

-- ĐỔI THÀNH COMMIT TRAN KHI ĐÃ KIỂM TRA OK
ROLLBACK TRAN
