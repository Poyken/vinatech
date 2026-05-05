-- Procedure: usp_Add_MasterAgaingDetails
CREATE PROC [dbo].[usp_Add_MasterAgaingDetails]
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

	DECLARE @OldCompanyCode INT
	DECLARE @IDCODE NVARCHAR(50)
	DECLARE @DATAGAING DATETIME
	DECLARE @MODEL NVARCHAR(50)
	DECLARE @NAMEERROR NVARCHAR(50)
	DECLARE @STANDAGAING NVARCHAR(50)
	DECLARE @QTYINPUT INT
	DECLARE @QTYOK INT
	DECLARE @NGESR INT
	DECLARE @NGLC INT
	DECLARE @NGOTHER INT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MasterAgaingDetails',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

   BEGIN TRY
	 MERGE STB_MasterAgaingDetails AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.IDCODE,
							XMLData.DATAGAING,
							XMLData.MODEL,
							XMLData.NAMEERROR,
							XMLData.STANDAGAING,
							XMLData.QTYINPUT,
							XMLData.QTYOK,
							XMLData.NGESR,
							XMLData.NGLC,
							XMLData.NGOTHER,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										IDCODE NVARCHAR(50),
										DATAGAING DATETIME,
										MODEL NVARCHAR(20),
										NAMEERROR NVARCHAR(50),
										STANDAGAING NVARCHAR(50),
										QTYINPUT INT,
										QTYOK INT,
										NGESR INT,
										NGLC INT,
										NGOTHER INT,
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
					IDCODE = SourceTable.IDCODE,
					DATAGAING = SourceTable.DATAGAING,
					MODEL = SourceTable.MODEL,
					NAMEERROR = SourceTable.NAMEERROR,
					STANDAGAING = SourceTable.STANDAGAING,
					QTYINPUT = SourceTable.QTYINPUT,
					QTYOK = SourceTable.QTYINPUT - SourceTable.NGESR - SourceTable.NGOTHER,
					NGESR = SourceTable.NGESR,
					NGLC = SourceTable.NGLC,
					NGOTHER = SourceTable.NGOTHER,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN

				INSERT
					(
						IDCODE,
						DATAGAING,
						MODEL,
						NAMEERROR,
						STANDAGAING,
						QTYINPUT,
						QTYOK,
						NGESR,
						NGLC,
						NGOTHER,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.IDCODE,
							SourceTable.DATAGAING,
							SourceTable.MODEL,
							SourceTable.NAMEERROR,
							SourceTable.STANDAGAING,
							SourceTable.QTYINPUT,
							SourceTable.QTYOK,
							SourceTable.NGESR,
							SourceTable.NGLC,
							SourceTable.NGOTHER,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);			
 MERGE STB_MasterAgaingDetails AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.IDCODE,
							XMLData.DATAGAING,
							XMLData.MODEL,
							XMLData.NAMEERROR,
							XMLData.STANDAGAING,
							XMLData.QTYINPUT,
							XMLData.QTYOK,
							XMLData.NGESR,
							XMLData.NGLC,
							XMLData.NGOTHER,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										IDCODE NVARCHAR(50),
										DATAGAING DATETIME,
										MODEL NVARCHAR(20),
										NAMEERROR NVARCHAR(50),
										STANDAGAING NVARCHAR(50),
										QTYINPUT INT,
										QTYOK INT,
										NGESR INT,
										NGLC INT,
										NGOTHER INT,
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
					IDCODE = SourceTable.IDCODE,
					DATAGAING = SourceTable.DATAGAING,
					MODEL = SourceTable.MODEL,
					NAMEERROR = SourceTable.NAMEERROR,
					STANDAGAING = SourceTable.STANDAGAING,
					QTYINPUT = SourceTable.QTYINPUT,
					QTYOK = SourceTable.QTYINPUT - SourceTable.NGESR - SourceTable.NGOTHER,
					NGESR = SourceTable.NGESR,
					NGLC = SourceTable.NGLC,
					NGOTHER = SourceTable.NGOTHER,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

			INSERT
					(
						IDCODE,
						DATAGAING,
						MODEL,
						NAMEERROR,
						STANDAGAING,
						QTYINPUT,
						QTYOK,
						NGESR,
						NGLC,
						NGOTHER,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.IDCODE,
							SourceTable.DATAGAING,
							SourceTable.MODEL,
							SourceTable.NAMEERROR,
							SourceTable.STANDAGAING,
							SourceTable.QTYINPUT,
							SourceTable.QTYOK,
							SourceTable.NGESR,
							SourceTable.NGLC,
							SourceTable.NGOTHER,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

	-- Process Delete Table
            MERGE STB_MasterAgaingDetails AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.IDCODE,
							XMLData.DATAGAING,
							XMLData.MODEL,
							XMLData.NAMEERROR,
							XMLData.STANDAGAING,
							XMLData.QTYINPUT,
							XMLData.QTYOK,
							XMLData.NGESR,
							XMLData.NGLC,
							XMLData.NGOTHER,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										IDCODE VARCHAR(50),
										DATAGAING DATETIME,
										MODEL NVARCHAR(20),
										NAMEERROR NVARCHAR(50),
										STANDAGAING NVARCHAR(50),
										QTYINPUT INT,
										QTYOK INT,
										NGESR INT,
										NGLC INT,
										NGOTHER INT,
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
									XMLData.IDCODE,
									XMLData.DATAGAING,
									XMLData.MODEL,
									XMLData.NAMEERROR,
									XMLData.STANDAGAING,
									XMLData.QTYINPUT,
									XMLData.QTYOK,
									XMLData.NGESR,
									XMLData.NGLC,
									XMLData.NGOTHER,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 IDCODE VARCHAR(50),
											 DATAGAING DATETIME,
											 MODEL NVARCHAR(20),
											 NAMEERROR NVARCHAR(50),
											 STANDAGAING NVARCHAR(50),
											 QTYINPUT INT,
											 QTYOK INT,
											 NGESR INT,
											 NGLC INT,
											 NGOTHER INT,
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
									XMLData.IDCODE,
									XMLData.DATAGAING,
									XMLData.MODEL,
									XMLData.NAMEERROR,
									XMLData.STANDAGAING,
									XMLData.QTYINPUT,
									XMLData.QTYOK,
									XMLData.NGESR,
									XMLData.NGLC,
									XMLData.NGOTHER,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 IDCODE VARCHAR(50),
											 DATAGAING DATETIME,
											 MODEL NVARCHAR(20),
											 NAMEERROR NVARCHAR(50),
											 STANDAGAING NVARCHAR(50),
											 QTYINPUT INT,
											 QTYOK INT,
											 NGESR INT,
											 NGLC INT,
											 NGOTHER INT,
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
									XMLData.IDCODE,
									XMLData.DATAGAING,
									XMLData.MODEL,
									XMLData.NAMEERROR,
									XMLData.STANDAGAING,
									XMLData.QTYINPUT,
									XMLData.QTYOK,
									XMLData.NGESR,
									XMLData.NGLC,
									XMLData.NGOTHER,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 IDCODE NVARCHAR(50),
											 DATAGAING DATETIME,
											 MODEL NVARCHAR(20),
											 NAMEERROR NVARCHAR(50),
											 STANDAGAING NVARCHAR(50),
											 QTYINPUT INT,
											 QTYOK INT,
											 NGESR INT,
											 NGLC INT,
											 NGOTHER INT,
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
								 @IDCODE,
								 @DATAGAING,
								 @MODEL,
								 @NAMEERROR,
								 @STANDAGAING,
								 @QTYINPUT,
								 @QTYOK,
								 @NGESR,
								 @NGLC,
								 @NGOTHER,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MasterAgaingDetails WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MasterAgaingDetails', @OldCompanyCode OUTPUT
	
	INSERT INTO STB_MasterAgaingDetails
						(
						    IDCODE,
						    DATAGAING,
						    MODEL,
						    NAMEERROR,
						    STANDAGAING,
						    QTYINPUT,
							QTYOK,
							NGESR,
							NGLC,
							NGOTHER,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @IDCODE,
						    @DATAGAING,
						    @MODEL,
						    @NAMEERROR,
						    @STANDAGAING,
						    @QTYINPUT,
							@QTYOK,
							@NGESR,
							@NGLC,
							@NGOTHER,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_MasterAgaingDetails
						SET
							IDCODE =   CASE
						                WHEN @IDCODE IS NOT NULL THEN @IDCODE
						                ELSE IDCODE
						            END,
						DATAGAING =   CASE
						                WHEN @DATAGAING IS NOT NULL THEN @DATAGAING
						                ELSE DATAGAING
						            END,

							 MODEL =   CASE
						                WHEN @MODEL IS NOT NULL THEN @MODEL
						                ELSE MODEL
						            END,

							 NAMEERROR =   CASE
						                WHEN @NAMEERROR IS NOT NULL THEN @NAMEERROR
						                ELSE NAMEERROR
						            END,
							 STANDAGAING =   CASE
						                WHEN @STANDAGAING IS NOT NULL THEN @STANDAGAING
						                ELSE STANDAGAING
						            END,
						 QTYINPUT =   CASE
						                WHEN @QTYINPUT IS NOT NULL THEN @QTYINPUT
						                ELSE QTYINPUT
						            END,
						 QTYOK =   CASE
						                WHEN @QTYOK IS NULL THEN (@QTYINPUT - @NGESR  - @NGOTHER)
						                ELSE QTYOK
						            END,
						 NGESR =   CASE
						                WHEN @NGESR IS NOT NULL THEN @NGESR
						                ELSE NGESR
						            END,
						 NGLC =   CASE
						                WHEN @NGLC IS NOT NULL THEN @NGLC
						                ELSE NGLC
						            END,
							 NGOTHER =   CASE
						                WHEN @NGOTHER IS NOT NULL THEN @NGOTHER
						                ELSE NGOTHER
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_MasterAgaingDetails
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


--SELECT * FROM STB_MasterAgaingDetails
GO

