CREATE PROC [dbo].[usp_Add_VN_MODEL_INVENTORY]
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


	-- Declare Columns Variable
	   DECLARE @OldCompanyCode NVARCHAR(50)
	   DECLARE @CODEMODEL NVARCHAR(100)
	   DECLARE @NAMES NVARCHAR(150)
	   DECLARE @IsUsed BIT
	   DECLARE @DECRISPTION NVARCHAR(500)
	   DECLARE @CreateDateTime DATETIME
       DECLARE @CreateUserID NVARCHAR(20)
       DECLARE @ChangeDateTime DATETIME
       DECLARE @ChangeUserID NVARCHAR(20)
	   DECLARE @iDoc INT

	   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_MODEL_INVENTORY',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
		  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
		  
	 BEGIN TRY
	--EXEC usp_Add_InventoryFirst_History @OldCompanyCode	
	 -- Process Insert Table
	  MERGE STB_VN_MODEL_INVENTORY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDM
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDM,
							XMLData.CODEMODEL,
							XMLData.NAMES,
							XMLData.IsUsed,
							XMLData.DECRISPTION,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDM INT,
										CODEMODEL NVARCHAR(100),
										NAMES NVARCHAR(150),
										IsUsed  BIT,
										DECRISPTION NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable

				ON
				(
					TargetTable.IDM = SourceTable.IDM
				)

			WHEN MATCHED THEN
				UPDATE SET
					CODEMODEL = SourceTable.CODEMODEL,
					NAMES = SourceTable.NAMES,
					IsUsed=SourceTable.IsUsed,
					DECRISPTION = SourceTable.DECRISPTION,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN
				
				INSERT
					(
						CODEMODEL,
						NAMES,
						IsUsed,
						DECRISPTION,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CODEMODEL,
							SourceTable.NAMES,
							SourceTable.IsUsed,
							SourceTable.DECRISPTION,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
    

		-- Process Update Table
		 MERGE STB_VN_MODEL_INVENTORY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDM
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDM,
							XMLData.CODEMODEL,
							XMLData.NAMES,
							XMLData.IsUsed,
							XMLData.DECRISPTION,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDM INT,
										CODEMODEL NVARCHAR(100),
										NAMES NVARCHAR(150),
										IsUsed BIT,
										DECRISPTION NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
				ON
				(
					TargetTable.IDM = SourceTable.IDM
					
				)
		
	WHEN MATCHED THEN
	
				UPDATE SET
					CODEMODEL = SourceTable.CODEMODEL,
					NAMES = SourceTable.NAMES,
					IsUsed = SourceTable.IsUsed,
					DECRISPTION = SourceTable.DECRISPTION,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN
			
			INSERT
					(
						CODEMODEL,
						NAMES,
						IsUsed,
						DECRISPTION,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CODEMODEL,
							SourceTable.NAMES,
							SourceTable.IsUsed,
							SourceTable.DECRISPTION,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
					
			--EXEC usp_Add_InventoryFirst_History @OldCompanyCode	
		-- Process Delete Table
  MERGE STB_VN_MODEL_INVENTORY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDM
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDM,
							XMLData.CODEMODEL,
							XMLData.NAMES,
							XMLData.IsUsed,
							XMLData.DECRISPTION,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDM INT,
										CODEMODEL NVARCHAR(100),
										NAMES NVARCHAR(150),
										IsUsed BIT,
										DECRISPTION NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.IDM = SourceTable.IDM
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
									XMLData.IDM,
									XMLData.CODEMODEL,
									XMLData.NAMES,
									XMLData.IsUsed,
									XMLData.DECRISPTION,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDM INT,
											 CODEMODEL NVARCHAR(100),
											 NAMES NVARCHAR(150),
											 IsUsed BIT,
											 DECRISPTION NVARCHAR(500),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
									UNION ALL
SELECT
	'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDM
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDM,
									XMLData.CODEMODEL,
									XMLData.NAMES,
									XMLData.IsUsed,
									XMLData.DECRISPTION,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDM INT,
											 CODEMODEL NVARCHAR(100),
											 NAMES NVARCHAR(150),
											 IsUsed BIT,
											 DECRISPTION NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
UNION ALL
SELECT
				'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDM
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDM,
									XMLData.CODEMODEL,
									XMLData.NAMES,
									XMLData.IsUsed,
									XMLData.DECRISPTION,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 IDM INT,
											 CODEMODEL NVARCHAR(100),
											 NAMES NVARCHAR(150),
											 IsUsed BIT,
											 DECRISPTION NVARCHAR(500),
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
								 @CODEMODEL,
								 @IsUsed,
								 @DECRISPTION,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
					
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_MODEL_INVENTORY WHERE IDM = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
	 IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_MODEL_INVENTORY', @OldCompanyCode OUTPUT

INSERT INTO STB_VN_MODEL_INVENTORY
						(
						    CODEMODEL,
						    NAMES,
							IsUsed,
						    DECRISPTION,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CODEMODEL,
						    @NAMES,
							@IsUsed,
							@DECRISPTION,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_MODEL_INVENTORY
 
 SET
							CODEMODEL =   CASE
						                WHEN @CODEMODEL IS NOT NULL THEN @CODEMODEL
						                ELSE CODEMODEL
						            END,

						NAMES =   CASE
						                WHEN @NAMES IS NOT NULL THEN @NAMES
						                ELSE NAMES
						            END,
					   IsUsed= CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,

							 DECRISPTION =   CASE
						                WHEN @DECRISPTION IS NOT NULL THEN @DECRISPTION
						                ELSE DECRISPTION
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
					WHERE
						    IDM = @OldCompanyCode
				

			END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
	
                        DELETE FROM STB_VN_MODEL_INVENTORY
						WHERE
						    IDM = @OldCompanyCode
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