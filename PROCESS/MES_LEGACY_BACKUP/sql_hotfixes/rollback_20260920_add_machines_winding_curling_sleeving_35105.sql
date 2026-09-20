-- ==============================================================================
-- ROLLBACK SCRIPT: ROLLBACK_ADD_MACHINES_WINDING_CURLING_SLEEVING_35105
-- Mục đích: Khôi phục trạng thái ban đầu của STB_ProductMachine cho các Line Cell Hưng Yên
--   - Xóa bỏ các máy mapping bổ sung có CreateUserID = 'vanduc' tạo ngày hôm nay
--   - Khôi phục tên hiển thị VVMHY96 về 'Sleeving C#7' nếu cần
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Khôi phục tên máy VVMHY96 trong STB_MachineMaster
UPDATE STB_MachineMaster
SET MachineName = 'Sleeving C#7',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE MachineCode = 'VVMHY96' 
  AND MachineName = 'Sleeving C#6';

-- 2. Xóa các bản ghi đã thêm trong STB_ProductMachine
DELETE FROM STB_ProductMachine
WHERE CreateUserID = 'vanduc'
  AND CreateDateTime >= '2026-09-20'
  AND LineCode IN ('VVHYC-01', 'VVHYC-02', 'VVHYC-03', 'VVHYC-04', 'VVHYC-05', 'VVHYC-06', 'VVHYC-07', 'VVHYC-09', 'VVHYC-10')
  AND RouteCode IN ('V-22_HY', 'V-24_HY', 'V-25_HY');

COMMIT TRANSACTION;
GO
