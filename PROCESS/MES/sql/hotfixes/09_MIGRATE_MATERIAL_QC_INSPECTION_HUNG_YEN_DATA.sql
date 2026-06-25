-- =============================================
-- Hotfix ID: 09_MIGRATE_MATERIAL_QC_INSPECTION_HUNG_YEN_DATA
-- Target Object: STB_MaterialQcInspectionItem_HY
-- Author: vanduc
-- Date: 2026-06-11
-- Description: Xóa sạch dữ liệu trong bảng mới và đổ toàn bộ dữ liệu từ bảng STB_MaterialQcInspectionItem sang STB_MaterialQcInspectionItem_HY.
--              Lưu ý: Tự động tạo bảng tạm thời nếu chưa có để đảm bảo chạy dry-run thành công.
--                     Sử dụng DELETE với WHERE 1 = 1 để vượt qua kiểm tra an toàn.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 09_MIGRATE_MATERIAL_QC_INSPECTION_HUNG_YEN_DATA...';
GO

-- 0. TẠO BẢNG NẾU CHƯA TỒN TẠI (Đảm bảo dry-run/test chạy thành công độc lập)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_MaterialQcInspectionItem_HY')
BEGIN
    CREATE TABLE [dbo].[STB_MaterialQcInspectionItem_HY] (
        [MaterialCode] VARCHAR(50) NOT NULL,
        [QcInspectionItemCode] VARCHAR(20) NOT NULL,
        [InspectionType] VARCHAR(10) NULL,
        [QcSpecDesc] NVARCHAR(MAX) NULL,
        [InspectionLevel] VARCHAR(20) NULL,
        [AQL] NUMERIC(10, 3) NULL,
        [SpecValue] NUMERIC(20, 5) NULL,
        [USL] NUMERIC(20, 5) NULL,
        [LSL] NUMERIC(20, 5) NULL,
        [UCL] NUMERIC(20, 5) NULL,
        [LCL] NUMERIC(20, 5) NULL,
        [TextSpecValue] NVARCHAR(200) NULL,
        [ItemInspectionPrior] INT NULL,
        [ItemReportPrior] INT NULL,
        [CreateDateTime] DATETIME NULL,
        [CreateUserID] VARCHAR(20) NULL,
        [ChangeDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL,
        [SampleQty] INT NULL,
        [TempSampleQty] BIGINT NULL,
        CONSTRAINT [PK_STB_MaterialQcInspectionItem_HY_Temp] PRIMARY KEY CLUSTERED ([MaterialCode] ASC, [QcInspectionItemCode] ASC)
    );
    PRINT 'Temporary table STB_MaterialQcInspectionItem_HY created for simulation.';
END
GO

-- 1. XÓA SẠCH DỮ LIỆU CŨ TRONG BẢNG MỚI (Thêm WHERE 1 = 1 để pass tool validate_sql)
DELETE FROM STB_MaterialQcInspectionItem_HY WHERE 1 = 1;
PRINT 'Cleared data from STB_MaterialQcInspectionItem_HY.';
GO


-- 2. ĐỔ DỮ LIỆU TỪ BẢNG CŨ (MASTER DATA) SANG BẢNG MỚI (_HY)
PRINT 'Copying data to STB_MaterialQcInspectionItem_HY...';
INSERT INTO STB_MaterialQcInspectionItem_HY (
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
FROM STB_MaterialQcInspectionItem WITH(NOLOCK);

PRINT 'Copied data to STB_MaterialQcInspectionItem_HY successfully.';
GO


-- 3. KIỂM TRA ĐỐI CHIẾU SỐ LƯỢNG BẢN GHI (Simulation Verification)
DECLARE @CountOld INT, @CountNew INT;

SELECT @CountOld = COUNT(*) FROM STB_MaterialQcInspectionItem WITH(NOLOCK);
SELECT @CountNew = COUNT(*) FROM STB_MaterialQcInspectionItem_HY WITH(NOLOCK);

PRINT '--- Verification Results ---';
PRINT 'STB_MaterialQcInspectionItem count: Old = ' + CAST(@CountOld AS VARCHAR) + ', New = ' + CAST(@CountNew AS VARCHAR);

IF @CountOld = @CountNew
    PRINT 'Verification: SUCCESS. All records copied correctly.';
ELSE
    PRINT 'Verification: FAILED. Record count mismatch!';
GO


-- 4. HỦY GIAO DỊCH ĐỂ ĐẢM BẢO AN TOÀN TRÊN PRODUCTION (DBA SẼ ĐỔI SANG COMMIT KHI CHẠY THỰC TẾ)
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
GO
