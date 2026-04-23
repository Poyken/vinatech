CREATE PROC usp_VN_Add_STB_VN_STAMP_MODULE
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
-- SELECT * FROM STB_VN_STAMP_MODULE

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

	DECLARE @OldCompanyCode NVARCHAR(100)
	DECLARE @Voltage NVARCHAR(50)
	DECLARE @Farad NVARCHAR(50)
	DECLARE @Rating NVARCHAR(50)
	DECLARE @PartNo NVARCHAR(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT


	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_STAMP_MODULE',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN

	  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	  	BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_STAMP_MODULE AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.Voltage,
							XMLData.Farad,
							XMLData.Rating,
							XMLData.PartNo,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										Voltage NVARCHAR(50),
										Farad NVARCHAR(50),
										Rating NVARCHAR(50),
										PartNo NVARCHAR(50),
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
					
					Voltage =  SourceTable.Voltage,
					Farad =  SourceTable.Farad,
					Rating =  SourceTable.Rating,
					PartNo =  SourceTable.PartNo ,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

		WHEN NOT MATCHED THEN

				INSERT
					(
					Voltage,
					Farad,
					Rating,
					PartNo,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							SourceTable.Voltage,
							SourceTable.Farad,
							SourceTable.Rating,
							SourceTable.PartNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

 MERGE STB_VN_STAMP_MODULE AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.Voltage,
							XMLData.Farad,
							XMLData.Rating,
							XMLData.PartNo,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										Voltage NVARCHAR(50),
										Farad NVARCHAR(50),
										Rating NVARCHAR(50),
										PartNo NVARCHAR(50),
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

					Voltage = SourceTable.Voltage,
					Farad = SourceTable.Farad,
					Rating = SourceTable.Rating,
					PartNo = SourceTable.PartNo,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

	WHEN NOT MATCHED THEN

				INSERT
					(
					Voltage,
					Farad,
					Rating,
					PartNo,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							SourceTable.Voltage,
							SourceTable.Farad,
							SourceTable.Rating,
							SourceTable.PartNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

-- Process Delete Table
            MERGE STB_VN_DEVICEMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
						    XMLData.Voltage,
							XMLData.Farad,
							XMLData.Rating,
							XMLData.PartNo,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										Voltage NVARCHAR(50),
										Farad NVARCHAR(50),
										Rating NVARCHAR(50),
										PartNo NVARCHAR(50),
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
									 XMLData.Voltage,
									 XMLData.Farad ,
									 XMLData.Rating,
									 XMLData.PartNo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 Voltage NVARCHAR(50),
											 Farad NVARCHAR(50),
											 Rating NVARCHAR(50),
											 PartNo NVARCHAR(50),
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
									XMLData.Voltage,
									XMLData.Farad,
									XMLData.Rating,
									XMLData.PartNo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 Voltage NVARCHAR(50),
											 Farad NVARCHAR(50),
											 Rating NVARCHAR(50),
											 PartNo NVARCHAR(50),
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
									XMLData.Voltage,
									XMLData.Farad,
									XMLData.Rating,
									XMLData.PartNo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 Voltage NVARCHAR(50),
											 Farad NVARCHAR(50),
											 Rating NVARCHAR(50),
											 PartNo NVARCHAR(50),
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
								 @Voltage,
								 @Farad,
								 @Rating,
								 @PartNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_STAMP_MODULE WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_STAMP_MODULE', @OldCompanyCode OUTPUT		
INSERT INTO STB_VN_STAMP_MODULE
						(
						    Voltage,
							Farad,
							Rating,
							PartNo,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
							@Voltage,
							@Farad,
							@Rating,
							@PartNo,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
							
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_VN_STAMP_MODULE

						SET
						
								
									 Voltage  =   CASE
						                WHEN @Voltage  IS NOT NULL THEN @Voltage 
						                ELSE Voltage 
						            END,

									Farad  =   CASE
						                WHEN @Farad  IS NOT NULL THEN @Farad 
						                ELSE Farad 
						            END,

										Rating  =   CASE
						                WHEN @Rating  IS NOT NULL THEN @Rating 
						                ELSE Rating 
						            END,

									PartNo  =   CASE
						                WHEN @PartNo  IS NOT NULL THEN @PartNo 
						                ELSE PartNo 
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE
						    ID = ''

		  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_STAMP_MODULE
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