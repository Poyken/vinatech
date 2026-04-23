CREATE PROC [dbo].[usp_VN_Import_Modules]
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
	DECLARE @GROUPID NVARCHAR(100)
	DECLARE @TYPEIMPORT NVARCHAR(20)
	DECLARE @IMPORT BIT
	DECLARE @DESCRIPTIONIMPORT NVARCHAR(500)
	DECLARE @DATEIMPORT DATETIME
	DECLARE @PERSONIMPORT NVARCHAR(50)
	DECLARE @FLAG BIT
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT


	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_MASTERMODULES',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN

		 EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
 BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_MASTERMODULES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.GROUPID,
							XMLData.TYPEIMPORT,
							XMLData.IMPORT,
							XMLData.DESCRIPTIONSIMPORT,
							XMLData.FLAG,
							DATEADD(HH, -2, GETDATE()) AS DATEIMPORT,
							@pProcessUserID AS PERSONIMPORT
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode NVARCHAR(50),
										GROUPID NVARCHAR(100),
										TYPEIMPORT NVARCHAR(50),
										IMPORT BIT,
										DESCRIPTIONSIMPORT NVARCHAR(500),
										FLAG BIT,
										DATEIMPORT  DATETIMEOFFSET,
										PERSONIMPORT NVARCHAR(50)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.GROUPID = SourceTable.GROUPID
				)

WHEN MATCHED THEN
				UPDATE SET

					GROUPID = SourceTable.GROUPID,
					TYPEIMPORT = N'Nhập',
					IMPORT = SourceTable.IMPORT,
					DESCRIPTIONSIMPORT = SourceTable.DESCRIPTIONSIMPORT,
					FLAG = '1',
					DATEIMPORT = SourceTable.DATEIMPORT,
					PERSONIMPORT = SourceTable.PERSONIMPORT

		WHEN NOT MATCHED THEN

				INSERT
					(
							GROUPID,
							TYPEIMPORT,
							IMPORT,
							DESCRIPTIONSIMPORT,
							FLAG
					)
				VALUES
					(
							SourceTable.GROUPID,
							N'Nhập',
							SourceTable.IMPORT,
							SourceTable.DESCRIPTIONSIMPORT,
							'1'
					);

					-- Process Update Table
	 MERGE STB_VN_MASTERMODULES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.GROUPID,
							XMLData.TYPEIMPORT,
							XMLData.IMPORT,
							XMLData.DESCRIPTIONSIMPORT,
							XMLData.Flag,
							 DATEADD(HH, -2, GETDATE()) AS DATEIMPORT,
							  @pProcessUserID AS PERSONIMPORT
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode NVARCHAR(100),
										GROUPID NVARCHAR(100),
										TYPEIMPORT NVARCHAR(50),
										IMPORT  BIT,
										DESCRIPTIONSIMPORT NVARCHAR(500),
										Flag BIT,
										DATEIMPORT  DATETIMEOFFSET,
										PERSONIMPORT NVARCHAR(50)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.GROUPID = SourceTable.GROUPID
				)

				
	 	WHEN MATCHED THEN

				UPDATE SET

					GROUPID = SourceTable.GROUPID,
					TYPEIMPORT = N'Nhập',
					IMPORT = SourceTable.IMPORT,
					DESCRIPTIONSIMPORT = SourceTable.DESCRIPTIONSIMPORT ,
					Flag = '1',
					DATEIMPORT = SourceTable.DATEIMPORT,
					PERSONIMPORT = SourceTable.PERSONIMPORT
		
		WHEN NOT MATCHED THEN

			INSERT
					(
							GROUPID,
							TYPEIMPORT,
							IMPORT,
							DESCRIPTIONSIMPORT,
							Flag

					)
				VALUES
					(
							SourceTable.GROUPID,
							SourceTable.TYPEIMPORT,
							SourceTable.IMPORT,
							SourceTable.DESCRIPTIONSIMPORT,
							'1'
							
					);

-- Process Delete Table
            MERGE STB_VN_MASTERMODULES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.GROUPID,
							XMLData.TYPEIMPORT,
							XMLData.IMPORT,
							XMLData.DESCRIPTIONIMPORT,
							XMLData.Flag,
							 DATEADD(HH, -2, GETDATE()) AS DATEIMPORT,
							@pProcessUserID AS PERSONIMPORT
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode NVARCHAR(50),
										GROUPID NVARCHAR(100),
										TYPEIMPORT NVARCHAR(100),
										IMPORT BIT,
										DESCRIPTIONIMPORT NVARCHAR(500),
										Flag BIT,
										DATEIMPORT  DATETIMEOFFSET,
										PERSONIMPORT NVARCHAR(50)
										
										
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.GROUPID = SourceTable.GROUPID
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
									XMLData.GROUPID,
									XMLData.TYPEIMPORT,
									XMLData.IMPORT,
									XMLData.DESCRIPTIONIMPORT,
									XMLData.FLAG,
									XMLData.DATEIMPORT,
									XMLData.PERSONIMPORT 
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
										    OldCompanyCode NVARCHAR(50),
											GROUPID NVARCHAR(100),
											TYPEIMPORT NVARCHAR(100),
											IMPORT BIT,
											DESCRIPTIONIMPORT NVARCHAR(500),
											FLAG BIT,
											DATEIMPORT  DATETIMEOFFSET,
											PERSONIMPORT NVARCHAR(50)
											 
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.GROUPID,
									XMLData.TYPEIMPORT,
									XMLData.IMPORT,
									XMLData.DESCRIPTIONIMPORT,
									XMLData.FLAG,
									XMLData.DATEIMPORT,
									XMLData.PERSONIMPORT
									
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldCompanyCode NVARCHAR(50),
											GROUPID  NVARCHAR(50),
											TYPEIMPORT NVARCHAR(100),
											IMPORT BIT,
											DESCRIPTIONIMPORT NVARCHAR(500),
											FLAG BIT,
											DATEIMPORT  DATETIMEOFFSET,
											PERSONIMPORT NVARCHAR(50) 
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.GROUPID,
								    XMLData.TYPEIMPORT,
									XMLData.IMPORT,
									XMLData.DESCRIPTIONIMPORT,
									XMLData.FLAG,
									XMLData.DATEIMPORT,
									XMLData.PERSONIMPORT
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldCompanyCode NVARCHAR(50),
											GROUPID NVARCHAR(50),
											TYPEIMPORT NVARCHAR(100),
											IMPORT BIT,
											DESCRIPTIONIMPORT NVARCHAR(500),
											Flag BIT,
											DATEIMPORT  DATETIMEOFFSET,
											PERSONIMPORT NVARCHAR(50) 
											) XMLData
					 OPEN SourceData

	   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @GROUPID,
								 @TYPEIMPORT,
								 @IMPORT,
								 @DESCRIPTIONIMPORT,
								 @Flag,
								 @DATEIMPORT,
								 @PERSONIMPORT 
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		IF @IUD_FLAG = 'INSERT' BEGIN

		  IF EXISTS (SELECT 1 FROM STB_VN_MASTERMODULES WHERE GROUPID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_MASTERMODULES', @OldCompanyCode OUTPUT	
						
						INSERT INTO STB_VN_MASTERMODULES
						(
						   	GROUPID,
							TYPEIMPORT,
							IMPORT,
							DESCRIPTIONSIMPORT,
							Flag
						)
						VALUES
						(
							@GROUPID,
							N'Nhập',
							@IMPORT,
							@PERSONIMPORT,
							'1'
						)

						END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

UPDATE STB_VN_MASTERMODULES

						SET
						
						 TYPEIMPORT =   CASE
						                WHEN @TYPEIMPORT IS NOT NULL THEN @TYPEIMPORT
						                ELSE TYPEIMPORT
						            END,

						 IMPORT =   CASE
						                WHEN @IMPORT IS NOT NULL THEN @IMPORT
						                ELSE IMPORT
						            END,

									 DESCRIPTIONSIMPORT =   CASE
						                WHEN @DESCRIPTIONIMPORT IS NOT NULL THEN @DESCRIPTIONIMPORT
						                ELSE DESCRIPTIONSIMPORT
						            END ,
						    DATEIMPORT = DATEADD(HH, -2, GETDATE()),
						    PERSONIMPORT = @pProcessUserID
						
					
					WHERE
						    GROUPID = @OldCompanyCode

			  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_MASTERMODULES
						WHERE
						    GROUPID = @OldCompanyCode
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