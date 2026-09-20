-- ==============================================================================
-- HOTFIX SCRIPT: FIX_B552_SLITTING_DEL_SEQ
-- Date: 2026-09-08 13:14:31
-- Target Database: SmartFactoryV2
-- Single Source of Truth: KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #2 & HOTFIX_LOG.md § ID_36, ID_39
-- Description: Xóa 40 bản ghi kết quả cắt điện cực (Seq 11-50) của Lot VVQR0720001E66
--              và 5 bản ghi kết quả cắt điện cực (Seq 16-20) của Lot VVQP0720001E11
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [AUDIT LOG] Ghi lưu vết lịch sử trước khi xóa (Chuẩn SOP KB_09 § B552)
INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
SELECT ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE (ElectrodeLotNumber = 'VVQR0720001E66' AND Seq BETWEEN 11 AND 50)
   OR (ElectrodeLotNumber = 'VVQP0720001E11' AND Seq BETWEEN 16 AND 20);

-- 2. [EXECUTION] Xóa 45 bản ghi cắt thừa theo yêu cầu người dùng
DELETE FROM STB_ElectrodeSlittingResult
WHERE (ElectrodeLotNumber = 'VVQR0720001E66' AND Seq BETWEEN 11 AND 50)
   OR (ElectrodeLotNumber = 'VVQP0720001E11' AND Seq BETWEEN 16 AND 20);

COMMIT TRANSACTION;
GO
