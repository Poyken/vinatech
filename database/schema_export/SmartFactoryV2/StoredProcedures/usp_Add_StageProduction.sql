-- Procedure: usp_Add_StageProduction

CREATE PROC usp_Add_StageProduction
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
	   DECLARE @LOCATIONS NVARCHAR(50)
	   DECLARE @TYPES NVARCHAR(50)
	   DECLARE @ITEMCODES NVARCHAR(50)
	   DECLARE @ITEMNAMES NVARCHAR(50)
	   DECLARE @MATERIALSNAME NVARCHAR(50)
	   DECLARE @UNITS NVARCHAR(50)
	   DECLARE @QTY NVARCHAR(50)
	   DECLARE @DATEINPUT NVARCHAR(50)
	   DECLARE @CREATEDATETIME DATETIME
	   DECLARE @CREATEUSERID NVARCHAR(50)
	   DECLARE @CHANGEDATETIME DATETIME
	   DECLARE @CHANGEUSERID NVARCHAR(50)
	   DECLARE @iDoc INT
	   
	   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_STAGE_PRODUCTION',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
		  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
		  
	 BEGIN TRY
	   MERGE STB_VN_STAGE_PRODUCTION AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOCATIONS,
							XMLData.TYPES,
							XMLData.ITEMCODES,
							XMLData.ITEMNAMES,
							XMLData.MATERIALSNAME,
							XMLData.UNITS,
							XMLData.QTY,
							XMLData.DATEINPUT,
							GETDATE() AS CREATEDATETIME,
							@pProcessUserID AS CREATEUSERID,
							GETDATE() AS CHANGEDATETIME,
							@pProcessUserID AS CHANGEUSERID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOCATIONS NVARCHAR(50),
										TYPES NVARCHAR(50),
										ITEMCODES  NVARCHAR(50),
										ITEMNAMES NVARCHAR(50),
										MATERIALSNAME NVARCHAR(50),
										UNITS NVARCHAR(50),
										QTY NVARCHAR(50),
										DATEINPUT NVARCHAR(50),
										CREATEDATETIME  DATETIMEOFFSET,
										CREATEUSERID VARCHAR(20),
										CHANGEDATETIME  DATETIMEOFFSET,
										CHANGEUSERID VARCHAR(20)
									) XMLData
				) AS SourceTable

				ON
				(
					TargetTable.ID = SourceTable.ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					LOCATIONS = SourceTable.LOCATIONS,
					TYPES = SourceTable.TYPES,
					ITEMCODES=SourceTable.ITEMCODES,
					ITEMNAMES = SourceTable.ITEMNAMES,
					MATERIALSNAME = SourceTable.MATERIALSNAME,
					UNITS = SourceTable.UNITS,
					QTY = SourceTable.QTY,
					DATEINPUT = SourceTable.DATEINPUT,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN
				
				INSERT
					(
						LOCATIONS,
						TYPES,
						ITEMCODES,
						ITEMNAMES,
						MATERIALSNAME,
						UNITS,
						QTY,
						DATEINPUT,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LOCATIONS,
							SourceTable.TYPES,
							SourceTable.ITEMCODES,
							SourceTable.ITEMNAMES,
							SourceTable.MATERIALSNAME,
							SourceTable.UNITS,
							SourceTable.QTY,
							SourceTable.DATEINPUT,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
    
	-- Process Update Table
		 MERGE STB_VN_STAGE_PRODUCTION AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOCATIONS,
							XMLData.TYPES,
							XMLData.ITEMCODES,
							XMLData.ITEMNAMES,
							XMLData.MATERIALSNAME,
							XMLData.UNITS,
							XMLData.QTY,
							XMLData.DATEINPUT,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOCATIONS NVARCHAR(100),
										TYPES NVARCHAR(150),
										ITEMCODES NVARCHAR(50),
										ITEMNAMES NVARCHAR(50),
										MATERIALSNAME NVARCHAR(50),
										UNITS NVARCHAR(50),
										QTY NVARCHAR(50),
										DATEINPUT NVARCHAR(50),
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
					LOCATIONS = SourceTable.LOCATIONS,
					TYPES = SourceTable.TYPES,
					ITEMCODES = SourceTable.ITEMCODES,
					ITEMNAMES = SourceTable.ITEMNAMES,
					MATERIALSNAME = SourceTable.MATERIALSNAME,
					UNITS = SourceTable.UNITS,
					QTY = SourceTable.QTY,
					DATEINPUT = SourceTable.DATEINPUT,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN
			
			INSERT
					(
						LOCATIONS,
						TYPES,
						ITEMCODES,
						ITEMNAMES,
						MATERIALSNAME,
						UNITS,
						QTY,
						DATEINPUT,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LOCATIONS,
							SourceTable.TYPES,
							SourceTable.ITEMCODES,
							SourceTable.ITEMNAMES,
							SourceTable.MATERIALSNAME,
							SourceTable.UNITS,
							SourceTable.QTY,
							SourceTable.DATEINPUT,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
	-- Process Delete Table
  MERGE STB_VN_STAGE_PRODUCTION AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOCATIONS,
							XMLData.TYPES,
							XMLData.ITEMCODES,
							XMLData.ITEMNAMES,
							XMLData.MATERIALSNAME,
							XMLData.UNITS,
							XMLData.QTY,
							XMLData.DATEINPUT,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOCATIONS NVARCHAR(100),
										TYPES NVARCHAR(150),
										ITEMCODES NVARCHAR(150),
										ITEMNAMES NVARCHAR(50),
										MATERIALSNAME NVARCHAR(50),
										UNITS NVARCHAR(50),
										QTY NVARCHAR(50),
										DATEINPUT NVARCHAR(50),
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
									XMLData.LOCATIONS,
									XMLData.TYPES,
									XMLData.ITEMCODES,
									XMLData.ITEMNAMES,
									XMLData.MATERIALSNAME,
									XMLData.UNITS,
									XMLData.QTY,
									XMLData.DATEINPUT,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 LOCATIONS NVARCHAR(100),
											 TYPES NVARCHAR(150),
											 ITEMCODES NVARCHAR(50),
											 ITEMNAMES NVARCHAR(50),
											 MATERIALSNAME NVARCHAR(50),
											 UNITS NVARCHAR(50),
											 QTY NVARCHAR(50),
											 DATEINPUT NVARCHAR(50),
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
									XMLData.LOCATIONS,
									XMLData.TYPES,
									XMLData.ITEMCODES,
									XMLData.ITEMNAMES,
									XMLData.MATERIALSNAME,
									XMLData.UNITS,
									XMLData.QTY,
									XMLData.DATEINPUT,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 LOCATIONS NVARCHAR(100),
											 TYPES NVARCHAR(150),
											 ITEMCODES NVARCHAR(50),
											 ITEMNAMES NVARCHAR(50),
											 MATERIALSNAME NVARCHAR(50),
											 UNITS NVARCHAR(50),
											 QTY NVARCHAR(50),
											 DATEINPUT NVARCHAR(50),
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
									XMLData.LOCATIONS,
									XMLData.TYPES,
									XMLData.ITEMCODES,
									XMLData.ITEMNAMES,
									XMLData.MATERIALSNAME,
									XMLData.UNITS,
									XMLData.QTY,
									XMLData.DATEINPUT,
									XMLData.CREATEDATETIME,
									XMLData.CREATEUSERID,
									XMLData.CHANGEDATETIME,
									XMLData.CHANGEUSERID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 LOCATIONS NVARCHAR(100),
											 TYPES NVARCHAR(150),
											 ITEMCODES NVARCHAR(50),
											 ITEMNAMES NVARCHAR(50),
											 MATERIALSNAME NVARCHAR(50),
											 UNITS NVARCHAR(50),
											 QTY NVARCHAR(50),
											 DATEINPUT NVARCHAR(50),
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
								 @LOCATIONS,
								 @TYPES,
								 @ITEMCODES,
								 @ITEMNAMES,
								 @MATERIALSNAME,
								 @UNITS,
							     @QTY,
								 @DATEINPUT,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
					
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_STAGE_PRODUCTION WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
	 IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_STAGE_PRODUCTION', @OldCompanyCode OUTPUT


	INSERT INTO STB_VN_STAGE_PRODUCTION
						(
						    LOCATIONS,
						    TYPES,
							ITEMCODES,
						    ITEMNAMES,
							MATERIALSNAME,
							UNITS,
							QTY,
							DATEINPUT,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LOCATIONS,
							@TYPES,
							@ITEMCODES,
							@ITEMNAMES,
							@MATERIALSNAME,
							@UNITS,
							@QTY,
							@DATEINPUT,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_STAGE_PRODUCTION
 
 SET
							LOCATIONS =   CASE
						                WHEN @LOCATIONS IS NOT NULL THEN @LOCATIONS
						                ELSE @LOCATIONS
						            END,

						TYPES =   CASE
						                WHEN @TYPES IS NOT NULL THEN @TYPES
						                ELSE @TYPES
						            END,
					   ITEMCODES= CASE
						                WHEN @ITEMCODES IS NOT NULL THEN @ITEMCODES
						                ELSE @ITEMCODES
						            END,

							 ITEMNAMES =   CASE
						                WHEN @ITEMNAMES IS NOT NULL THEN @ITEMNAMES
						                ELSE @ITEMNAMES
						            END,

									 MATERIALSNAME =   CASE
						                WHEN @MATERIALSNAME IS NOT NULL THEN @MATERIALSNAME
						                ELSE @MATERIALSNAME
						            END,

									 QTY =   CASE
						                WHEN @QTY IS NOT NULL THEN @QTY
						                ELSE @QTY
						            END,

									 UNITS =   CASE
						                WHEN @UNITS IS NOT NULL THEN @UNITS
						                ELSE @UNITS
						            END,

									 DATEINPUT =   CASE
						                WHEN @DATEINPUT IS NOT NULL THEN @DATEINPUT
						                ELSE @DATEINPUT
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
					WHERE
						    ID = @OldCompanyCode
				

			END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
	
                        DELETE FROM STB_VN_STAGE_PRODUCTION
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
GO

