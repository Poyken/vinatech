-- ==============================================================================
-- HOTFIX SCRIPT: B552_DELETE_MIXING_VVQR0120001E38
-- Date: 2026-09-03 08:46:59
-- Target Database: SmartFactoryV2
-- Standard: KB_05_01_QC_AND_ELECTRODE_CORE.md § 8.10 & KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #3
-- Purpose: Xóa dọn dẹp mẻ trộn điện cực thừa / hủy (Mixing) cho Lot VVQR0120001E38
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [BEFORE] KHẢO SÁT HIỆN TRẠNG TRƯỚC KHI XÓA
SELECT 'STB_ElectrodeMixStepInfo' AS TableName, COUNT(*) AS RecordCount 
FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQR0120001E38'
UNION ALL
SELECT 'STB_ElectrodeMixInfo', COUNT(*) 
FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQR0120001E38'
UNION ALL
SELECT 'STB_SetInfo', COUNT(*) 
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'VVQR0120001E38';

-- 2. [EXECUTION] THỰC HIỆN CASCADE DELETE THEO ĐÚNG THỨ TỰ SOP
-- 2.1 Xóa chi tiết các bước cân nguyên vật liệu (10 bước cân)
DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQR0120001E38';

-- 2.2 Xóa header mẻ trộn điện cực (1 bản ghi)
DELETE FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQR0120001E38';

-- 2.3 Xóa mã khởi tạo Lot thùng / SetInfo (1 bản ghi)
DELETE FROM STB_SetInfo WHERE Barcode = 'VVQR0120001E38';

-- 3. [AFTER] KIỂM TRA LẠI (TẤT CẢ PHẢI VỀ 0)
SELECT 'STB_ElectrodeMixStepInfo' AS TableName, COUNT(*) AS RecordCount 
FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQR0120001E38'
UNION ALL
SELECT 'STB_ElectrodeMixInfo', COUNT(*) 
FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQR0120001E38'
UNION ALL
SELECT 'STB_SetInfo', COUNT(*) 
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'VVQR0120001E38';

-- 4. [COMMIT XÁC NHẬN TRIỂN KHAI THEO YÊU CẦU]
COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;
GO
