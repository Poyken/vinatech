
CREATE PROCEDURE [dbo].[sp_Export_WithHistory_STB_RndRawMaterial_HN]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = NULL, 
    @pXml NVARCHAR(MAX) = NULL     
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'DataTable');
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @iDoc INT;

    DECLARE @MaterialCode NVARCHAR(50), @ExportValue FLOAT, @Remark NVARCHAR(MAX);
    DECLARE @OldValue FLOAT = 0, @NewValue FLOAT = 0;

    IF ISNULL(@pXml, '') = '' RETURN;
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE SourceData CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                MaterialCode, Qty, Remark
            FROM OPENXML(@iDoc, @TableName, 2) 
            WITH (
                MaterialCode NVARCHAR(50) 'MaterialCode',
                Qty FLOAT 'Qty',
                Remark NVARCHAR(MAX) 'Note'
            );

        OPEN SourceData;
        FETCH NEXT FROM SourceData INTO @MaterialCode, @ExportValue, @Remark;

        WHILE @@FETCH_STATUS = 0 
        BEGIN
            IF ISNULL(@MaterialCode, '') <> ''
            BEGIN
                SET @OldValue = 0;
                SELECT @OldValue = ISNULL([Value], 0)
                FROM STB_RndRawMaterial_HN WITH (UPDLOCK)
                WHERE MaterialCode = @MaterialCode;

                IF @@ROWCOUNT = 0
                BEGIN
                    SET @ERROR_MSG = N'Lỗi: Mã vật tư [' + @MaterialCode + N'] không tồn tại trong kho.';
                    RAISERROR(@ERROR_MSG, 16, 1);
                END

                IF @OldValue < ISNULL(@ExportValue, 0)
                BEGIN
                    SET @ERROR_MSG = N'Lỗi: Mã [' + @MaterialCode + N'] không đủ tồn kho (Tồn: ' 
                                     + CAST(@OldValue AS NVARCHAR(20)) + N', Cần xuất: ' 
                                     + CAST(ISNULL(@ExportValue, 0) AS NVARCHAR(20)) + N').';
                    RAISERROR(@ERROR_MSG, 16, 1);
                END

                SET @NewValue = @OldValue - ISNULL(@ExportValue, 0);

                UPDATE STB_RndRawMaterial_HN 
                SET [Value] = @NewValue
                WHERE MaterialCode = @MaterialCode;

                INSERT INTO STB_RnDRawMaterial_HN_History (
                    MaterialCode, 
                    OldValue, 
                    ImportValue,
                    NewValue, 
                    ActionType, 
                    CreatedBy,
                    Remark
                )
                VALUES (
                    @MaterialCode, 
                    @OldValue, 
                    ISNULL(@ExportValue, 0), 
                    @NewValue, 
                    'EXPORT', 
                    @pProcessUserID,
                    @Remark
                );
            END

            FETCH NEXT FROM SourceData INTO @MaterialCode, @ExportValue, @Remark;
        END

        CLOSE SourceData;
        DEALLOCATE SourceData;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        IF CURSOR_STATUS('local', 'SourceData') >= 0 
        BEGIN 
            CLOSE SourceData; 
            DEALLOCATE SourceData; 
        END

        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH

    IF @iDoc IS NOT NULL EXEC sp_xml_removedocument @iDoc;
END