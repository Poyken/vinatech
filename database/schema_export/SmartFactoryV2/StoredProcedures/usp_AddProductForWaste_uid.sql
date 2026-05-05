-- Procedure: usp_AddProductForWaste_uid
CREATE PROCEDURE usp_AddProductForWaste_uid(
   @pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null

)
AS
BEGIN
    SET NOCOUNT ON;
  -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
	DECLARE @LOAIHANG VARCHAR(50)
	DECLARE @CODENVL NVARCHAR(100)
	DECLARE @NAMESNVL NVARCHAR(100)
	DECLARE @UNIT NVARCHAR(100)
	DECLARE @PRICES FLOAT
	DECLARE @NORM FLOAT
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
						    NORM,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
									 LOAIHANG VARCHAR(50),
                                     CODENVL NVARCHAR(100),
                                     NAMESNVL NVARCHAR(100),
                                     UNIT NVARCHAR(100),
                                     PRICES FLOAT,
                                     NORM FLOAT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
	

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								       @IUD_FLAG,
								
										@LOAIHANG,
                                        @CODENVL,
                                        @NAMESNVL ,
                                        @UNIT,
                                        @PRICES ,
                                        @NORM ,
										@CreateDateTime ,
										@CreateUserID ,
										@ChangeDateTime ,
										@ChangeUserID 
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					INSERT INTO STB_VN_B598
						(
							LOAIHANG,
							CODENVL,
							NAMESNVL,
						    UNIT,
						    PRICES,
						     NORM,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@LOAIHANG,
                            @CODENVL,
                            @NAMESNVL ,
                            @UNIT,
                            @PRICES ,
                            @NORM ,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END
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
GO

