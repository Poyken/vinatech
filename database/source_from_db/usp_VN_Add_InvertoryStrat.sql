CREATE PROC [dbo].[usp_VN_Add_InvertoryStrat]
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
	   DECLARE @CLASSIFY NVARCHAR(50)
	   DECLARE @MODEL NVARCHAR(50)
	   DECLARE @PRODUCTIONNAME NVARCHAR(50)
	   DECLARE @UNIT NVARCHAR(20)
	   DECLARE @ACTUALLYQTY NVARCHAR(50)
	   DECLARE @NAMETYPE NVARCHAR(50)
	   DECLARE @DESCRIPTIONS NVARCHAR(500)
	   DECLARE @DateInput DATETIME
	   DECLARE @CreateDateTime DATETIME
       DECLARE @CreateUserID NVARCHAR(20)
       DECLARE @ChangeDateTime DATETIME
       DECLARE @ChangeUserID NVARCHAR(20)
	   DECLARE @iDoc INT

	 
	   EXEC SmartFramework.dbo.usp_GetSerialRule 

			@pTableName = 'STB_VN_InventoryFirst',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
		  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
		  
	 BEGIN TRY
	 -- Process Insert Table
	  MERGE STB_VN_InventoryFirst AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDIF
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDIF,
							XMLData.CLASSIFY,
							XMLData.MODEL,
							XMLData.PRODUCTIONNAME,
							XMLData.UNIT,
							XMLData.ACTUALLYQTY,
							XMLData.NAMETYPE,
							XMLData.DESCRIPTIONS,
							XMLData.DateInput,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDIF INT,
										CLASSIFY NVARCHAR(50),
										MODEL NVARCHAR(50),
										PRODUCTIONNAME NVARCHAR(50),
										UNIT NVARCHAR(20),
										ACTUALLYQTY NVARCHAR(50),
										NAMETYPE NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(500),
										DateInput DATETIME,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
					
				ON
				(
					TargetTable.IDIF = SourceTable.IDIF
				)
				
			WHEN MATCHED  THEN 
			
				UPDATE SET
					CLASSIFY = SourceTable.CLASSIFY,
					MODEL = SourceTable.MODEL,
					PRODUCTIONNAME = SourceTable.PRODUCTIONNAME,
					UNIT = SourceTable.UNIT,
					ACTUALLYQTY = SourceTable.ACTUALLYQTY,
					NAMETYPE  = SourceTable.NAMETYPE,
					DESCRIPTIONS =SourceTable.DESCRIPTIONS,
					DateInput=SourceTable.DateInput,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
WHEN NOT MATCHED THEN
				
				INSERT
					(
						CLASSIFY,
						MODEL,
						PRODUCTIONNAME,
						UNIT,
						ACTUALLYQTY,
						NAMETYPE,
						DESCRIPTIONS,
						DateInput,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CLASSIFY,
							SourceTable.MODEL,
							SourceTable.PRODUCTIONNAME,
							SourceTable.UNIT,
							SourceTable.ACTUALLYQTY,
							SourceTable.NAMETYPE, 
							SourceTable.DESCRIPTIONS,
							SourceTable.DateInput,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
   	
		-- Process Update Table

		 MERGE STB_VN_InventoryFirst AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDIF
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDIF,
							XMLData.CLASSIFY,
							XMLData.MODEL,
							XMLData.PRODUCTIONNAME,
							XMLData.UNIT,
							XMLData.ACTUALLYQTY,
							XMLData.NAMETYPE ,
							XMLData.DESCRIPTIONS,
							XMLData.DateInput,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDIF INT,
										CLASSIFY NVARCHAR(50),
										MODEL NVARCHAR(50),
										PRODUCTIONNAME NVARCHAR(50),
										UNIT NVARCHAR(20),
										ACTUALLYQTY NVARCHAR(50),
										NAMETYPE NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(500),
										DateInput DATETIME,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
				ON
				(
					TargetTable.IDIF = SourceTable.IDIF
				)
			
	WHEN MATCHED THEN
			
				UPDATE SET
					CLASSIFY = SourceTable.CLASSIFY,
					MODEL = SourceTable.MODEL,
					PRODUCTIONNAME = SourceTable.PRODUCTIONNAME,
					UNIT = SourceTable.UNIT,
					ACTUALLYQTY = SourceTable.ACTUALLYQTY,
					NAMETYPE = SourceTable.NAMETYPE,
					DESCRIPTIONS = SourceTable.DESCRIPTIONS,
					DateInput=SourceTable.DateInput,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			
			WHEN NOT MATCHED THEN
			
			INSERT
					(
						CLASSIFY,
						MODEL,
						PRODUCTIONNAME,
						UNIT,
						ACTUALLYQTY,
						NAMETYPE,
						DESCRIPTIONS,
						DateInput,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CLASSIFY,
							SourceTable.MODEL,
							SourceTable.PRODUCTIONNAME,
							SourceTable.UNIT,
							SourceTable.ACTUALLYQTY,
							SourceTable.NAMETYPE, 
							SourceTable.DESCRIPTIONS,
							SourceTable.DateInput,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
		
		
		-- Process Delete Table
  MERGE STB_VN_InventoryFirst AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDIF
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDIF,
							XMLData.CLASSIFY,
							XMLData.MODEL,
							XMLData.PRODUCTIONNAME,
							XMLData.UNIT,
							XMLData.ACTUALLYQTY,
							XMLData.NAMETYPE, 
							XMLData.DESCRIPTIONS,
							XMLData.DateInput,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDIF INT,
										CLASSIFY NVARCHAR(50),
										MODEL NVARCHAR(50),
										PRODUCTIONNAME NVARCHAR(50),
										UNIT NVARCHAR(20),
										ACTUALLYQTY NVARCHAR(50),
										NAMETYPE NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(500),
										DateInput DATETIME,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.IDIF = SourceTable.IDIF
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
									XMLData.IDIF,
									XMLData.CLASSIFY,
									XMLData.MODEL,
									XMLData.PRODUCTIONNAME,
									XMLData.UNIT,
									XMLData.ACTUALLYQTY,
									XMLData.NAMETYPE,
									XMLData.DESCRIPTIONS,
									XMLData.DateInput,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDIF INT,
											 CLASSIFY NVARCHAR(50),
											 MODEL NVARCHAR(50),
											 PRODUCTIONNAME NVARCHAR(50),
											 UNIT NVARCHAR(20),
											 ACTUALLYQTY NVARCHAR(50),
											 NAMETYPE NVARCHAR(50),
											 DESCRIPTIONS NVARCHAR(500),
											 DateInput DATETIME,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
									UNION ALL
SELECT
	'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDIF
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDIF,
									XMLData.CLASSIFY,
									XMLData.MODEL,
									XMLData.PRODUCTIONNAME,
									XMLData.UNIT,
									XMLData.ACTUALLYQTY,
									XMLData.NAMETYPE,
									XMLData.DESCRIPTIONS,
									XMLData.DateInput,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDIF INT,
											 CLASSIFY NVARCHAR(50),
											 MODEL NVARCHAR(50),
											 PRODUCTIONNAME NVARCHAR(50),
											 UNIT NVARCHAR(20),
										 	 ACTUALLYQTY NVARCHAR(50),
											 NAMETYPE NVARCHAR(50),
											 DESCRIPTIONS NVARCHAR(500),
											 DateInput DATETIME,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
											
UNION ALL
SELECT
				'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDIF
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDIF,
									XMLData.CLASSIFY,
									XMLData.MODEL,
									XMLData.PRODUCTIONNAME,
									XMLData.UNIT,
									XMLData.ACTUALLYQTY,
									XMLData.NAMETYPE,
									XMLData.DESCRIPTIONS,
									XMLData.DateInput,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 IDIF INT,
											 CLASSIFY NVARCHAR(50),
											 MODEL NVARCHAR(50),
											 PRODUCTIONNAME NVARCHAR(50),
											 UNIT NVARCHAR(20),
											 ACTUALLYQTY NVARCHAR(50),
											 NAMETYPE NVARCHAR(50),
											 DESCRIPTIONS NVARCHAR(500),
											 DateInput DATETIME,
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
								 @CLASSIFY,
								 @MODEL,
								 @PRODUCTIONNAME,
								 @UNIT,
								 @ACTUALLYQTY,
								 @NAMETYPE,
								 @DESCRIPTIONS,
								 @DateInput,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_InventoryFirst WHERE IDIF = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
						
					END
	 IF @IsAutoKey = 1 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_InventoryFirst', @OldCompanyCode OUTPUT

INSERT INTO STB_VN_InventoryFirst
						(
						    CLASSIFY,
						    MODEL,
						    PRODUCTIONNAME,
						    UNIT,
						    ACTUALLYQTY,
							NAMETYPE,
							DESCRIPTIONS,
							DateInput,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CLASSIFY,
							@MODEL,
							@PRODUCTIONNAME,
							@UNIT,
						    @ACTUALLYQTY,
							@NAMETYPE,
						    @DESCRIPTIONS,
							@DateInput,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_VN_InventoryFirst
 
 SET
						CLASSIFY =   CASE
						                WHEN @CLASSIFY IS NOT NULL THEN @CLASSIFY
						                ELSE CLASSIFY
						            END,

							 MODEL =   CASE
						                WHEN @MODEL IS NOT NULL THEN @MODEL
						                ELSE MODEL
						            END,

							 PRODUCTIONNAME =   CASE
						                WHEN @PRODUCTIONNAME IS NOT NULL THEN @PRODUCTIONNAME
						                ELSE PRODUCTIONNAME
						            END,

							 UNIT =   CASE
						                WHEN @UNIT IS NOT NULL THEN @UNIT
						                ELSE UNIT
						            END,

					

						 ACTUALLYQTY =   CASE
						                WHEN @ACTUALLYQTY IS NOT NULL THEN @ACTUALLYQTY
						                ELSE ACTUALLYQTY
									 END,

							 NAMETYPE =   CASE
						                WHEN @NAMETYPE IS NOT NULL THEN @NAMETYPE
						                ELSE NAMETYPE
									 END,

						 DESCRIPTIONS =   CASE
						                WHEN @DESCRIPTIONS IS NOT NULL THEN @DESCRIPTIONS
						                ELSE DESCRIPTIONS
						            END,

						DateInput = CASE
										  WHEN @DateInput IS NOT NULL THEN @DateInput
						                  ELSE DateInput
										  END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
							
							
					WHERE
						    IDIF = @OldCompanyCode
							
			END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
                        DELETE FROM STB_VN_InventoryFirst
						WHERE
						    IDIF = @OldCompanyCode
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