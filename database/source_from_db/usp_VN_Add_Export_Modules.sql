CREATE PROC [dbo].[usp_VN_Add_Export_Modules]
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
	DECLARE @LOTNO NVARCHAR(50)
	DECLARE @QTY INT
	DECLARE @VOL NVARCHAR(30)
	DECLARE @FWAR NVARCHAR(20)
	DECLARE @PARTNO NVARCHAR(50)
	DECLARE @SIZE NVARCHAR(20)
    DECLARE @EXPORT BIT
	DECLARE @COUNTRY NVARCHAR(50)
	DECLARE @Flag BIT
	DECLARE @DESCRIPTIONS_EXPORT NVARCHAR(500) 
	DECLARE @TYPEACTION_EXPORT NVARCHAR(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_MODULE_EXPORT_IMPORT',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN

		 EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		 BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_MODULE_EXPORT_IMPORT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.GROUPID,
							XMLData.LOTNO,
							XMLData.QTY,
							XMLData.VOL,
							XMLData.FWAR,
							XMLData.PARTNO,
							XMLData.SIZE,
							XMLData.EXPORT,
							XMLData.DESCRIPTIONS_EXPORT,
							XMLData.TYPEACTION_EXPORT,
							XMLData.COUNTRY,
							XMLData.Flag,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode NVARCHAR(50),
										GROUPID NVARCHAR(100),
										LOTNO NVARCHAR(50),
										QTY INT,
										VOL NVARCHAR(30),
										FWAR NVARCHAR(30),
										PARTNO NVARCHAR(50),
										SIZE NVARCHAR(20),
										EXPORT BIT,
										DESCRIPTIONS_EXPORT  NVARCHAR(500),
										COUNTRY NVARCHAR(50),
										TYPEACTION_EXPORT NVARCHAR(50),
										Flag BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.GROUPID = SourceTable.GROUPID
				)
	 
	 	WHEN MATCHED THEN
				UPDATE SET

					GROUPID = SourceTable.GROUPID,
					LOTNO = SourceTable.LOTNO,
					QTY = SourceTable.QTY,
					VOL = SourceTable.VOL,
					FWAR = SourceTable.FWAR,
					PARTNO = SourceTable.PARTNO,
					SIZE = SourceTable.SIZE,
					EXPORT = '1',
					DESCRIPTIONS_EXPORT = SourceTable.DESCRIPTIONS_EXPORT,
					TYPEACTION_EXPORT =N'Nhập',
					COUNTRY = SourceTable.COUNTRY,
					Flag = '1',
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

		WHEN NOT MATCHED THEN

				INSERT
					(
							GROUPID,
							LOTNO,
							QTY,
							VOL,
							FWAR,
							PARTNO,
							SIZE,
							EXPORT,
							DESCRIPTIONS_EXPORT,
							TYPEACTION_EXPORT,
							COUNTRY,
							Flag,
							CreateDateTime,
							CreateUserID
					)
				VALUES
					(
							
							SourceTable.GROUPID,
							SourceTable.LOTNO,
							SourceTable.QTY,
							SourceTable.VOL,
							SourceTable.FWAR,
							SourceTable.PARTNO,
							SourceTable.SIZE,
							'1',
							SourceTable.DESCRIPTIONS_EXPORT,
							N'Nhập',
							SourceTable.COUNTRY,
							'1',
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

					-- Process Update Table
	 MERGE STB_VN_MODULE_EXPORT_IMPORT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.GROUPID,
							XMLData.LOTNO,
							XMLData.QTY,
							XMLData.VOL,
							XMLData.FWAR,
							XMLData.PARTNO,
							XMLData.SIZE,
							XMLData.EXPORT,
							XMLData.DESCRIPTIONS_EXPORT,
							XMLData.TYPEACTION_EXPORT,
							XMLData.COUNTRY,
							XMLData.Flag,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode NVARCHAR(100),
										GROUPID NVARCHAR(100),
										LOTNO NVARCHAR(50),
										QTY  INT,
										VOL NVARCHAR(20),
										FWAR NVARCHAR(30),
										PARTNO NVARCHAR(100),
										SIZE NVARCHAR(20),
										EXPORT BIT,
										DESCRIPTIONS_EXPORT NVARCHAR(500),
										TYPEACTION_EXPORT NVARCHAR(50),
										COUNTRY NVARCHAR(50),
										Flag BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.GROUPID = SourceTable.GROUPID
				)

				
	 	WHEN MATCHED THEN

				UPDATE SET

					GROUPID = SourceTable.GROUPID,
					LOTNO = SourceTable.LOTNO,
					QTY = SourceTable.QTY,
					VOL = SourceTable.VOL,
					FWAR = SourceTable.FWAR,
					PARTNO = SourceTable.PARTNO,
					SIZE = SourceTable.SIZE,
					EXPORT = '1',
					DESCRIPTIONS_EXPORT = SourceTable.DESCRIPTIONS_EXPORT,
					TYPEACTION_EXPORT =N'Nhập',
					COUNTRY = SourceTable.COUNTRY,
					Flag = '1',
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
		
		WHEN NOT MATCHED THEN

			INSERT
					(
					GROUPID,
					LOTNO,
					QTY,
					VOL,
					FWAR,
					PARTNO,
					SIZE,
					EXPORT,
					DESCRIPTIONS_EXPORT,
					TYPEACTION_EXPORT,
					COUNTRY,
					Flag,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							
							SourceTable.GROUPID,
							SourceTable.LOTNO,
							SourceTable.QTY,
							SourceTable.VOL,
							SourceTable.FWAR,
							SourceTable.PARTNO,
							SourceTable.SIZE,
							'1',
							SourceTable.DESCRIPTIONS_EXPORT,
							N'Nhập',
							SourceTable.COUNTRY,
							'1',
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);


	-- Process Delete Table
            MERGE STB_VN_MODULE_EXPORT_IMPORT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.GROUPID,
							XMLData.LOTNO,
							XMLData.QTY,
							XMLData.VOL,
							XMLData.FWAR,
							XMLData.PARTNO,
							XMLData.SIZE,
							XMLData.EXPORT,
							XMLData.DESCRIPTIONS_EXPORT,
							XMLData.TYPEACTION_EXPORT,
							XMLData.COUNTRY,
							XMLData.Flag,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode NVARCHAR(50),
										GROUPID NVARCHAR(100),
										LOTNO NVARCHAR(100),
										QTY INT,
										VOL NVARCHAR(100),
										FWAR NVARCHAR(100),
										PARTNO NVARCHAR(100),
										SIZE NVARCHAR(100),
										EXPORT BIT,
										DESCRIPTIONS_EXPORT NVARCHAR(500),
										TYPEACTION_EXPORT NVARCHAR(50),
										COUNTRY NVARCHAR(50),
										Flag BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
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
									XMLData.LOTNO,
									XMLData.QTY,
									XMLData.VOL,
									XMLData.FWAR,
									XMLData.PARTNO,
									XMLData.SIZE,
									XMLData.EXPORT,
									XMLData.DESCRIPTIONS_EXPORT,
									XMLData.TYPEACTION_EXPORT,
									XMLData.COUNTRY,
									XMLData.Flag,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
										    OldCompanyCode NVARCHAR(50),
											GROUPID NVARCHAR(100),
											LOTNO NVARCHAR(100),
											QTY INT,
											VOL NVARCHAR(30),
											FWAR NVARCHAR(20),
											PARTNO NVARCHAR(50),
											SIZE NVARCHAR(100),
											EXPORT BIT,
											DESCRIPTIONS_EXPORT NVARCHAR(500),
											TYPEACTION_EXPORT NVARCHAR(50),
											COUNTRY NVARCHAR(50),
											Flag BIT,
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											 
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.GROUPID,
									XMLData.LOTNO,
									XMLData.QTY,
									XMLData.VOL,
									XMLData.FWAR,
									XMLData.PARTNO,
									XMLData.SIZE,
									XMLData.EXPORT,
									XMLData.DESCRIPTIONS_EXPORT,
									XMLData.TYPEACTION_EXPORT,
									XMLData.COUNTRY,
									XMLData.Flag,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldCompanyCode NVARCHAR(50),
											GROUPID  NVARCHAR(50),
											LOTNO NVARCHAR(100),
											QTY INT,
											VOL NVARCHAR(30),
											FWAR NVARCHAR(30),
											PARTNO NVARCHAR(50),
											SIZE NVARCHAR(20),
											EXPORT BIT,
											DESCRIPTIONS_EXPORT NVARCHAR(500),
											TYPEACTION_EXPORT NVARCHAR(50),
											COUNTRY NVARCHAR(50),
											Flag BIT,
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											 
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.GROUPID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.GROUPID,
								    XMLData.LOTNO,
									XMLData.QTY,
									XMLData.VOL,
									XMLData.FWAR,
									XMLData.PARTNO,
									XMLData.SIZE,
									XMLData.EXPORT,
									XMLData.DESCRIPTIONS_EXPORT,
									XMLData.TYPEACTION_EXPORT,
									XMLData.COUNTRY,
									XMLData.Flag,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldCompanyCode NVARCHAR(50),
											GROUPID NVARCHAR(50),
											LOTNO NVARCHAR(50),
											QTY INT,
											VOL NVARCHAR(30),
											FWAR NVARCHAR(20),
											PARTNO NVARCHAR(50),
											SIZE NVARCHAR(30),
											EXPORT BIT,
											DESCRIPTIONS_EXPORT NVARCHAR(500), 
											TYPEACTION_EXPORT NVARCHAR(50),
											COUNTRY NVARCHAR(50),
											Flag BIT,
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
								 @GROUPID,
								 @LOTNO,
								 @QTY,
								 @VOL,
								 @FWAR,
								 @PARTNO,
								 @SIZE,
								 @EXPORT,
								 @DESCRIPTIONS_EXPORT,
								 @TYPEACTION_EXPORT,
								 @COUNTRY,
								 @Flag,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_MODULE_EXPORT_IMPORT WHERE GROUPID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_MODULE_EXPORT_IMPORT', @OldCompanyCode OUTPUT	
						INSERT INTO STB_VN_MODULE_EXPORT_IMPORT
						(
						   	GROUPID,
							LOTNO,
							QTY,
							VOL,
							FWAR,
							PARTNO,
							SIZE,
							EXPORT,
							DESCRIPTIONS_EXPORT,
							TYPEACTION_EXPORT,
							COUNTRY,
							Flag,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
						@GROUPID,
						@LOTNO,
						@QTY,
						@VOL,
						@FWAR,
						@PARTNO,
						@SIZE,
						'1',
						@DESCRIPTIONS_EXPORT,
						@TYPEACTION_EXPORT,
						@COUNTRY,
						'1',
						DATEADD(HH, -2, GETDATE()),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

UPDATE STB_VN_MODULE_EXPORT_IMPORT

						SET
							--GROUPID =   CASE
						 --               WHEN  @GROUPID IS NOT NULL THEN  @GROUPID
						 --               ELSE GROUPID
						 --           END,
						--LOTNO =   CASE
						--                WHEN @LOTNO IS NOT NULL THEN @LOTNO
						--                ELSE LOTNO
						--            END,

							 --QTY =   CASE
						  --              WHEN @QTY IS NOT NULL THEN @QTY
						  --              ELSE QTY
						  --          END,

							 --VOL =   CASE
						  --              WHEN @VOL IS NOT NULL THEN @VOL
						  --              ELSE VOL
						  --          END,
							 --FWAR =   CASE
						  --              WHEN @FWAR IS NOT NULL THEN @FWAR
						  --              ELSE FWAR
						  --          END,
						 --PARTNO =   CASE
						 --               WHEN @PARTNO IS NOT NULL THEN @PARTNO
						 --               ELSE PARTNO
						 --           END,

						 --SIZE =   CASE
						 --               WHEN @SIZE IS NOT NULL THEN @SIZE
						 --               ELSE SIZE
						 --           END,

						 EXPORT =   CASE
						                WHEN @EXPORT IS NOT NULL THEN @EXPORT
						                ELSE EXPORT
						            END,

						 DESCRIPTIONS_EXPORT =   CASE
						                WHEN @DESCRIPTIONS_EXPORT IS NOT NULL THEN @DESCRIPTIONS_EXPORT
						                ELSE DESCRIPTIONS_EXPORT
						            END,

									 TYPEACTION_EXPORT =   CASE
						                WHEN @TYPEACTION_EXPORT IS NOT NULL THEN @TYPEACTION_EXPORT
						                ELSE TYPEACTION_EXPORT
						            END,


										 COUNTRY =   CASE
						                WHEN @COUNTRY IS NOT NULL THEN @COUNTRY
						                ELSE COUNTRY
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE
						    GROUPID = @OldCompanyCode

			  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_MODULE_EXPORT_IMPORT
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