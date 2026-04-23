CREATE PROC [dbo].[usp_VN_ItemCheck]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pXml NVARCHAR(MAX) = NULL
AS
BEGIN

		--ID INT IDENTITY(1,1) PRIMARY KEY(ID) NOT NULL,
		--	CODELINE NVARCHAR(20) NULL,
		--	NAMELINE NVARCHAR(50) NULL,
		--	CATEGORIESCHECK NVARCHAR(50) NULL,
		--	QTY INT NULL,
		--	TYPEINPUT NVARCHAR(20) NULL,
		--	INPUT NVARCHAR(50) NULL,
		--	UNIT NVARCHAR(20) NULL,
		--	REMARK NVARCHAR(500) NULL,
		--	CreateDateTime DATETIME NULL,
		--	CreateUserID NVARCHAR(50) NULL,
		--	ChangeDateTime DATETIME NULL,
		--	ChangeUserID NVARCHAR(50) NULL

		-- SELECT * FROM STB_VN_ITEM_CHECK

		--alter table STB_VN_ITEM_CHECK
		--add
			
		--		CODENAME NVARCHAR(50) NULL

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
	DECLARE @CODELINE NVARCHAR(500)
	DECLARE @NAMELINE NVARCHAR(500)
	DECLARE @CATEGORIESCHECK NVARCHAR(500)
	DECLARE @QTY INT
	DECLARE @TYPEINPUT NVARCHAR(500) 
	DECLARE @INPUT NVARCHAR(500)
	DECLARE @REMARK NVARCHAR(500)
	DECLARE @UNIT NVARCHAR(500)
	DECLARE @DEPARTMENT NVARCHAR(500)
	DECLARE @TYPES NVARCHAR(500)
	DECLARE @CODENAME NVARCHAR(500)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(500)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(500)
	DECLARE @iDoc INT

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_ITEM_CHECK',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		   BEGIN TRY
	 MERGE STB_VN_ITEM_CHECK AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODELINE,
							XMLData.NAMELINE,
							XMLData.CATEGORIESCHECK,
							XMLData.QTY,
							XMLData.TYPEINPUT,
							XMLData.INPUT,
							XMLData.UNIT,
							XMLData.REMARK,
							XMLData.DEPARTMENT,
							XMLData.TYPES, 
							XMLData.CODENAME, 
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODELINE NVARCHAR(500),
										NAMELINE NVARCHAR(500),
										CATEGORIESCHECK NVARCHAR(500),
										QTY INT,
										TYPEINPUT NVARCHAR(500),
										INPUT NVARCHAR(500),
										UNIT NVARCHAR(500),
										REMARK NVARCHAR(500),
										DEPARTMENT NVARCHAR(500),
										TYPES NVARCHAR(500), 
										CODENAME NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(500),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(500)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)

WHEN MATCHED THEN
				UPDATE SET
					CODELINE = SourceTable.CODELINE,
					NAMELINE = SourceTable.NAMELINE,
					CATEGORIESCHECK = SourceTable.CATEGORIESCHECK,
					QTY = SourceTable.QTY,
					TYPEINPUT = SourceTable.TYPEINPUT,
					INPUT = SourceTable.INPUT,
					UNIT = SourceTable.UNIT,
					REMARK = SourceTable.REMARK,
					DEPARTMENT = SourceTable.DEPARTMENT,
					TYPES= SourceTable.TYPES,
					CODENAME= SourceTable.CODENAME,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID


					WHEN NOT MATCHED THEN

				INSERT
					(
						CODELINE,
						NAMELINE,
						CATEGORIESCHECK,
						QTY,
						TYPEINPUT,
						INPUT,
						UNIT,
						REMARK,
						DEPARTMENT,
						TYPES,
						CODENAME,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CODELINE,
							SourceTable.NAMELINE,
							SourceTable.CATEGORIESCHECK,
							SourceTable.QTY,
							SourceTable.TYPEINPUT,
							SourceTable.INPUT,
							SourceTable.UNIT,
							SourceTable.REMARK,
							SourceTable.DEPARTMENT,
							SourceTable.TYPES,
							SourceTable.CODENAME,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);		
		
		
		MERGE STB_VN_ITEM_CHECK AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODELINE,
							XMLData.NAMELINE,
							XMLData.CATEGORIESCHECK,
							XMLData.QTY,
							XMLData.TYPEINPUT,
							XMLData.INPUT,
							XMLData.UNIT,
							XMLData.REMARK,
							XMLData.DEPARTMENT,
							XMLData.TYPES,
							XMLData.CODENAME,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODELINE NVARCHAR(500),
										NAMELINE NVARCHAR(500),
										CATEGORIESCHECK NVARCHAR(500),
										QTY INT,
										TYPEINPUT NVARCHAR(500),
										INPUT NVARCHAR(500),
										UNIT NVARCHAR(500),
										REMARK NVARCHAR(500),
										DEPARTMENT NVARCHAR(500),
										TYPES NVARCHAR(500), 
										CODENAME NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(500),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(500)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)	

WHEN MATCHED THEN
				UPDATE SET
					CODELINE = SourceTable.CODELINE,
					NAMELINE = SourceTable.NAMELINE,
					CATEGORIESCHECK = SourceTable.CATEGORIESCHECK,
					QTY = SourceTable.QTY,
					TYPEINPUT = SourceTable.TYPEINPUT,
					INPUT = SourceTable.INPUT,
					UNIT = SourceTable.UNIT,
					REMARK = SourceTable.REMARK,
					DEPARTMENT = SourceTable.DEPARTMENT,
					TYPES = SourceTable.TYPES,
					CODENAME = SourceTable.CODENAME,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

			INSERT
					(
						CODELINE,
						NAMELINE,
						CATEGORIESCHECK,
						QTY,
						TYPEINPUT,
						INPUT,
						UNIT,
						REMARK,
						DEPARTMENT,
						TYPES,
						CODENAME,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CODELINE,
							SourceTable.NAMELINE,
							SourceTable.CATEGORIESCHECK,
							SourceTable.QTY,
							SourceTable.TYPEINPUT,
							SourceTable.INPUT,
							SourceTable.UNIT,
							SourceTable.REMARK,
							SourceTable.DEPARTMENT,
							SourceTable.TYPES,
							SourceTable.CODENAME,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

					-- Process Delete Table
            MERGE STB_VN_ITEM_CHECK AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODELINE,
							XMLData.NAMELINE,
							XMLData.CATEGORIESCHECK,
							XMLData.QTY,
							XMLData.TYPEINPUT,
							XMLData.INPUT,
							XMLData.UNIT,
							XMLData.REMARK,
							XMLData.DEPARTMENT,
							XMLData.TYPES,
							XMLData.CODENAME,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODELINE NVARCHAR(500),
										NAMELINE NVARCHAR(500),
										CATEGORIESCHECK NVARCHAR(500),
										QTY INT,
										TYPEINPUT NVARCHAR(500),
										INPUT NVARCHAR(500),
										UNIT NVARCHAR(500),
										REMARK NVARCHAR(500),
										DEPARTMENT NVARCHAR(500),
										TYPES NVARCHAR(500), 
										CODENAME NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(500),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(500)
										
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
									XMLData.CODELINE,
									XMLData.NAMELINE,
									XMLData.CATEGORIESCHECK,
									XMLData.QTY,
									XMLData.TYPEINPUT,
									XMLData.INPUT,
									XMLData.UNIT,
									XMLData.REMARK,
									XMLData.DEPARTMENT,
									XMLData.TYPES,
									XMLData.CODENAME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldCompanyCode INT,
										ID INT,
										CODELINE NVARCHAR(500),
										NAMELINE NVARCHAR(500),
										CATEGORIESCHECK NVARCHAR(500),
										QTY INT,
										TYPEINPUT NVARCHAR(500),
										INPUT NVARCHAR(500),
										UNIT NVARCHAR(500),
										REMARK NVARCHAR(500),
										DEPARTMENT NVARCHAR(500),
										TYPES NVARCHAR(500), 
										CODENAME NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(500),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(500)
											) XMLData
									UNION ALL


									SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.CODELINE,
									XMLData.NAMELINE,
									XMLData.CATEGORIESCHECK,
									XMLData.QTY,
									XMLData.TYPEINPUT,
									XMLData.INPUT,
									XMLData.UNIT,
									XMLData.REMARK,
									XMLData.DEPARTMENT,
									XMLData.TYPES,
									XMLData.CODENAME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
										ID INT,
										CODELINE NVARCHAR(500),
										NAMELINE NVARCHAR(500),
										CATEGORIESCHECK NVARCHAR(500),
										QTY INT,
										TYPEINPUT NVARCHAR(500),
										INPUT NVARCHAR(500),
										UNIT NVARCHAR(500),
										REMARK NVARCHAR(500),
										DEPARTMENT NVARCHAR(500),
										TYPES NVARCHAR(500), 
										CODENAME NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(500),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(500)
											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.CODELINE,
									XMLData.NAMELINE,
									XMLData.CATEGORIESCHECK,
									XMLData.QTY,
									XMLData.TYPEINPUT,
									XMLData.INPUT,
									XMLData.UNIT,
									XMLData.REMARK,
									XMLData.DEPARTMENT,
									XMLData.TYPES,
									XMLData.CODENAME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
										ID INT,
										CODELINE NVARCHAR(500),
										NAMELINE NVARCHAR(500),
										CATEGORIESCHECK NVARCHAR(500),
										QTY INT,
										TYPEINPUT NVARCHAR(500),
										INPUT NVARCHAR(500),
										UNIT NVARCHAR(500),
										REMARK NVARCHAR(500),
										DEPARTMENT NVARCHAR(500),
										TYPES NVARCHAR(500), 
										CODENAME NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(500),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(500)
											) XMLData

								 OPEN SourceData

					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @CODELINE,
								 @NAMELINE,
								 @CATEGORIESCHECK,
								 @QTY,
								 @TYPEINPUT,
								 @INPUT,
								 @UNIT,
								 @REMARK,
								 @DEPARTMENT,
								 @TYPES,
								 @CODENAME,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_ITEM_CHECK WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_ITEM_CHECK', @OldCompanyCode OUTPUT


						INSERT INTO STB_VN_ITEM_CHECK
						(
						    CODELINE,
						    NAMELINE,
						    CATEGORIESCHECK,
						    QTY,
						    TYPEINPUT,
						    INPUT,
							UNIT,
							REMARK,
							DEPARTMENT,
							TYPES,
							CODENAME,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    
						    @CODELINE,
						    @NAMELINE,
						    @CATEGORIESCHECK,
						    @QTY,
						    @TYPEINPUT,
							@INPUT,
							@UNIT,
							@REMARK,
							@DEPARTMENT,
							@TYPES,
							@CODENAME,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)


						END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_ITEM_CHECK
						SET
							CODELINE =   CASE
						                WHEN @CODELINE IS NOT NULL THEN @CODELINE
						                ELSE CODELINE
						            END,
						NAMELINE =   CASE
						                WHEN @NAMELINE IS NOT NULL THEN @NAMELINE
						                ELSE NAMELINE
						            END,

							 CATEGORIESCHECK =   CASE
						                WHEN @CATEGORIESCHECK IS NOT NULL THEN @CATEGORIESCHECK
						                ELSE CATEGORIESCHECK
						            END,

							 QTY =   CASE
						                WHEN @QTY IS NOT NULL THEN @QTY
						                ELSE QTY
						            END,
							 TYPEINPUT =   CASE
						                WHEN @TYPEINPUT IS NOT NULL THEN @TYPEINPUT
						                ELSE TYPEINPUT
						            END,
						 INPUT =   CASE
						                WHEN @INPUT IS NOT NULL THEN @INPUT
						                ELSE INPUT
						            END,
						 UNIT =   CASE
						                WHEN @UNIT IS NULL THEN @UNIT
						                ELSE UNIT
						            END,
						 REMARK =   CASE
						                WHEN @REMARK IS NOT NULL THEN @REMARK
						                ELSE REMARK
						            END,

						DEPARTMENT =   CASE
						                WHEN @DEPARTMENT IS NOT NULL THEN @DEPARTMENT
						                ELSE DEPARTMENT
						            END,

									
						TYPES =   CASE
						                WHEN @TYPES IS NOT NULL THEN @TYPES
						                ELSE TYPES
						            END,

						CODENAME =   CASE
						                WHEN @CODENAME IS NOT NULL THEN @CODENAME
						                ELSE CODENAME
						            END,
					
					
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_ITEM_CHECK
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

