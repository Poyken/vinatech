-- =================================================================================
-- Author: Antigravity
-- Date: 2026-06-15
-- Description: Đăng ký hạng mục kiểm tra chất lượng (QC inspection items) cho model LIVT38-037
--              để khắc phục lỗi "검사항목이 등록되어있지 않습니다" (Chưa đăng ký hạng mục kiểm tra)
--              khi tạo Lot kiểm định trên màn hình C512.
-- Safety Warning: Wrapped in a Transaction. Verify changes and change ROLLBACK to COMMIT.
-- =================================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY

    -- 1. Cập nhật cấu hình OqcType và OqcInspectionRuleType cho model LIVT38-037 trong STB_ModelBasicInfo
    PRINT 'Updating STB_ModelBasicInfo...';
    UPDATE STB_ModelBasicInfo
    SET OqcType = 'MANUAL',
        OqcInspectionRuleType = 'BY_MODEL'
    WHERE ModelCode = 'LIVT38-037';

    -- 2. Sao chép các hạng mục kiểm tra từ Model LIVT38-010 (VPC 0820) sang Model LIVT38-037
    PRINT 'Copying inspection items from LIVT38-010 to LIVT38-037...';
    
    -- Xóa các hạng mục cũ nếu có để tránh trùng lặp khóa chính
    DELETE FROM STB_MaterialQcInspectionItem WHERE MaterialCode = 'LIVT38-037';

    INSERT INTO STB_MaterialQcInspectionItem (
        MaterialCode,
        QcInspectionItemCode,
        InspectionType,
        QcSpecDesc,
        InspectionLevel,
        AQL,
        SpecValue,
        USL,
        LSL,
        UCL,
        LCL,
        TextSpecValue,
        ItemInspectionPrior,
        ItemReportPrior,
        CreateDateTime,
        CreateUserID,
        ChangeDateTime,
        ChangeUserID,
        SampleQty,
        TempSampleQty
    )
    SELECT 
        'LIVT38-037' AS MaterialCode,
        QcInspectionItemCode,
        InspectionType,
        QcSpecDesc,
        InspectionLevel,
        AQL,
        SpecValue,
        USL,
        LSL,
        UCL,
        LCL,
        TextSpecValue,
        ItemInspectionPrior,
        ItemReportPrior,
        GETDATE() AS CreateDateTime,
        'Antigravity' AS CreateUserID,
        NULL AS ChangeDateTime,
        NULL AS ChangeUserID,
        SampleQty,
        TempSampleQty
    FROM STB_MaterialQcInspectionItem WITH(NOLOCK)
    WHERE MaterialCode = 'LIVT38-010';

    -- 3. Xác minh kết quả sau khi update
    PRINT 'Verification:';
    SELECT ModelCode, OqcType, InspectionType, OqcInspectionRuleType 
    FROM STB_ModelBasicInfo WITH(NOLOCK)
    WHERE ModelCode = 'LIVT38-037';

    SELECT MaterialCode, QcInspectionItemCode, InspectionLevel, AQL, SpecValue, USL, LSL, UCL, LCL, TextSpecValue 
    FROM STB_MaterialQcInspectionItem WITH(NOLOCK)
    WHERE MaterialCode = 'LIVT38-037';

    -- Mặc định rollback để bảo vệ DB. Anh đổi sang COMMIT TRANSACTION khi muốn lưu.
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back successfully. (Change to COMMIT TRANSACTION to persist changes)';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error encountered, transaction rolled back.';
    THROW;
END CATCH
GO
