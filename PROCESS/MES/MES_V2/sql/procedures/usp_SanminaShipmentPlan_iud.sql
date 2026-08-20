-- =========================================================================================
-- Author     : Vinatech MES Standard
-- Create date: 2026-08-19
-- Description: Quản lý thiết lập Lô xuất Sanmina (B763) chuẩn SmartFramework Grid IUD
-- =========================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SanminaShipmentPlan_iud]') AND type in (N'P', N'PC'))
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SanminaShipmentPlan_iud] AS SELECT 1 AS Stub;'
GO

ALTER PROCEDURE [dbo].[usp_SanminaShipmentPlan_iud]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20) = 'vi-VN',
    @pProcessViewName VARCHAR(50) = 'SanminaShipmentPlan',
    @pXml NVARCHAR(MAX) = NULL,
    @pUtcOffset INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Khai báo các đường dẫn bảng trong XML chuẩn SmartFramework
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'SanminaShipmentPlan') + '_INSERT';
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'SanminaShipmentPlan') + '_UPDATE';
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'SanminaShipmentPlan') + '_DELETE';

    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @NowDateTime DATETIME = DATEADD(MINUTE, @pUtcOffset, GETDATE());
    DECLARE @iDoc INT;

    -- Chuẩn bị tài liệu XML
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        BEGIN TRANSACTION;

        -------------------------------------------------------
        -- 1. XỬ LÝ INSERT (Thêm mới từ Grid)
        -------------------------------------------------------
        INSERT INTO STB_SanminaShipmentPlan (
            PlanCode,
            PONumber,
            PartNumber,
            LotNo,
            QtyPerBox,
            TotalBox,
            PrintedBoxCount,
            IsActive,
            Status,
            Remark,
            CreateUserID,
            CreateDateTime
        )
        SELECT 
            'CFG-' + CONVERT(VARCHAR(8), @NowDateTime, 112) + '-' + RIGHT('000' + CAST(ISNULL((SELECT MAX(PlanID) FROM STB_SanminaShipmentPlan), 0) + ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS VARCHAR), 3),
            LTRIM(RTRIM(PONumber)),
            LTRIM(RTRIM(PartNumber)),
            NULLIF(LTRIM(RTRIM(LotNo)), ''),
            ISNULL(Quantity, 200),
            ISNULL(TotalBox, 1),
            0,
            ISNULL(IsActive, 1),
            CASE WHEN ISNULL(IsActive, 1) = 1 THEN 'ACTIVE' ELSE 'PENDING' END,
            Remark,
            @pProcessUserID,
            @NowDateTime
        FROM OPENXML(@iDoc, @InsertTableName, 2)
        WITH (
            PONumber VARCHAR(50),
            PartNumber VARCHAR(50),
            LotNo VARCHAR(50),
            Quantity INT,
            TotalBox INT,
            IsActive BIT,
            Remark NVARCHAR(255)
        )
        WHERE PONumber IS NOT NULL AND LTRIM(RTRIM(PONumber)) <> '';

        -------------------------------------------------------
        -- 2. XỬ LÝ UPDATE (Chỉnh sửa trên Grid)
        -------------------------------------------------------
        UPDATE TargetTable
        SET 
            TargetTable.PONumber = ISNULL(SourceTable.PONumber, TargetTable.PONumber),
            TargetTable.PartNumber = ISNULL(SourceTable.PartNumber, TargetTable.PartNumber),
            TargetTable.LotNo = NULLIF(LTRIM(RTRIM(SourceTable.LotNo)), ''),
            TargetTable.QtyPerBox = ISNULL(SourceTable.Quantity, TargetTable.QtyPerBox),
            TargetTable.TotalBox = ISNULL(SourceTable.TotalBox, TargetTable.TotalBox),
            TargetTable.IsActive = ISNULL(SourceTable.IsActive, TargetTable.IsActive),
            TargetTable.Status = CASE WHEN ISNULL(SourceTable.IsActive, TargetTable.IsActive) = 1 THEN 'ACTIVE' ELSE TargetTable.Status END,
            TargetTable.Remark = ISNULL(SourceTable.Remark, TargetTable.Remark),
            TargetTable.UpdateUserID = @pProcessUserID,
            TargetTable.UpdateDateTime = @NowDateTime
        FROM STB_SanminaShipmentPlan AS TargetTable
        INNER JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 2)
            WITH (
                PlanID INT,
                PONumber VARCHAR(50),
                PartNumber VARCHAR(50),
                LotNo VARCHAR(50),
                Quantity INT,
                TotalBox INT,
                IsActive BIT,
                Remark NVARCHAR(255)
            )
        ) AS SourceTable ON TargetTable.PlanID = SourceTable.PlanID;

        -------------------------------------------------------
        -- 3. XỬ LÝ DELETE (Xóa dòng trên Grid)
        -------------------------------------------------------
        DELETE TargetTable
        FROM STB_SanminaShipmentPlan AS TargetTable
        INNER JOIN (
            SELECT PlanID FROM OPENXML(@iDoc, @DeleteTableName, 2)
            WITH (PlanID INT)
        ) AS SourceTable ON TargetTable.PlanID = SourceTable.PlanID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH

    -- Giải phóng tài liệu XML
    EXEC sp_xml_removedocument @iDoc;
END
GO
