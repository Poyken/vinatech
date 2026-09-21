-- ==============================================================================
-- HOTFIX SCRIPT: {{ISSUE_CODE}}
-- Date: {{DATE_CREATED}}
-- Target Database: SmartFactoryV2
-- Single Source of Truth: Follows Rules in RULES.md (UTF-8-BOM / BEGIN TRAN...ROLLBACK)
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [BEFORE] SELECT KHẢO SÁT HIỆN TRẠNG
SELECT 
    LotID, MaterialCode, CurrentQty, ISNULL(HoldFlag,'N') AS HoldFlag, UpdateDate
FROM STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotID = N'YOUR_LOT_ID_HERE';

-- 2. [EXECUTION] CẬP NHẬT DỮ LIỆU
-- UPDATE STB_MaterialLotInfo
-- SET HoldFlag = 'N', UpdateDate = GETDATE()
-- WHERE LotID = N'YOUR_LOT_ID_HERE' AND HoldFlag = 'Y';

-- 3. [AFTER] SELECT KIỂM TRA LẠI KẾT QUẢ
-- SELECT 
--     LotID, MaterialCode, CurrentQty, ISNULL(HoldFlag,'N') AS HoldFlag, UpdateDate
-- FROM STB_MaterialLotInfo WITH(NOLOCK)
-- WHERE LotID = N'YOUR_LOT_ID_HERE';

-- 4. [CONTROL] MẶC ĐỊNH ROLLBACK ĐỂ KIỂM THỬ (CHUYỂN SANG COMMIT KHI CHẮC CHẮN)
ROLLBACK TRANSACTION;
-- COMMIT TRANSACTION;
GO
