-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[sp_Upsert_Accumulate_STB_RndRawMaterial_HN]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = NULL,
    @pXml NVARCHAR(MAX) = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, '');
    DECLARE @ERROR_MSG NVARCHAR(MAX);

    DECLARE @Class NVARCHAR(10), @MaterialCode NVARCHAR(50), @GroupCode NVARCHAR(50);
    DECLARE @Description NVARCHAR(MAX), @Unit NVARCHAR(5), @Value FLOAT;
    
    DECLARE @OldValue FLOAT = 0;
    DECLARE @NewValue FLOAT = 0;
    DECLARE @iDoc INT;

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE SourceData CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                Class, MaterialCode, GroupCode, [Description], Unit, Qty
            FROM OPENXML(@iDoc, @TableName, 2) 
            WITH (
                Class NVARCHAR(10),
                MaterialCode NVARCHAR(50),
                GroupCode NVARCHAR(50),
                [Description] NVARCHAR(MAX),
                Unit NVARCHAR(5),
                Qty FLOAT
            );

        OPEN SourceData;

        FETCH NEXT FROM SourceData INTO 
            @Class, @MaterialCode, @GroupCode, @Description, @Unit, @Value;

        WHILE @@FETCH_STATUS = 0 
        BEGIN
            SET @OldValue = 0;
            SELECT @OldValue = ISNULL([Value], 0)
            FROM STB_RndRawMaterial_HN 
            WHERE MaterialCode = @MaterialCode;

            IF @@ROWCOUNT > 0
            BEGIN
                SET @NewValue = @OldValue + @Value;

                UPDATE STB_RndRawMaterial_HN 
                SET Class = ISNULL(@Class, Class),
                    GroupCode = ISNULL(@GroupCode, GroupCode),
                    [Description] = ISNULL(@Description, [Description]),
                    Unit = ISNULL(@Unit, Unit),
                    [Value] = @NewValue
                WHERE MaterialCode = @MaterialCode;

                INSERT INTO STB_RnDRawMaterial_HN_History (MaterialCode, OldValue, ImportValue, NewValue, ActionType, CreatedBy)
                VALUES (@MaterialCode, @OldValue, @Value, @NewValue, 'UPDATE', @pProcessUserID);
            END
            ELSE
            BEGIN
                SET @NewValue = @Value;

                INSERT INTO STB_RndRawMaterial_HN (Class, MaterialCode, GroupCode, [Description], Unit, [Value], CreateDate)
                VALUES (@Class, @MaterialCode, @GroupCode, @Description, @Unit, @NewValue, GETDATE());

                INSERT INTO STB_RnDRawMaterial_HN_History (MaterialCode, OldValue, ImportValue, NewValue, ActionType, CreatedBy)
                VALUES (@MaterialCode, 0, @Value, @NewValue, 'INSERT', @pProcessUserID);
            END

            FETCH NEXT FROM SourceData INTO 
                @Class, @MaterialCode, @GroupCode, @Description, @Unit, @Value;
        END

        CLOSE SourceData;
        DEALLOCATE SourceData;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        
        IF CURSOR_STATUS('local', 'SourceData') >= 0 
        BEGIN 
            CLOSE SourceData; 
            DEALLOCATE SourceData; 
        END

        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH

    IF @iDoc IS NOT NULL
        EXEC sp_xml_removedocument @iDoc;
END