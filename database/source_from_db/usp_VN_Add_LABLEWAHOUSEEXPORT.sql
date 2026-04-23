CREATE proc usp_VN_Add_LABLEWAHOUSEEXPORT
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

	 DECLARE @OldCompanyCode NVARCHAR(50)
	 DECLARE @FIRSTLABLE NVARCHAR(50)
	 DECLARE @FIRSTSECOND NVARCHAR(50)
	 DECLARE @FIRSTTHREE NVARCHAR(50)
	 DECLARE @FRISTFOURS NVARCHAR(50)
	 DECLARE @INVOICENO NVARCHAR(50)
	 DECLARE @DATES NVARCHAR(50)
	 DECLARE @DESCRIPTIONS NVARCHAR(50)
	 DECLARE @MODEL NVARCHAR(50)
	 DECLARE @DRNOWITHREV NVARCHAR(50)
	 DECLARE @SAPCODE NVARCHAR(50)
	 DECLARE @PKTQTY INT
	 DECLARE @LOTQTY INT
	 DECLARE @NUMBERPINTERED INT
	 DECLARE @NOTES NVARCHAR(50)
	 DECLARE @CreateDateTime DATETIME
	 DECLARE @CreateUserID NVARCHAR(50)
	 DECLARE @ChangeDateTime DATETIME
	 DECLARE @ChangeUserID NVARCHAR(50)
	 DECLARE @iDoc INT

		 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_LABLEWAHOUSEEXPORT',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT   

  IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

   BEGIN TRY
   
    	-- Process Insert Table
			 MERGE STB_VN_LABLEWAHOUSEEXPORT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.FIRSTLABLE,
							XMLData.FIRSTSECOND,
							XMLData.FIRSTTHREE,
							XMLData.FRISTFOURS,
							XMLData.INVOICENO,
							XMLData.DATES,
							XMLData.DESCRIPTIONS,
							XMLData.MODEL,
							XMLData.DRNOWITHREV,
							XMLData.SAPCODE,
							XMLData.PKTQTY,
							XMLData.LOTQTY,
							XMLData.NUMBERPINTERED,
							XMLData.NOTES,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										FIRSTLABLE NVARCHAR(50),
										FIRSTSECOND NVARCHAR(50),
										FIRSTTHREE NVARCHAR(50),
										FRISTFOURS NVARCHAR(50),
										INVOICENO NVARCHAR(50),
										DATES NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(50),
										MODEL NVARCHAR(50),
										DRNOWITHREV NVARCHAR(50),
										SAPCODE NVARCHAR(50),
										PKTQTY INT,
										LOTQTY INT,
										NUMBERPINTERED INT,
										NOTES NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
										
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)

	WHEN MATCHED THEN
			
				UPDATE SET
					FIRSTLABLE = SourceTable.FIRSTLABLE,
					FIRSTSECOND = SourceTable.FIRSTSECOND,
					FIRSTTHREE = SourceTable.FIRSTTHREE,
					FRISTFOURS = SourceTable.FRISTFOURS,
					INVOICENO = SourceTable.INVOICENO,
					DATES = SourceTable.DATES,
					DESCRIPTIONS = SourceTable.DESCRIPTIONS,
					MODEL = SourceTable.MODEL,
					DRNOWITHREV = SourceTable.DRNOWITHREV,
					SAPCODE = SourceTable.SAPCODE,
					PKTQTY = SourceTable.PKTQTY,
					LOTQTY = SourceTable.LOTQTY,
					NUMBERPINTERED = SourceTable.NUMBERPINTERED,
					NOTES = SourceTable.NOTES,
					CreateDateTime = SourceTable.CreateDateTime,
					CreateUserID = SourceTable.CreateUserID,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
WHEN NOT MATCHED THEN

				INSERT
					(
						FIRSTLABLE,
				        FIRSTSECOND,
						FIRSTTHREE,
						FRISTFOURS,
						INVOICENO,
						DATES,
						DESCRIPTIONS,
						MODEL,
						DRNOWITHREV,
						SAPCODE,
						PKTQTY,
						LOTQTY,
						NUMBERPINTERED,
						NOTES,
						ChangeDateTime,
						ChangeUserID
					)
				VALUES
					(
							SourceTable.FIRSTLABLE,
				            SourceTable.FIRSTSECOND,
							SourceTable.FIRSTTHREE,
							SourceTable.FRISTFOURS,
							SourceTable.INVOICENO,
							SourceTable.DATES,
							SourceTable.DESCRIPTIONS,
							SourceTable.MODEL,
							SourceTable.DRNOWITHREV,
							SourceTable.SAPCODE,
							SourceTable.PKTQTY,
							SourceTable.LOTQTY,
							SourceTable.NUMBERPINTERED,
							SourceTable.NOTES,
							SourceTable.ChangeDateTime,
							SourceTable.ChangeUserID
					);

-- Process Update Table
	 MERGE STB_VN_LABLEWAHOUSEEXPORT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.FIRSTLABLE,
							XMLData.FIRSTSECOND,
							XMLData.FIRSTTHREE,
							XMLData.FRISTFOURS,
							XMLData.INVOICENO,
							XMLData.DATES,
							XMLData.DESCRIPTIONS,
							XMLData.MODEL,
							XMLData.DRNOWITHREV,
							XMLData.SAPCODE,
							XMLData.PKTQTY,
							XMLData.LOTQTY,
							XMLData.NUMBERPINTERED,
							XMLData.NOTES,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										FIRSTLABLE NVARCHAR(50),
										FIRSTSECOND NVARCHAR(50),
										FIRSTTHREE NVARCHAR(50),
										FRISTFOURS NVARCHAR(50),
										INVOICENO NVARCHAR(50),
										DATES NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(50),
										MODEL NVARCHAR(50),
										DRNOWITHREV NVARCHAR(50),
										SAPCODE NVARCHAR(50),
										PKTQTY INT,
										LOTQTY INT,
										NUMBERPINTERED INT,
										NOTES NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)
	WHEN MATCHED THEN
				UPDATE SET
					FIRSTLABLE = SourceTable.FIRSTLABLE,
					FIRSTSECOND = SourceTable.FIRSTSECOND,
					FIRSTTHREE = SourceTable.FIRSTTHREE,
					FRISTFOURS = SourceTable.FRISTFOURS,
					INVOICENO = SourceTable.INVOICENO,
					DATES = SourceTable.DATES,
					DESCRIPTIONS = SourceTable.DESCRIPTIONS,
					MODEL = SourceTable.MODEL,
					DRNOWITHREV = SourceTable.DRNOWITHREV,
					SAPCODE = SourceTable.SAPCODE,
					PKTQTY = SourceTable.PKTQTY,
					LOTQTY = SourceTable.LOTQTY,
					NUMBERPINTERED = SourceTable.NUMBERPINTERED,
					NOTES = SourceTable.NOTES,
					CreateDateTime = SourceTable.CreateDateTime,
					CreateUserID = SourceTable.CreateUserID,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

		INSERT
					(
						FIRSTLABLE,
				        FIRSTSECOND,
						FIRSTTHREE,
						FRISTFOURS,
						INVOICENO,
						DATES,
						DESCRIPTIONS,
						MODEL,
						DRNOWITHREV,
						SAPCODE,
						PKTQTY,
						LOTQTY,
						NUMBERPINTERED,
						NOTES,
						ChangeDateTime,
						ChangeUserID
					)
				VALUES
					(
							SourceTable.FIRSTLABLE,
				            SourceTable.FIRSTSECOND,
							SourceTable.FIRSTTHREE,
							SourceTable.FRISTFOURS,
							SourceTable.INVOICENO,
							SourceTable.DATES,
							SourceTable.DESCRIPTIONS,
							SourceTable.MODEL,
							SourceTable.DRNOWITHREV,
							SourceTable.SAPCODE,
							SourceTable.PKTQTY,
							SourceTable.LOTQTY,
							SourceTable.NUMBERPINTERED,
							SourceTable.NOTES,
							SourceTable.ChangeDateTime,
							SourceTable.ChangeUserID
					);
-- Process Delete Table
            MERGE STB_VN_LABLEWAHOUSEEXPORT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.FIRSTLABLE,
							XMLData.FIRSTSECOND,
							XMLData.FIRSTTHREE,
							XMLData.FRISTFOURS,
							XMLData.INVOICENO,
							XMLData.DATES,
							XMLData.DESCRIPTIONS,
							XMLData.MODEL,
							XMLData.DRNOWITHREV,
							XMLData.SAPCODE,
							XMLData.PKTQTY,
							XMLData.LOTQTY,
							XMLData.NUMBERPINTERED,
							XMLData.NOTES,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										FIRSTLABLE NVARCHAR(50),
										FIRSTSECOND NVARCHAR(50),
										FIRSTTHREE NVARCHAR(50),
										FRISTFOURS NVARCHAR(50),
										INVOICENO NVARCHAR(50),
										DATES NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(50),
										MODEL NVARCHAR(50),
										DRNOWITHREV NVARCHAR(50),
										SAPCODE NVARCHAR(50),
										PKTQTY INT,
										LOTQTY INT,
										NUMBERPINTERED INT,
										NOTES NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
										
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
							XMLData.FIRSTLABLE,
							XMLData.FIRSTSECOND,
							XMLData.FIRSTTHREE,
							XMLData.FRISTFOURS,
							XMLData.INVOICENO,
							XMLData.DATES,
							XMLData.DESCRIPTIONS,
							XMLData.MODEL,
							XMLData.DRNOWITHREV,
							XMLData.SAPCODE,
							XMLData.PKTQTY,
							XMLData.LOTQTY,
							XMLData.NUMBERPINTERED,
							XMLData.NOTES,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
								
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldCompanyCode INT,
										ID INT,
										FIRSTLABLE NVARCHAR(50),
										FIRSTSECOND NVARCHAR(50),
										FIRSTTHREE NVARCHAR(50),
										FRISTFOURS NVARCHAR(50),
										INVOICENO NVARCHAR(50),
										DATES NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(50),
										MODEL NVARCHAR(50),
										DRNOWITHREV NVARCHAR(50),
										SAPCODE NVARCHAR(50),
										PKTQTY INT,
										LOTQTY INT,
										NUMBERPINTERED INT,
										NOTES NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
											
											) XMLData
UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
							XMLData.FIRSTLABLE,
							XMLData.FIRSTSECOND,
							XMLData.FIRSTTHREE,
							XMLData.FRISTFOURS,
							XMLData.INVOICENO,
							XMLData.DATES,
							XMLData.DESCRIPTIONS,
							XMLData.MODEL,
							XMLData.DRNOWITHREV,
							XMLData.SAPCODE,
							XMLData.PKTQTY,
							XMLData.LOTQTY,
							XMLData.NUMBERPINTERED,
							XMLData.NOTES,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldCompanyCode INT,
										ID INT,
										FIRSTLABLE NVARCHAR(50),
										FIRSTSECOND NVARCHAR(50),
										FIRSTTHREE NVARCHAR(50),
										FRISTFOURS NVARCHAR(50),
										INVOICENO NVARCHAR(50),
										DATES NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(50),
										MODEL NVARCHAR(50),
										DRNOWITHREV NVARCHAR(50),
										SAPCODE NVARCHAR(50),
										PKTQTY INT,
										LOTQTY INT,
										NUMBERPINTERED INT,
										NOTES NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
								
									XMLData.ID,
							XMLData.FIRSTLABLE,
							XMLData.FIRSTSECOND,
							XMLData.FIRSTTHREE,
							XMLData.FRISTFOURS,
							XMLData.INVOICENO,
							XMLData.DATES,
							XMLData.DESCRIPTIONS,
							XMLData.MODEL,
							XMLData.DRNOWITHREV,
							XMLData.SAPCODE,
							XMLData.PKTQTY,
							XMLData.LOTQTY,
							XMLData.NUMBERPINTERED,
							XMLData.NOTES,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldCompanyCode VARCHAR(20),
											ID INT,
										FIRSTLABLE NVARCHAR(50),
										FIRSTSECOND NVARCHAR(50),
										FIRSTTHREE NVARCHAR(50),
										FRISTFOURS NVARCHAR(50),
										INVOICENO NVARCHAR(50),
										DATES NVARCHAR(50),
										DESCRIPTIONS NVARCHAR(50),
										MODEL NVARCHAR(50),
										DRNOWITHREV NVARCHAR(50),
										SAPCODE NVARCHAR(50),
										PKTQTY INT,
										LOTQTY INT,
										NUMBERPINTERED INT,
										NOTES NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
											) XMLData
					 OPEN SourceData
 WHILE 1 = 1 BEGIN

                FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldCompanyCode,
								@FIRSTLABLE,
								@FIRSTSECOND,
								@FIRSTTHREE,
								@FRISTFOURS,
								@INVOICENO,
								@DATES,
								@DESCRIPTIONS,
								@MODEL,
								@DRNOWITHREV,
								@SAPCODE,
								@PKTQTY,
								@LOTQTY,
								@NUMBERPINTERED,
								@NOTES,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
		
		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_LABLEWAHOUSEEXPORT WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_LABLEWAHOUSEEXPORT', @OldCompanyCode OUTPUT

						INSERT INTO STB_VN_LABLEWAHOUSEEXPORT
						(
								FIRSTLABLE,
								FIRSTSECOND,
								FIRSTTHREE,
								FRISTFOURS,
								INVOICENO,
								DATES,
								DESCRIPTIONS,
								MODEL,
								DRNOWITHREV,
								SAPCODE,
								PKTQTY,
								LOTQTY,
								NUMBERPINTERED,
								NOTES,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
							
						)
						VALUES
						(
								@FIRSTLABLE,
								@FIRSTSECOND,
								@FIRSTTHREE,
								@FRISTFOURS,
								@INVOICENO,
								@DATES,
								@DESCRIPTIONS,
								@MODEL,
								@DRNOWITHREV,
								@SAPCODE,
								@PKTQTY,
								@LOTQTY,
								@NUMBERPINTERED,
								@NOTES,
								DATEADD(HH, -2, GETDATE()),
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
							    
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
UPDATE STB_VN_LABLEWAHOUSEEXPORT
						SET

			FIRSTLABLE =   CASE
						                WHEN @FIRSTLABLE IS NOT NULL THEN @FIRSTLABLE
						                ELSE FIRSTLABLE
										  END,

			FIRSTSECOND =   CASE
						                WHEN @FIRSTSECOND IS NOT NULL THEN @FIRSTSECOND
						                ELSE FIRSTSECOND
										  END,

			FIRSTTHREE =   CASE
						                WHEN @FIRSTTHREE IS NOT NULL THEN @FIRSTTHREE
						                ELSE FIRSTTHREE
										  END,

			FRISTFOURS =   CASE
						                WHEN @FRISTFOURS IS NOT NULL THEN @FRISTFOURS
						                ELSE FRISTFOURS
										  END,

			INVOICENO =   CASE
						                WHEN @INVOICENO IS NOT NULL THEN @INVOICENO
						                ELSE INVOICENO
						            END,

			DATES =   CASE
						                WHEN @DATES IS NOT NULL THEN @DATES
						                ELSE DATES
						            END,
			DESCRIPTIONS =   CASE
						                WHEN @DESCRIPTIONS IS NOT NULL THEN @DESCRIPTIONS
						                ELSE DESCRIPTIONS
						            END,
						
			MODEL =   CASE
						                WHEN @MODEL IS NOT NULL THEN @MODEL
						                ELSE MODEL
						            END,

			DRNOWITHREV =   CASE
						                WHEN @DRNOWITHREV IS NOT NULL THEN @DRNOWITHREV
						                ELSE DRNOWITHREV
						            END,

			SAPCODE =   CASE
						                WHEN @SAPCODE IS NOT NULL THEN @SAPCODE
						                ELSE SAPCODE
						            END,

			PKTQTY =   CASE
						                WHEN @PKTQTY IS NOT NULL THEN @PKTQTY
						                ELSE PKTQTY
						            END,

				
			LOTQTY =   CASE
						                WHEN @LOTQTY IS NOT NULL THEN @LOTQTY
						                ELSE LOTQTY
						            END,
					
			NUMBERPINTERED =   CASE
						                WHEN @NUMBERPINTERED IS NOT NULL THEN @NUMBERPINTERED
						                ELSE NUMBERPINTERED
						            END,

					
			NOTES=   CASE
						                WHEN @NOTES IS NOT NULL THEN @NOTES
						                ELSE NOTES
						            END,

			
						
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_LABLEWAHOUSEEXPORT
						WHERE
						    ID = ''
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