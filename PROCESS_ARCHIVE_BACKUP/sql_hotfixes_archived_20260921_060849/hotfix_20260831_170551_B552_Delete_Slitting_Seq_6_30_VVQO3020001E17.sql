-- ==============================================================================
-- HOTFIX SCRIPT: B552_Delete_Slitting_Seq_6_30_VVQO3020001E17
-- Screen: [B552] Vietnam_Kết quả đo điện cực (Tab Slitting - Cắt điện cực)
-- Reference: KB_09_SCREEN_BUG_FIXBOOK.md Line 210 / HOTFIX_LOG.md ID_29
-- Target Database: SmartFactoryV2
-- Lot Number: VVQO3020001E17
-- Action: Backup history log & Delete Slitting result records Seq 6 to 30 (25 rows)
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [BEFORE] Khảo sát hiện trạng các bản ghi cần xóa (Seq 6 -> 30)
SELECT 
    ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty, CreateDateTime, CreateUserID
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQO3020001E17'
  AND Seq BETWEEN 6 AND 30
ORDER BY Seq ASC;

-- 2. [BACKUP/AUDIT] Ghi vết vào bảng lịch sử theo chuẩn KB_09
INSERT INTO STB_ElectrodeSlittingResultHist (
    ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID
)
SELECT 
    ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQO3020001E17'
  AND Seq BETWEEN 6 AND 30;

-- 3. [EXECUTION] Xóa dữ liệu dư thừa
DELETE FROM STB_ElectrodeSlittingResult
WHERE ElectrodeLotNumber = 'VVQO3020001E17'
  AND Seq BETWEEN 6 AND 30;

-- Kiểm tra số dòng bị tác động (Kỳ vọng: 25 dòng)
DECLARE @DeletedRows INT = @@ROWCOUNT;
IF @DeletedRows <> 25
BEGIN
    RAISERROR(N'Cảnh báo: Số dòng xóa không khớp (Kỳ vọng 25 dòng, thực tế %d dòng). Hủy thao tác!', 16, 1, @DeletedRows);
    ROLLBACK TRANSACTION;
    RETURN;
END

-- 4. [AFTER] Kiểm tra lại kết quả sau khi xóa (chỉ còn lại Seq 1 -> 5)
SELECT 
    ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty, CreateDateTime, CreateUserID
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQO3020001E17'
ORDER BY Seq ASC;

-- 5. [CONTROL] Xác nhận áp dụng thay đổi
COMMIT TRANSACTION;
GO
