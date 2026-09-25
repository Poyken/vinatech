-- ==============================================================================
-- TEMPLATE: CLONE DEFECT GROUP (ĐĂNG KÝ VÀ NHÂN BẢN MÃ PHẾ CHO CÔNG ĐOẠN MỚI)
-- Reference: POP_KB_03 Case 2 | HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI
-- Author / ChangeUserID: vanduc
-- Created At: {{DATE_CREATED}}
-- Issue Code: {{ISSUE_CODE}}
-- Target: Đăng ký STB_DefectGroup và clone STB_DefectInfo từ nhóm chuẩn sang nhóm mới
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra nhóm nguồn và nhóm đích)
DECLARE @SourceGroup VARCHAR(50) = '<NHÓM_NGUỒN>'; -- VD: 'V-11'
DECLARE @TargetGroup VARCHAR(50) = '<NHÓM_ĐÍCH>';  -- VD: 'V-11_HY'

SELECT DefectGroupCode, BasicDefectGroupName, IsUsed, CreateUserID, CreateDateTime
FROM SmartFactoryV2.dbo.STB_DefectGroup WITH(NOLOCK)
WHERE DefectGroupCode IN (@SourceGroup, @TargetGroup);

SELECT COUNT(1) AS TotalDefectsSource
FROM SmartFactoryV2.dbo.STB_DefectInfo WITH(NOLOCK)
WHERE DefectGroupCode = @SourceGroup;
GO

-- 2. THỰC THI CLONE MÃ LỖI AN TOÀN
BEGIN TRAN;

DECLARE @SourceGroup VARCHAR(50) = '<NHÓM_NGUỒN>';     -- VD: 'V-11'
DECLARE @TargetGroup VARCHAR(50) = '<NHÓM_ĐÍCH>';      -- VD: 'V-11_HY'
DECLARE @GroupName   VARCHAR(100) = '<TÊN_NHÓM_LỖI>';  -- VD: 'SLITTING'

-- 2.1 Đăng ký nhóm lỗi nếu chưa tồn tại
IF NOT EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_DefectGroup WHERE DefectGroupCode = @TargetGroup)
BEGIN
    INSERT INTO SmartFactoryV2.dbo.STB_DefectGroup (
        DefectGroupCode, BasicDefectGroupName, IsUsed, CreateUserID, CreateDateTime
    )
    VALUES (
        @TargetGroup, @GroupName, 1, 'vanduc', GETDATE()
    );
    PRINT '-> Đã thêm mới nhóm lỗi: ' + @TargetGroup;
END
ELSE
BEGIN
    PRINT '-> Nhóm lỗi ' + @TargetGroup + ' đã tồn tại.';
END

-- 2.2 Clone danh mục mã phế con từ nhóm nguồn sang nhóm đích
INSERT INTO SmartFactoryV2.dbo.STB_DefectInfo (
    DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, UseGroup, DisplayIndex,
    IsRealDefect, IsUsed, DefectImage, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,
    DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
)
SELECT 
    REPLACE(DefectCode, @SourceGroup + '_', @TargetGroup + '_'),
    BasicDefectName, DefectDesc, @TargetGroup, UseGroup, DisplayIndex,
    IsRealDefect, IsUsed, DefectImage, GETDATE(), 'vanduc', NULL, NULL,
    DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
FROM SmartFactoryV2.dbo.STB_DefectInfo WITH(NOLOCK)
WHERE DefectGroupCode = @SourceGroup
  AND NOT EXISTS (
      SELECT 1 FROM SmartFactoryV2.dbo.STB_DefectInfo 
      WHERE DefectCode = REPLACE(STB_DefectInfo.DefectCode, @SourceGroup + '_', @TargetGroup + '_')
  );

DECLARE @RowsCloned INT = @@ROWCOUNT;
PRINT '-> Số mã lỗi chi tiết được nhân bản sang ' + @TargetGroup + ': ' + CAST(@RowsCloned AS VARCHAR(10));

-- Đổi ROLLBACK thành COMMIT sau khi kiểm tra
ROLLBACK TRAN;
-- COMMIT TRAN;
PRINT '-> [XÁC MINH] Hãy kiểm tra kỹ trước khi đổi ROLLBACK thành COMMIT TRAN!';
GO
