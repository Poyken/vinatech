CREATE PROC [dbo].[usp_VN_Add_StatusMachines]
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
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	/***---------------------------------------------------------------Start automatic ID for add recorder-----------------------------------------------------------------***/


			DECLARE @NewCode NVARCHAR(50)
			DECLARE @Prefix NVARCHAR(30) = 'CSM'
			DECLARE @Id INT

			SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_VN_STATUSMACHINES 
			SELECT @NewCode = @Prefix + RIGHT('00000' + CAST(@Id AS nvarchar(30)),30)

		

	/***---------------------------------------------------------------End automatic ID for add recorder-------------------------------------------------------------------***/


			DECLARE @OldCompanyCode INT
			DECLARE @CODESTATUSMACHINES NVARCHAR(100)
			DECLARE @NAMESTATUS NVARCHAR(50)
			DECLARE @Descptions NVARCHAR(50)
			DECLARE @IsUsed BIT
			DECLARE @CreateDateTime DATETIME
			DECLARE @CreateUserID NVARCHAR(50)
			DECLARE @ChangeDateTime DATETIME
			DECLARE @ChangeUserID NVARCHAR(50)
			DECLARE @iDoc INT

			
		   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_STATUSMACHINES',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
		  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		   BEGIN TRY

		     MERGE STB_VN_STATUSMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODESTATUSMACHINES,
							XMLData.NAMESTATUS,
							XMLData.Descptions,
							XMLData.IsUsed,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODESTATUSMACHINES  NVARCHAR(50),
										NAMESTATUS NVARCHAR(50),
										Descptions NVARCHAR(50),
										IsUsed  BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable

				ON
				(
					TargetTable.ID = SourceTable.ID
				)

	WHEN MATCHED THEN
				UPDATE SET
					CODESTATUSMACHINES = @NewCode,
					NAMESTATUS = SourceTable.NAMESTATUS,
					Descptions = SourceTable.Descptions,
					IsUsed='1',
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

		WHEN NOT MATCHED THEN

	INSERT
					(
						
						CODESTATUSMACHINES,
						NAMESTATUS,
						Descptions,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							@NewCode,
							SourceTable.NAMESTATUS,
							SourceTable.Descptions,
							'1',
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

 MERGE STB_VN_STATUSMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODESTATUSMACHINES,
							XMLData.NAMESTATUS,
							XMLData.Descptions,
							XMLData.IsUsed,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODESTATUSMACHINES NVARCHAR(100),
										NAMESTATUS NVARCHAR(50),
										Descptions NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
				ON
				(
					TargetTable.ID = SourceTable.ID
					
				)

	WHEN MATCHED THEN
				DELETE;

 END TRY
  BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

	 END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		  BEGIN TRY
				  DECLARE SourceData CURSOR FOR
				   SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldCompanyCode,
									XMLData.ID,
									XMLData.CODESTATUSMACHINES,
									XMLData.NAMESTATUS,
									XMLData.Descptions,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 CODESTATUSMACHINES  NVARCHAR(100),
											 NAMESTATUS NVARCHAR(50),
											 Descptions NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
									UNION ALL

	SELECT
	'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.CODESTATUSMACHINES,
									XMLData.NAMESTATUS,
									XMLData.Descptions,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 CODESTATUSMACHINES NVARCHAR(100),
											 NAMESTATUS NVARCHAR(50),
											 Descptions NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
UNION ALL
SELECT
				'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.CODESTATUSMACHINES,
									XMLData.NAMESTATUS,
									XMLData.Descptions,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 CODESTATUSMACHINES NVARCHAR(100),
											 NAMESTATUS  NVARCHAR(100),
											 Descptions NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData

									 OPEN SourceData
						   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @CODESTATUSMACHINES,
								 @NAMESTATUS,
								 @Descptions,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			
		  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

		     IF EXISTS (SELECT 1 FROM STB_VN_STATUSMACHINES WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
	 IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_STATUSMACHINES', @OldCompanyCode OUTPUT

INSERT INTO STB_VN_STATUSMACHINES
						(
							CODESTATUSMACHINES,
						    NAMESTATUS,
							Descptions,
							IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@NewCode,
							@NAMESTATUS,
							@Descptions,
							'1',
						     DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
	END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

	 UPDATE STB_VN_STATUSMACHINES
 
 SET

							CODESTATUSMACHINES =   CASE
						                WHEN @CODESTATUSMACHINES IS NOT NULL THEN @CODESTATUSMACHINES
						                ELSE CODESTATUSMACHINES
						            END,

							NAMESTATUS =   CASE
						                WHEN @NAMESTATUS IS NOT NULL THEN @NAMESTATUS
						                ELSE NAMESTATUS
						            END,

						
					
						Descptions =   CASE
						                WHEN @Descptions IS NOT NULL THEN @Descptions
						                ELSE Descptions
						            END,

					   IsUsed= CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					WHERE
						    ID = @OldCompanyCode

				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
	
                        DELETE FROM STB_VN_STATUSMACHINES
						WHERE
						    ID = @OldCompanyCode
                    END
						
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
END