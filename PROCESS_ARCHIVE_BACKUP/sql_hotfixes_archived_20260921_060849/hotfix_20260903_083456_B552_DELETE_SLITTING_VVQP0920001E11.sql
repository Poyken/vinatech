-- ==============================================================================
-- HOTFIX SCRIPT: B552_DELETE_SLITTING_VVQP0920001E11
-- Date: 2026-09-03 08:34:56
-- Target Database: SmartFactoryV2
-- Standard: KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #2 & HOTFIX_LOG.md § ID_29, ID_36
-- Purpose: Xóa 10 bản ghi kết quả cắt điện cực thừa (STT 16-25) cho Lot VVQP0920001E11
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [BEFORE] SELECT KHẢO SÁT 10 BẢN GHI CẦN XÓA (SEQ 16 - 25)
SELECT 
    Seq, ElectrodeLotNumber, Barcode, SlittingWidth, GoodQtyLength, CreateDateTime, CreateUserID
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQP0920001E11' AND Seq BETWEEN 16 AND 25
ORDER BY Seq ASC;

-- 2. [AUDIT LOG] GHI LƯU VẾT LỊCH SỬ TRƯỚC KHI XÓA (CHUẨN SOP KB_09 § B552)
INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
SELECT ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQP0920001E11' AND Seq BETWEEN 16 AND 25;

-- 3. [EXECUTION] XÓA 10 BẢN GHI CẮT THỪA
DELETE FROM STB_ElectrodeSlittingResult
WHERE ElectrodeLotNumber = 'VVQP0920001E11' AND Seq BETWEEN 16 AND 25;

-- 4. [AFTER] KIỂM TRA LẠI DỮ LIỆU CÒN LẠI CỦA LOT (GIỮ LẠI ĐÚNG SEQ 1 - 15)
SELECT 
    Seq, ElectrodeLotNumber, Barcode, SlittingWidth, GoodQtyLength, CreateDateTime
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQP0920001E11'
ORDER BY Seq ASC;

-- 5. [COMMIT XÁC NHẬN TRIỂN KHAI THEO YÊU CẦU]
COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;
GO
