CREATE PROC [dbo].[usp_VN_update_finishedgood]
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

	DECLARE @OldCompanyCode NVARCHAR(100)
	DECLARE @IDCODE NVARCHAR(50)
	DECLARE @Statusout NVARCHAR(50)
	DECLARE @MethodActions1 NVARCHAR(50)
	DECLARE @DateExport NVARCHAR(50)
	DECLARE @PersonExport NVARCHAR(50)
	DECLARE @iDoc INT

			EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_FINISHGOODS',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

			IF @IsAutoKey = 0 AND @IsLoopIUD = 0 

			BEGIN

			 EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

			BEGIN TRY

			 MERGE STB_VN_FINISHGOODS AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDCODE
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDCODE,
							XMLData.Statusout,
							XMLData.MethodActions1,
							XMLData.DateExport,
							XMLData.PersonExport
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDCODE NVARCHAR(50),
										Statusout NVARCHAR(50),
										MethodActions1 NVARCHAR(50),
										DateExport NVARCHAR(50),
										PersonExport NVARCHAR(50)
										
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.IDCODE = SourceTable.IDCODE
				)
	 
				WHEN MATCHED THEN

			UPDATE SET
					
						Statusout = N'Xuất',
						MethodActions1 = N'Xuất bằng scan barcode',
						DateExport = DATEADD(HH, -2, GETDATE()),
						PersonExport =  @pProcessUserID

		WHEN NOT MATCHED THEN

				INSERT
					(
						Statusout,
						MethodActions1,
						DateExport,
						PersonExport
					)
				VALUES
					(
						SourceTable.Statusout,
						SourceTable.MethodActions1,
						SourceTable.DateExport,
						SourceTable.PersonExport
					);

MERGE STB_VN_FINISHGOODS AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDCODE
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDCODE,
							XMLData.Statusout,
							XMLData.MethodActions1,
							XMLData.DateExport,
							XMLData.PersonExport
						
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDCODE NVARCHAR(50),
										Statusout NVARCHAR(50),
										MethodActions1 NVARCHAR(50),
										DateExport NVARCHAR(50),
										PersonExport NVARCHAR(50)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.IDCODE = SourceTable.IDCODE
				)

	WHEN MATCHED THEN

			UPDATE SET

						Statusout = N'Xuất',
						MethodActions1 = N'Xuất bằng scan barcode',
						DateExport = DATEADD(HH, -2, GETDATE()),
						PersonExport =  @pProcessUserID

	WHEN NOT MATCHED THEN

				INSERT
					(
						Statusout,
						MethodActions1,
						DateExport,
						PersonExport
					)
				VALUES
					(
						SourceTable.Statusout,
						SourceTable.MethodActions1,
						SourceTable.DateExport,
						SourceTable.PersonExport
					);

   MERGE STB_VN_FINISHGOODS AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDCODE
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDCODE,
						    XMLData.Statusout,
							XMLData.MethodActions1,
							XMLData.DateExport,
							XMLData.PersonExport
						
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDCODE NVARCHAR(50),
										Statusout NVARCHAR(50),
										MethodActions1 NVARCHAR(50),
										DateExport NVARCHAR(50),
										PersonExport NVARCHAR(50)
									
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.IDCODE = SourceTable.IDCODE
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
									XMLData.IDCODE,
									XMLData.Statusout,
									XMLData.MethodActions1,
									XMLData.DateExport,
									XMLData.PersonExport
								
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDCODE NVARCHAR(50),
											 Statusout NVARCHAR(50),
											 MethodActions1 NVARCHAR(50),
											 DateExport NVARCHAR(50),
											 PersonExport NVARCHAR(50)
											 
											) XMLData
							UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDCODE
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDCODE,
									XMLData.Statusout,
									XMLData.MethodActions1,
									XMLData.DateExport,
									XMLData.PersonExport
								
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDCODE NVARCHAR(50),
											 Statusout NVARCHAR(50),
											 MethodActions1 NVARCHAR(50),
											 DateExport NVARCHAR(50),
											 PersonExport NVARCHAR(50)

											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDCODE
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDCODE,
									XMLData.Statusout,
									XMLData.MethodActions1,
									XMLData.DateExport,
									XMLData.PersonExport
								
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 IDCODE NVARCHAR(50),
											 Statusout NVARCHAR(50),
											 MethodActions1 NVARCHAR(50),
											 DateExport NVARCHAR(50),
											 PersonExport NVARCHAR(50)
											
											) XMLData
					 OPEN SourceData

	    WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @Statusout,
								 @MethodActions1,
								 @DateExport,
								 @PersonExport
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS WHERE IDCODE = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS', @OldCompanyCode OUTPUT	

INSERT INTO STB_VN_FINISHGOODS
						(
								 Statusout,
								 MethodActions1,
								 DateExport,
								 PersonExport
							
						)
						VALUES
						(
								 @Statusout,
								 @MethodActions1,
								 @DateExport,
								 @PersonExport
							
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
UPDATE STB_VN_FINISHGOODS

						SET
									 Statusout  =   CASE
						                WHEN @Statusout  IS NOT NULL THEN @Statusout 
						                ELSE Statusout 
						            END,

									 MethodActions1  =   CASE
						                WHEN @MethodActions1  IS NOT NULL THEN @MethodActions1 
						                ELSE MethodActions1 
						            END,

									 DateExport  =   CASE
						                WHEN @DateExport  IS NOT NULL THEN @DateExport 
						                ELSE DateExport 
						            END,

									 PersonExport  =   CASE
						                WHEN @PersonExport  IS NOT NULL THEN @PersonExport
						                ELSE PersonExport 
						            END

								
					WHERE
						    IDCODE = @IDCODE

		  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_FINISHGOODS
						WHERE
						    IDCODE = ''
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