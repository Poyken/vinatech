CREATE PROC usp_VN_Add_QCMoudle
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
			DECLARE @DateInput DATETIME
			DECLARE @LotNo NVARCHAR(100)
			DECLARE @Species NVARCHAR(100) 
			DECLARE @ValuesESR NVARCHAR(10)
			DECLARE @TypeSpecies NVARCHAR(10)
			DECLARE @Descriptions NVARCHAR(500)
			DECLARE @CreateDateTime DATETIME
			DECLARE @CreateUserID NVARCHAR(50)
			DECLARE @ChangeDateTime DATETIME
			DECLARE @ChangeUserID NVARCHAR(50)
			DECLARE @iDoc INT

			
		   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_QCModule',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

 IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
		  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		   BEGIN TRY

MERGE STB_VN_QCModule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.DateInput,
							XMLData.LotNo,
							XMLData.Species,
							XMLData.ValuesESR,
							XMLData.TypeSpecies,
							XMLData.Descriptions,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										DateInput  DATETIME,
										LotNo NVARCHAR(100),
										Species NVARCHAR(100),
										ValuesESR NVARCHAR(100),
										TypeSpecies NVARCHAR(100),
										Descriptions NVARCHAR(500),
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
					DateInput =  SourceTable.DateInput,
					LotNo = SourceTable.LotNo,
					Species = SourceTable.Species,
					ValuesESR = SourceTable.ValuesESR, 
					TypeSpecies = SourceTable.TypeSpecies,
					Descriptions = SourceTable.Descriptions,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

		WHEN NOT MATCHED THEN
		INSERT
					(
						
						DateInput,
						LotNo,
						Species,
						ValuesESR,
						TypeSpecies,
						Descriptions,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DateInput,
						    SourceTable.LotNo,
							SourceTable.Species,
							SourceTable.ValuesESR,
							SourceTable.TypeSpecies,
							SourceTable.Descriptions,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

MERGE STB_VN_QCModule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.DateInput,
							XMLData.LotNo,
							XMLData.Species,
							XMLData.ValuesESR,
							XMLData.TypeSpecies,
							XMLData.Descriptions,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										DateInput  DATETIME,
										LotNo NVARCHAR(100),
										Species NVARCHAR(100),
										ValuesESR NVARCHAR(100),
										TypeSpecies NVARCHAR(100),
										Descriptions NVARCHAR(500),
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
									XMLData.DateInput,
									XMLData.LotNo,
									XMLData.Species,
									XMLData.ValuesESR,
									XMLData.TypeSpecies,
									XMLData.Descriptions,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
										OldCompanyCode INT,
										ID INT,
										DateInput  DATETIME,
										LotNo NVARCHAR(100),
										Species NVARCHAR(100),
										ValuesESR NVARCHAR(100),
										TypeSpecies NVARCHAR(100),
										Descriptions NVARCHAR(500),
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
									XMLData.DateInput,
									XMLData.LotNo,
									XMLData.Species,
									XMLData.ValuesESR,
									XMLData.TypeSpecies,
									XMLData.Descriptions,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
										OldCompanyCode INT,
										ID INT,
										DateInput  DATETIME,
										LotNo NVARCHAR(100),
										Species NVARCHAR(100),
										ValuesESR NVARCHAR(100),
										TypeSpecies NVARCHAR(100),
										Descriptions NVARCHAR(500),
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
									XMLData.DateInput,
									XMLData.LotNo,
									XMLData.Species,
									XMLData.ValuesESR,
									XMLData.TypeSpecies,
									XMLData.Descriptions,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldCompanyCode INT,
											ID INT,
											DateInput  DATETIME,
											LotNo NVARCHAR(100),
											Species NVARCHAR(100),
											ValuesESR NVARCHAR(100),
											TypeSpecies NVARCHAR(100),
											Descriptions NVARCHAR(500),
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
								 @DateInput,
								 @LotNo,
								 @Species,
								 @ValuesESR,
								 @TypeSpecies,
								 @Descriptions,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			
		  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

		     IF EXISTS (SELECT 1 FROM STB_VN_QCModule WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
	 IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_QCModule', @OldCompanyCode OUTPUT

INSERT INTO STB_VN_QCModule
						(
							DateInput,
							LotNo,
							Species,
							ValuesESR,
							TypeSpecies,
							Descriptions,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
								 @DateInput,
								 @LotNo,
								 @Species,
								 @ValuesESR,
								 @TypeSpecies,
								 @Descriptions,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

	 UPDATE STB_VN_QCModule

	  SET

							DateInput =   CASE
						                WHEN @DateInput IS NOT NULL THEN @DateInput
						                ELSE DateInput
						            END,

							LotNo =   CASE
						                WHEN @LotNo IS NOT NULL THEN @LotNo
						                ELSE LotNo
						            END,

						
					
						Species =   CASE
						                WHEN @Species IS NOT NULL THEN @Species
						                ELSE Species
						            END,

					   ValuesESR= CASE
						                WHEN @ValuesESR IS NOT NULL THEN @ValuesESR
						                ELSE ValuesESR
						            END,
						
					   TypeSpecies= CASE
						                WHEN @TypeSpecies IS NOT NULL THEN @TypeSpecies
						                ELSE TypeSpecies
						            END,
						Descriptions= CASE
						                WHEN @Descriptions IS NOT NULL THEN @Descriptions
						                ELSE Descriptions
						            END,
						
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					WHERE
						    ID = @OldCompanyCode
			END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
	
                        DELETE FROM STB_VN_QCModule
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