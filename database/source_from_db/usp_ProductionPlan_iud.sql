
-- =============================================
-- Author:     ThucTd
-- Create date: 2026-04-08
-- Description: Quản lý kế hoạch sản xuất.
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductionPlan_iud]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50), -- Ví dụ: 'ProductionPlan'
    @pXml NVARCHAR(MAX) = NULL,
    @pUtcOffset INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Khai báo các đường dẫn bảng trong XML
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'
    
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @NowDateTime DATETIME = DATEADD(MINUTE, @pUtcOffset, GETDATE())
    DECLARE @iDoc INT

    -- Chuẩn bị tài liệu XML
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
        BEGIN TRANSACTION

        -------------------------------------------------------
        -- 1. Xử lý INSERT (Sử dụng MERGE hoặc INSERT trực tiếp)
        -------------------------------------------------------
        INSERT INTO STB_ProductionPlan (
            Month, DatePlan, DayOfWeek, InputESR, NGESR, 
            InputSD, NGSD, NoteModelNGESR, NoteModelNGSD, 
            CreateUserID, CreateDateTime
        )
        SELECT 
            Month, DatePlan, DayOfWeek, InputESR, NGESR, 
            InputSD, NGSD, NoteModelNGESR, NoteModelNGSD, 
            @pProcessUserID, @NowDateTime
        FROM OPENXML(@iDoc, @InsertTableName, 2)
        WITH (
            Month INT,
            DatePlan DATE,
            DayOfWeek NVARCHAR(10),
            InputESR NUMERIC(18, 2),
            NGESR NUMERIC(18, 2),
            InputSD NUMERIC(18, 2),
            NGSD NUMERIC(18, 2),
            NoteModelNGESR NVARCHAR(255),
            NoteModelNGSD NVARCHAR(255)
        )

        -------------------------------------------------------
        -- 2. Xử lý UPDATE
        -------------------------------------------------------
        UPDATE TargetTable
        SET 
            TargetTable.Month = SourceTable.Month,
            TargetTable.DatePlan = SourceTable.DatePlan,
            TargetTable.DayOfWeek = SourceTable.DayOfWeek,
            TargetTable.InputESR = SourceTable.InputESR,
            TargetTable.NGESR = SourceTable.NGESR,
            TargetTable.InputSD = SourceTable.InputSD,
            TargetTable.NGSD = SourceTable.NGSD,
            TargetTable.NoteModelNGESR = SourceTable.NoteModelNGESR,
            TargetTable.NoteModelNGSD = SourceTable.NoteModelNGSD,
            TargetTable.CreateUserID = @pProcessUserID -- Hoặc dùng ChangeUserID nếu bảng có cột đó
        FROM STB_ProductionPlan AS TargetTable
        INNER JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 2)
            WITH (
                PlanID INT,
                Month INT,
                DatePlan DATE,
                DayOfWeek NVARCHAR(10),
                InputESR NUMERIC(18, 2),
                NGESR NUMERIC(18, 2),
                InputSD NUMERIC(18, 2),
                NGSD NUMERIC(18, 2),
                NoteModelNGESR NVARCHAR(255),
                NoteModelNGSD NVARCHAR(255)
            )
        ) AS SourceTable ON TargetTable.PlanID = SourceTable.PlanID

        -------------------------------------------------------
        -- 3. Xử lý DELETE
        -------------------------------------------------------
        DELETE TargetTable
        FROM STB_ProductionPlan AS TargetTable
        INNER JOIN (
            SELECT PlanID FROM OPENXML(@iDoc, @DeleteTableName, 2)
            WITH (PlanID INT)
        ) AS SourceTable ON TargetTable.PlanID = SourceTable.PlanID

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        SET @ERROR_MSG = ERROR_MESSAGE()
        RAISERROR(@ERROR_MSG, 16, 1)
    END CATCH

    -- Giải phóng tài liệu XML
    EXEC sp_xml_removedocument @iDoc
END
