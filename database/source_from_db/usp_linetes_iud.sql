CREATE PROC [dbo].[usp_linetes_iud] 
@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
    --DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    
  
	DECLARE @CodeLine VARCHAR(20)
	DECLARE @NameLine VARCHAR(20)
	DECLARE @LineDesc VARCHAR(20)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @iRun INT
	DECLARE @iDoc INT
	

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
					CodeLine,NameLine,LineDesc,CreateDateTime, CreateUserID,ChangeDateTime,ChangeUserID
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH  (
								CodeLine VARCHAR(20),
								NameLine VARCHAR(20),
								LineDesc VARCHAR(50),
								CreateDateTime DATETIME,
								CreateUserID VARCHAR(50),
								ChangeDateTime DATETIME,
								ChangeUserID VARCHAR(20)
							)
        OPEN SourceData

        WHILE @iRun=0 OR @iRun ='' BEGIN
            FETCH NEXT FROM SourceData INTO
								@CodeLine,
								@NameLine,
								@LineDesc,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
								

   --         IF @@FETCH_STATUS <> 0 BEGIN
			--	BREAK
			--END

		

			insert into STB_TEST01(CodeLine,NameLine,LineDesc,CreateDateTime, CreateUserID,ChangeDateTime,ChangeUserID) values (@CodeLine
			,@NameLine,@LineDesc,@CreateDateTime,@CreateUserID,@ChangeDateTime,@ChangeUserID);
		END	

	
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
			
	CLOSE SourceData;
	DEALLOCATE SourceData;
			
	EXEC sp_xml_removedocument @idoc
END


--SELECT * FROM STB_TEST01