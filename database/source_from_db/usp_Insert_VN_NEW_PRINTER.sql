--select * from STB_VN_NEW_PRINTER

CREATE PROC [dbo].[usp_Insert_VN_NEW_PRINTER]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	
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
		DECLARE @Barcode NVARCHAR(50)
		DECLARE @MaterialName NVARCHAR(50)
		DECLARE @MaterialCode NVARCHAR(30)
		DECLARE @LotQty INT
		DECLARE @LabelQty INT
		DECLARE @Voltage NVARCHAR(30)
		DECLARE @Farad NVARCHAR(30)
		DECLARE @Rating NVARCHAR(30)
		DECLARE @PartNo NVARCHAR(30)
		DECLARE @StatusPrinter BIT
	
		DECLARE @iDoc INT
		DECLARE @CreateDateTime DATETIME
        DECLARE @CreateUserID NVARCHAR(20)
        DECLARE @ChangeDateTime DATETIME
        DECLARE @ChangeUserID NVARCHAR(20)

		   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_NEW_PRINTER',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
		  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		  BEGIN TRY

		  SELECT
		TOP(1)
			MaterialCode,
			MaterialName,
			Barcode,
			 LabelQty,
			LotQty,
			--REPLACE(SI.Barcode, 'VV', 'VJ') AS LotNo,
			Voltage,
			 Farad,
			 Rating,
			 PartNo,
			'Report' AS CommandType

	FROM
			STB_VN_NEW_PRINTER WITH (NOLOCK)

		   MERGE STB_VN_NEW_PRINTER AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.Barcode,
							XMLData.MaterialName,
							XMLData.MaterialCode,
							XMLData.LotQty,
							XMLData.LabelQty,
							XMLData.Voltage,
							XMLData.Farad,
							XMLData.Rating,
							XMLData.PartNo,
							XMLData.StatusPrinter,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@ProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@ProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										Barcode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										MaterialCode  NVARCHAR(30),
										LotQty INT,
										LabelQty INT,
										Voltage NVARCHAR(30),
										Farad NVARCHAR(30),
										Rating NVARCHAR(30),
										PartNo NVARCHAR(30),
										StatusPrinter BIT,
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
					Barcode = SourceTable.Barcode,
					MaterialName = SourceTable.MaterialName,
					MaterialCode = SourceTable.MaterialCode,
					LotQty = SourceTable.LotQty,
					LabelQty = SourceTable.LabelQty,
					Voltage = SourceTable.Voltage,
					Farad = SourceTable.Farad,
					Rating = SourceTable.Rating,
					PartNo = SourceTable.PartNo,
					StatusPrinter = '0',
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

	WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						MaterialName,
						MaterialCode,
						LotQty,
						LabelQty,
						Voltage,
						Farad,
						Rating,
						PartNo,
						StatusPrinter,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.MaterialName,
							SourceTable.MaterialCode,
							SourceTable.LotQty,
							SourceTable.LabelQty,
							SourceTable.Voltage,
							SourceTable.Farad,
							SourceTable.Rating,
							SourceTable.PartNo,
							'0',
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
							
					);

					 MERGE STB_VN_NEW_PRINTER AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.Barcode,
							XMLData.MaterialName,
							XMLData.MaterialCode,
							XMLData.LotQty,
							XMLData.LabelQty,
							XMLData.Voltage,
							XMLData.Farad,
							XMLData.Rating,
							XMLData.PartNo,
							XMLData.StatusPrinter,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@ProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@ProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										Barcode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										MaterialCode  NVARCHAR(30),
										LotQty INT,
										LabelQty INT,
										Voltage NVARCHAR(30),
										Farad NVARCHAR(30),
										Rating NVARCHAR(30),
										PartNo NVARCHAR(30),
										StatusPrinter BIT,
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
					Barcode = SourceTable.Barcode,
					MaterialName = SourceTable.MaterialName,
					MaterialCode = SourceTable.MaterialCode,
					LotQty = SourceTable.LotQty,
					LabelQty = SourceTable.LabelQty,
					Voltage = SourceTable.Voltage,
					Farad = SourceTable.Farad,
					Rating = SourceTable.Rating,
					PartNo = SourceTable.PartNo,
					StatusPrinter = '0',
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID	
		WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						MaterialName,
						MaterialCode,
						LotQty,
						LabelQty,
						Voltage,
						Farad,
						Rating,
						PartNo,
						StatusPrinter,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.MaterialName,
							SourceTable.MaterialCode,
							SourceTable.LotQty,
							SourceTable.LabelQty,
							SourceTable.Voltage,
							SourceTable.Farad,
							SourceTable.Rating,
							SourceTable.PartNo,
							'0',
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

     MERGE STB_VN_NEW_PRINTER AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.Barcode,
							XMLData.MaterialName,
							XMLData.MaterialCode,
							XMLData.LotQty,
							XMLData.LabelQty,
							XMLData.Voltage,
							XMLData.Farad,
							XMLData.Rating,
							XMLData.PartNo,
							XMLData.StatusPrinter,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@ProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@ProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										Barcode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										MaterialCode  NVARCHAR(30),
										LotQty INT,
										LabelQty INT,
										Voltage NVARCHAR(30),
										Farad NVARCHAR(30),
										Rating NVARCHAR(30),
										PartNo NVARCHAR(30),
										StatusPrinter BIT,
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
									XMLData.Barcode,
									XMLData.MaterialName,
									XMLData.MaterialCode,
									XMLData.LotQty,
									XMLData.LabelQty,
									XMLData.Voltage,
									XMLData.Farad,
									XMLData.Rating,
									XMLData.PartNo,
									XMLData.StatusPrinter,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 Barcode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 MaterialCode  NVARCHAR(30),
											 LotQty INT,
											 LabelQty INT,
											 Voltage NVARCHAR(30),
											 Farad NVARCHAR(30),
											 Rating NVARCHAR(30),
											 PartNo NVARCHAR(30),
											 StatusPrinter BIT,
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
									XMLData.Barcode,
									XMLData.MaterialName,
									XMLData.MaterialCode,
									XMLData.LotQty,
									XMLData.LabelQty,
									XMLData.Voltage,
									XMLData.Farad,
									XMLData.Rating,
									XMLData.PartNo,
									XMLData.StatusPrinter,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								

						FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 Barcode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 MaterialCode  NVARCHAR(30),
											 LotQty INT,
											 LabelQty INT,
											 Voltage NVARCHAR(30),
											 Farad NVARCHAR(30),
											 Rating NVARCHAR(30),
											 PartNo NVARCHAR(30),
											 StatusPrinter BIT,
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
									XMLData.Barcode,
									XMLData.MaterialName,
									XMLData.MaterialCode,
									XMLData.LotQty,
									XMLData.LabelQty,
									XMLData.Voltage,
									XMLData.Farad,
									XMLData.Rating,
									XMLData.PartNo,
									XMLData.StatusPrinter,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 Barcode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 MaterialCode  NVARCHAR(30),
											 LotQty INT,
											 LabelQty INT,
											 Voltage NVARCHAR(30),
											 Farad NVARCHAR(30),
											 Rating NVARCHAR(30),
											 PartNo NVARCHAR(30),
											 StatusPrinter BIT,
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
								 @Barcode,
								 @MaterialName,
								 @MaterialCode,
								 @LotQty,
								 @LabelQty,
								 @Voltage,
								 @Farad,
								 @Rating,
								 @PartNo,
								 @StatusPrinter,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								 

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_NEW_PRINTER WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_PRODUCTION_ERROR', @OldCompanyCode OUTPUT

							INSERT INTO STB_VN_NEW_PRINTER
						(
						    Barcode,
						    MaterialName,
						    MaterialCode,
						    LotQty,
						    LabelQty,
						    Voltage,
							Farad,
							Rating,
							PartNo,
							StatusPrinter,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						
						)
						VALUES
						(
						    @Barcode,
						    @MaterialName,
						    @MaterialCode,
						    @LotQty,
						    @LabelQty,
						    @Voltage,
							@Farad,
							@Rating,
							@PartNo,
							'0',
						    DATEADD(HH, -2, GETDATE()),
						    @ProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

						END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_NEW_PRINTER
						SET
							Barcode =   CASE
						                WHEN @Barcode IS NOT NULL THEN @Barcode
						                ELSE Barcode
						            END,
						MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,

							 MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,

							 LotQty =   CASE
						                WHEN @LotQty IS NOT NULL THEN @LotQty
						                ELSE LotQty
						            END,
							 LabelQty =   CASE
						                WHEN @LabelQty IS NOT NULL THEN @LabelQty
						                ELSE LabelQty
						            END,
						 Voltage =   CASE
						                WHEN @Voltage IS NOT NULL THEN @Voltage
						                ELSE Voltage
						            END,
						 Farad =   CASE
						                WHEN @Farad IS NOT NULL THEN @Farad
						                ELSE Farad
						            END,
						 Rating =   CASE
						                WHEN @Rating IS NOT NULL THEN @Rating
						                ELSE Rating
						            END,
						 PartNo =   CASE
						                WHEN @PartNo IS NOT NULL THEN @PartNo
						                ELSE PartNo
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @ProcessUserID
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_NEW_PRINTER
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

--SELECT * FROM STB_VN_NEW_PRINTER