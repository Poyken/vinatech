-- ==============================================================================
-- HOTFIX SCRIPT: DISABLE_FIFO_CUWIRE_01
-- Date: 2026-09-07
-- Target Database: SmartFactoryV2
-- Single Source of Truth: Follows Rules in .agents (UTF-8-BOM / BEGIN TRAN...ROLLBACK)
-- Mục đích: Tắt kiểm tra FIFO cho mã nguyên vật liệu CUWIRE-01
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [BEFORE] Khảo sát hiện trạng thuộc tính quản lý kho của mã CUWIRE-01
SELECT 
    MaterialCode, IsFIFO, IsLotUse, IsUseBarcode, ChangeDateTime, ChangeUserID
FROM STB_MaterialStockAttributeInfo WITH(NOLOCK)
WHERE MaterialCode = 'CUWIRE-01';

-- 2. [EXECUTION] Tắt cờ IsFIFO về 0 (False)
UPDATE STB_MaterialStockAttributeInfo
SET 
    IsFIFO = 0,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'IT_SUPPORT'
WHERE MaterialCode = 'CUWIRE-01';

-- 3. [AFTER] Kiểm tra lại sau khi cập nhật
SELECT 
    MaterialCode, IsFIFO, IsLotUse, IsUseBarcode, ChangeDateTime, ChangeUserID
FROM STB_MaterialStockAttributeInfo WITH(NOLOCK)
WHERE MaterialCode = 'CUWIRE-01';

-- 4. [CONTROL] Mặc định ROLLBACK để kiểm thử (chuyển sang COMMIT khi chạy chính thức)
ROLLBACK TRANSACTION;
-- COMMIT TRANSACTION;
GO
