-- ==============================================================================
-- TEMPLATE: FIX ELECTRODE THICKNESS (ĐIỀU CHỈNH ĐỘ DÀY ĐIỆN CỰC MỞ KHÓA NÚT CẮT)
-- Reference: POP_KB_03 Case 17 | RULE 20 (POP BẤT BIẾN - EA PLAYBOOK)
-- Author / ChangeUserID: vanduc
-- Created At: {{DATE_CREATED}}
-- Issue Code: {{ISSUE_CODE}}
-- Target: Kiểm tra và hiệu chỉnh MaterialThickness >= 100 trong STB_MaterialMaster
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra độ dày màng điện cực hiện tại của Lot)
DECLARE @Barcode VARCHAR(50) = '<MÃ_LOT>'; -- VD: 'VWQQ2609501E13'

SELECT 
    SI.Barcode, SI.DayPlanNo, SI.MaterialCode, MM.MaterialName, 
    MM.MaterialThickness, MM.MaterialTypeCode,
    CASE 
        WHEN MM.MaterialThickness < 100 THEN N'KHÓA (Độ dày < 100 um)' 
        ELSE N'HỢP LỆ (Độ dày >= 100 um)' 
    END AS CutButtonStatus
FROM SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK) ON SI.MaterialCode = MM.MaterialCode
WHERE SI.Barcode = @Barcode;
GO

-- 2. THỰC THI ĐIỀU CHỈNH ĐỘ DÀY (Nếu master data khai báo sai thông số)
BEGIN TRAN;

DECLARE @MaterialCode VARCHAR(50) = '<MÃ_VẬT_TƯ>'; -- VD: 'CRPSC5-005'
DECLARE @CorrectThickness NUMERIC(10,2) = 110.00;    -- Độ dày thực tế chuẩn (>= 100)

UPDATE MM
SET 
    MM.MaterialThickness = @CorrectThickness,
    MM.ChangeDateTime    = GETDATE(),
    MM.ChangeUserID      = 'vanduc'
FROM SmartFactoryV2.dbo.STB_MaterialMaster MM
WHERE MM.MaterialCode = @MaterialCode
  AND MM.MaterialThickness < 100;

DECLARE @RowsUpdated INT = @@ROWCOUNT;
PRINT '-> Số dòng STB_MaterialMaster được điều chỉnh độ dày: ' + CAST(@RowsUpdated AS VARCHAR(10));

-- Đổi ROLLBACK thành COMMIT sau khi kiểm tra
ROLLBACK TRAN;
-- COMMIT TRAN;
PRINT '-> [XÁC MINH] Hãy kiểm tra kỹ trước khi đổi ROLLBACK thành COMMIT TRAN!';
GO
