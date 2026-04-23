CREATE PROC [dbo].[usp_VN_ModuleConfirm]
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
	DECLARE @QTY INT
	DECLARE @DIVIDETHENUMBER INT
	DECLARE @TOTALQTY INT
	DECLARE @VOL NVARCHAR(50)
	DECLARE @FWAR NVARCHAR(50)
	DECLARE @PARTNO NVARCHAR(50)
	DECLARE @SIZE NVARCHAR(50)
	DECLARE @ISUSED BIT
	DECLARE @EXPORT BIT
	DECLARE @TYPEEXPORT NVARCHAR(10)
	DECLARE @DESCRIPTIONSEXPORT NVARCHAR(500)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
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
	 MERGE STB_VN_MASTERMODULES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.QTY,
							XMLData.DIVIDETHENUMBER,
							XMLData.TOTALQTY,
							XMLData.VOL,
							XMLData.FWAR,
							XMLData.PARTNO,
							XMLData.SIZE,
							XMLData.ISUSED,
							XMLData.EXPORT,
							XMLData.TYPEEXPORT,
							XMLData.DESCRIPTIONSEXPORT,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										QTY INT,
										DIVIDETHENUMBER INT,
										TOTALQTY INT,
										VOL NVARCHAR(20),
										FWAR NVARCHAR(20),
										PARTNO  NVARCHAR(50),
										SIZE NVARCHAR(20),
										ISUSED BIT,
										EXPORT BIT,
										TYPEEXPORT NVARCHAR(10),
										DESCRIPTIONSEXPORT NVARCHAR(500),
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
					
					QTY = SourceTable.QTY,
					DIVIDETHENUMBER = SourceTable.DIVIDETHENUMBER,
					TOTALQTY =  SourceTable.QTY / SourceTable.DIVIDETHENUMBER,
					VOL = SourceTable.VOL,
					FWAR = SourceTable.FWAR,
					PARTNO = SourceTable.PARTNO,
					SIZE = SourceTable.SIZE,
					ISUSED = SourceTable.ISUSED,
					EXPORT = '1',
					TYPEEXPORT = N'Xuất',
					DESCRIPTIONSEXPORT =SourceTable.DESCRIPTIONSEXPORT,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

					WHEN NOT MATCHED THEN
			INSERT
					(
						QTY,
						DIVIDETHENUMBER,
						TOTALQTY,
						VOL,
						FWAR,
						PARTNO,
						SIZE,
						ISUSED,
						EXPORT,
						TYPEEXPORT,
						DESCRIPTIONSEXPORT,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QTY,
							SourceTable.DIVIDETHENUMBER,
							SourceTable.TOTALQTY,
							SourceTable.VOL,
							SourceTable.FWAR,
							SourceTable.PARTNO,
							SourceTable.SIZE,
							SourceTable.ISUSED,
							'1',
							N'Xuất',
							SourceTable.DESCRIPTIONSEXPORT,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);		
					
MERGE STB_VN_MASTERMODULES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.QTY,
							XMLData.DIVIDETHENUMBER,
							XMLData.TOTALQTY,
							XMLData.VOL,
							XMLData.FWAR,
							XMLData.PARTNO,
							XMLData.SIZE,
							XMLData.ISUSED,
							XMLData.EXPORT,
							XMLData.TYPEEXPORT,
							XMLData.DESCRIPTIONSEXPORT,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										QTY INT,
										DIVIDETHENUMBER INT,
										TOTALQTY INT,
										VOL NVARCHAR(20),
										FWAR NVARCHAR(20),
										PARTNO NVARCHAR(50),
										SIZE NVARCHAR(20),
										ISUSED BIT,
										EXPORT BIT,
										TYPEEXPORT NVARCHAR(10),
										DESCRIPTIONSEXPORT NVARCHAR(500),
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
					
					QTY = SourceTable.QTY,
					DIVIDETHENUMBER = SourceTable.DIVIDETHENUMBER,
					TOTALQTY = SourceTable.QTY / SourceTable.DIVIDETHENUMBER,
					VOL = SourceTable.VOL,
					FWAR = SourceTable.FWAR,
					PARTNO = SourceTable.PARTNO,
					SIZE = SourceTable.SIZE,
					ISUSED = SourceTable.ISUSED,
					EXPORT = '1',
					TYPEEXPORT = N'Nhập',
					DESCRIPTIONSEXPORT = SourceTable.DESCRIPTIONSEXPORT,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN

			INSERT
					(
						QTY,
						DIVIDETHENUMBER,
						TOTALQTY,
						VOL,
						FWAR,
						PARTNO,
						SIZE,
						ISUSED,
						EXPORT,
						TYPEEXPORT,
						DESCRIPTIONSEXPORT,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QTY,
							SourceTable.DIVIDETHENUMBER,
							SourceTable.TOTALQTY,
							SourceTable.VOL,
							SourceTable.FWAR,
							SourceTable.PARTNO,
							SourceTable.SIZE,
							SourceTable.ISUSED,
							'1',
							N'Xuất',
							SourceTable.DESCRIPTIONSEXPORT,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

-- Process Delete Table
            MERGE STB_VN_MASTERMODULES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.QTY,
							XMLData.DIVIDETHENUMBER,
							XMLData.TOTALQTY,
							XMLData.VOL,
							XMLData.FWAR,
							XMLData.PARTNO,
							XMLData.SIZE,
							XMLData.ISUSED,
							XMLData.EXPORT,
							XMLData.TYPEEXPORT,
							XMLData.DESCRIPTIONSEXPORT,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										QTY INT,
										DIVIDETHENUMBER INT,
										TOTALQTY INT,
										VOL NVARCHAR(20),
										FWAR NVARCHAR(20),
										PARTNO NVARCHAR(50),
										SIZE NVARCHAR(20),
										ISUSED BIT,
										EXPORT BIT,
										TYPEEXPORT NVARCHAR(10),
										DESCRIPTIONSEXPORT NVARCHAR(500),
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
									XMLData.QTY,
									XMLData.DIVIDETHENUMBER,
									XMLData.TOTALQTY,
									XMLData.VOL,
									XMLData.FWAR,
									XMLData.PARTNO,
									XMLData.SIZE,
									XMLData.ISUSED,
									XMLData.EXPORT,
									XMLData.TYPEEXPORT,
									XMLData.DESCRIPTIONSEXPORT,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 QTY INT,
											 DIVIDETHENUMBER INT,
											 TOTALQTY INT,
											 VOL NVARCHAR(20),
											 FWAR NVARCHAR(20),
											 PARTNO NVARCHAR(50),
											 SIZE  NVARCHAR(20),
											 ISUSED BIT,
											 EXPORT BIT,
											 TYPEEXPORT NVARCHAR(10),
											 DESCRIPTIONSEXPORT NVARCHAR(500),
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
									XMLData.QTY,
									XMLData.DIVIDETHENUMBER,
									XMLData.TOTALQTY,
									XMLData.VOL,
									XMLData.FWAR,
									XMLData.PARTNO,
									XMLData.SIZE,
									XMLData.ISUSED,
									XMLData.EXPORT,
									XMLData.TYPEEXPORT,
									XMLData.DESCRIPTIONSEXPORT,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 QTY INT,
											 DIVIDETHENUMBER INT,
											 TOTALQTY INT,
											 VOL NVARCHAR(20),
											 FWAR NVARCHAR(20),
											 PARTNO NVARCHAR(50),
											 SIZE NVARCHAR(20),
											 ISUSED BIT,
											 EXPORT BIT,
											 TYPEEXPORT NVARCHAR(10),
											 DESCRIPTIONSEXPORT NVARCHAR(500),
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
									XMLData.QTY,
									XMLData.DIVIDETHENUMBER,
									XMLData.TOTALQTY,
									XMLData.VOL,
									XMLData.FWAR,
									XMLData.PARTNO,
									XMLData.SIZE,
									XMLData.ISUSED,
									XMLData.EXPORT,
									XMLData.TYPEEXPORT,
									XMLData.DESCRIPTIONSEXPORT,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 QTY INT,
											 DIVIDETHENUMBER INT,
											 TOTALQTY INT,
											 VOL NVARCHAR(20),
											 FWAR NVARCHAR(20),
											 PARTNO NVARCHAR(50),
											 SIZE NVARCHAR(20),
											 ISUSED BIT,
											 EXPORT BIT,
											 TYPEEXPORT NVARCHAR(10),
											 DESCRIPTIONSEXPORT NVARCHAR(500),
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
								 @QTY,
								 @DIVIDETHENUMBER,
								 @TOTALQTY,
								 @VOL,
								 @FWAR,
								 @PARTNO,
								 @SIZE,
								 @ISUSED,
								 @EXPORT,
								 @TYPEEXPORT,
								 @DESCRIPTIONSEXPORT,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_MASTERMODULES WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_MASTERMODULES', @OldCompanyCode OUTPUT
	
	INSERT INTO STB_VN_MASTERMODULES
						(
						    QTY,
						    DIVIDETHENUMBER,
						    TOTALQTY,
						    VOL,
						    FWAR,
						    PARTNO,
							SIZE,
							ISUSED,
							EXPORT,
							TYPEEXPORT,
							DESCRIPTIONSEXPORT,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @QTY,
						    @DIVIDETHENUMBER,
						    @TOTALQTY,
						    @VOL,
						    @FWAR,
						    @PARTNO,
							@SIZE,
							@ISUSED,
							'1',
							N'Xuất',
							@DESCRIPTIONSEXPORT,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_VN_MASTERMODULES

						SET
							QTY =   CASE
						                WHEN @QTY IS NOT NULL THEN @QTY
						                ELSE QTY
						            END,
						DIVIDETHENUMBER =   CASE
						                WHEN @DIVIDETHENUMBER IS NOT NULL THEN @DIVIDETHENUMBER
						                ELSE DIVIDETHENUMBER
						            END,

							 TOTALQTY =   CASE
						                WHEN @TOTALQTY IS NOT NULL THEN (@QTY / @DIVIDETHENUMBER)
						                ELSE TOTALQTY
						            END,

							 VOL =   CASE
						                WHEN @VOL IS NOT NULL THEN @VOL
						                ELSE VOL
						            END,
							 FWAR =   CASE
						                WHEN @FWAR IS NOT NULL THEN @FWAR
						                ELSE FWAR
						            END,
						 PARTNO =   CASE
						                WHEN @PARTNO IS NOT NULL THEN @PARTNO
						                ELSE PARTNO
						            END,
						 SIZE =   CASE
						                WHEN @SIZE IS NULL THEN @SIZE
						                ELSE SIZE
						            END,
						 ISUSED =   CASE
						                WHEN @ISUSED IS NOT NULL THEN @ISUSED
						                ELSE ISUSED
						            END,

					EXPORT	=   CASE
						                WHEN @EXPORT IS NOT NULL THEN @EXPORT
						                ELSE EXPORT
						            END,
						
					TYPEEXPORT	=   CASE
						                WHEN @TYPEEXPORT IS NOT NULL THEN @TYPEEXPORT
						                ELSE TYPEEXPORT
						            END,

										DESCRIPTIONSEXPORT	=   CASE
						                WHEN @DESCRIPTIONSEXPORT IS NOT NULL THEN @DESCRIPTIONSEXPORT
						                ELSE DESCRIPTIONSEXPORT
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_MASTERMODULES
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
