CREATE PROCEDURE usp_Infomation_Category_Waste(
 @pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
   @pProcessViewName VARCHAR(50) = null,
@pXml NVARCHAR(MAX) = null

)
AS
BEGIN
   SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
    DECLARE @LOAIHANG VARCHAR(50)
    DECLARE @CODENVL NVARCHAR(100)
    DECLARE @NAMESNVL NVARCHAR(100)
    DECLARE @UNIT NVARCHAR(50)
    DECLARE @PRICES FLOAT
    DECLARE @DESCPRTIONS NVARCHAR(200)
    DECLARE @CreateDateTime DATETIME
    DECLARE @CreateUserID VARCHAR(20)
    DECLARE @ChangeDateTime DATETIME
    DECLARE @ChangeUserID VARCHAR(20)

    DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
        DECLARE SourceData CURSOR FOR
            SELECT
                'INSERT' AS IUD_FLAG,
                LOAIHANG,
                CODENVL,
                NAMESNVL,
                UNIT,
                PRICES,
                DESCPRTIONS,
                CreateDateTime,
                CreateUserID,
                ChangeDateTime,
                ChangeUserID
            FROM
                OPENXML(@iDoc, @InsertTableName, 2)
                WITH (
                    LOAIHANG VARCHAR(50),
                    CODENVL NVARCHAR(100),
                    NAMESNVL NVARCHAR(100),
                    UNIT VARCHAR(50),
                    PRICES FLOAT,
                    DESCPRTIONS NVARCHAR(200),
                    CreateDateTime DATETIMEOFFSET,
                    CreateUserID VARCHAR(20),
                    ChangeDateTime DATETIMEOFFSET,
                    ChangeUserID VARCHAR(20)
                )

        OPEN SourceData

        FETCH NEXT FROM SourceData INTO
            @IUD_FLAG,
            @LOAIHANG,
            @CODENVL,
            @NAMESNVL,
            @UNIT,
            @PRICES,
            @DESCPRTIONS,
            @CreateDateTime,
            @CreateUserID,
            @ChangeDateTime,
            @ChangeUserID

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @IUD_FLAG = 'INSERT'
            BEGIN
                INSERT INTO STB_VN_B598
                (
                    LOAIHANG,
                    CODENVL,
                    NAMESNVL,
                    UNIT,
                    PRICES,
                    DESCPRTIONS,
                    CreateDateTime,
                    CreateUserID,
                    ChangeDateTime,
                    ChangeUserID
                )
                VALUES
                (
                    @LOAIHANG,
                    @CODENVL,
                    @NAMESNVL,
                    @UNIT,
                    @PRICES,
                    @DESCPRTIONS,
                    GETDATE(),
                    @pProcessUserID,
                    @ChangeDateTime,
                    @ChangeUserID
                )
            END

            FETCH NEXT FROM SourceData INTO
                @IUD_FLAG,
                @LOAIHANG,
                @CODENVL,
                @NAMESNVL,
                @UNIT,
                @PRICES,
                @DESCPRTIONS,
                @CreateDateTime,
                @CreateUserID,
                @ChangeDateTime,
                @ChangeUserID
        END

        CLOSE SourceData
        DEALLOCATE SourceData

        EXEC sp_xml_removedocument @iDoc
    END TRY
    BEGIN CATCH
        SET @ERROR_MSG = ERROR_MESSAGE()
        RAISERROR(@ERROR_MSG, 16, 1)
        IF CURSOR_STATUS('global','SourceData') >= -1
        BEGIN
            CLOSE SourceData
            DEALLOCATE SourceData
        END
        EXEC sp_xml_removedocument @iDoc
    END CATCH
END
