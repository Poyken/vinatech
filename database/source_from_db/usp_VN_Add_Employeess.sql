CREATE PROC usp_VN_Add_Employeess
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
	DECLARE @EMPID NVARCHAR(100)
	DECLARE @FULLNAME NVARCHAR(100)
	DECLARE @BIRTHDAY NVARCHAR(100)
	DECLARE @GENDER NVARCHAR(100)
	DECLARE @STARTWORK NVARCHAR(100)
	DECLARE @DEPARTMENT NVARCHAR(100)
	DECLARE @PART NVARCHAR(50)
	DECLARE @POSITION  NVARCHAR(50)
	DECLARE @ISUED BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT
	
	
	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_EMPLOYEES',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

			BEGIN TRY
			-- Process Insert Table
			 MERGE STB_EMPLOYEES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.EMPID,
							XMLData.FULLNAME,
							XMLData.BIRTHDAY,
							XMLData.GENDER,
							XMLData.STARTWORK,
							XMLData.DEPARTMENT,
							XMLData.PART,
							XMLData.POSITION,
							XMLData.ISUED,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										EMPID NVARCHAR(100),
										FULLNAME NVARCHAR(100),
										BIRTHDAY NVARCHAR(100),
										GENDER NVARCHAR(100),
										STARTWORK NVARCHAR(100),
										DEPARTMENT NVARCHAR(100),
										PART NVARCHAR(50),
										POSITION  NVARCHAR(50),
										ISUED BIT,
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

					EMPID = SourceTable.EMPID,
					FULLNAME = SourceTable.FULLNAME,
					BIRTHDAY = SourceTable.BIRTHDAY,
					GENDER = SourceTable.GENDER,
					STARTWORK = SourceTable.STARTWORK,
					DEPARTMENT = SourceTable.DEPARTMENT,
					PART = SourceTable.PART,
					POSITION = SourceTable.POSITION,
					ISUED = SourceTable.ISUED,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

					WHEN NOT MATCHED THEN

				INSERT
					(
					EMPID,
					FULLNAME,
					BIRTHDAY,
					GENDER,
					STARTWORK,
					DEPARTMENT,
					PART,
					POSITION,
					ISUED,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							
							SourceTable.EMPID,
							SourceTable.FULLNAME,
							SourceTable.BIRTHDAY,
							SourceTable.GENDER,
							SourceTable.STARTWORK,
							SourceTable.DEPARTMENT,
							SourceTable.PART,
							SourceTable.POSITION,
							SourceTable.ISUED,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
		
			-- Process Update Table
	 MERGE STB_EMPLOYEES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.EMPID,
							XMLData.FULLNAME,
							XMLData.BIRTHDAY,
							XMLData.GENDER,
							XMLData.STARTWORK,
							XMLData.DEPARTMENT,
							XMLData.PART,
							XMLData.POSITION,
							XMLData.ISUED,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										EMPID NVARCHAR(100),
										FULLNAME NVARCHAR(100),
										BIRTHDAY NVARCHAR(100),
										GENDER NVARCHAR(100),
										STARTWORK NVARCHAR(100),
										DEPARTMENT NVARCHAR(100),
										PART NVARCHAR(50),
										POSITION  NVARCHAR(50),
										ISUED BIT,
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

					EMPID = SourceTable.EMPID,
					FULLNAME = SourceTable.FULLNAME,
					BIRTHDAY = SourceTable.BIRTHDAY,
					GENDER = SourceTable.GENDER,
					STARTWORK = SourceTable.STARTWORK,
					DEPARTMENT = SourceTable.DEPARTMENT,
					PART = SourceTable.PART,
					POSITION = SourceTable.POSITION,
					ISUED = SourceTable.ISUED,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

				WHEN NOT MATCHED THEN

				INSERT
					(
						EMPID,
					FULLNAME,
					BIRTHDAY,
					GENDER,
					STARTWORK,
					DEPARTMENT,
					PART,
					POSITION,
					ISUED,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							SourceTable.EMPID,
							SourceTable.FULLNAME,
							SourceTable.BIRTHDAY,
							SourceTable.GENDER,
							SourceTable.STARTWORK,
							SourceTable.DEPARTMENT,
							SourceTable.PART,
							SourceTable.POSITION,
							SourceTable.ISUED,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID	
					);

					-- Process Delete Table
            MERGE STB_EMPLOYEES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.EMPID,
							XMLData.FULLNAME,
							XMLData.BIRTHDAY,
							XMLData.GENDER,
							XMLData.STARTWORK,
							XMLData.DEPARTMENT,
							XMLData.PART,
							XMLData.POSITION,
							XMLData.ISUED,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										EMPID NVARCHAR(100),
										FULLNAME NVARCHAR(100),
										BIRTHDAY NVARCHAR(100),
										GENDER NVARCHAR(100),
										STARTWORK NVARCHAR(100),
										DEPARTMENT NVARCHAR(100),
										PART NVARCHAR(50),
										POSITION  NVARCHAR(50),
										ISUED BIT,
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
								   	XMLData.EMPID,
								    XMLData.FULLNAME,
									XMLData.BIRTHDAY,
									XMLData.GENDER,
									XMLData.STARTWORK,
									XMLData.DEPARTMENT,
									XMLData.PART,
									XMLData.POSITION,
									XMLData.ISUED,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											EMPID NVARCHAR(100),
											FULLNAME NVARCHAR(100),
											BIRTHDAY NVARCHAR(100),
											GENDER NVARCHAR(100),
											STARTWORK NVARCHAR(100),
											DEPARTMENT NVARCHAR(100),
											PART NVARCHAR(50),
											POSITION  NVARCHAR(50),
											ISUED NVARCHAR(50),
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
									XMLData.EMPID,
									XMLData.FULLNAME,
									XMLData.BIRTHDAY,
									XMLData.GENDER,
									XMLData.STARTWORK,
									XMLData.DEPARTMENT,
									XMLData.PART,
									XMLData.POSITION,
									XMLData.ISUED,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											EMPID NVARCHAR(100),
											FULLNAME NVARCHAR(100),
											BIRTHDAY NVARCHAR(100),
											GENDER NVARCHAR(100),
											STARTWORK NVARCHAR(100),
											DEPARTMENT NVARCHAR(100),
											PART NVARCHAR(50),
											POSITION  NVARCHAR(50),
											ISUED NVARCHAR(50),
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
									XMLData.EMPID,
									XMLData.FULLNAME,
									XMLData.BIRTHDAY,
									XMLData.GENDER,
									XMLData.STARTWORK,
									XMLData.DEPARTMENT,
									XMLData.PART,
									XMLData.POSITION,
									XMLData.ISUED,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											EMPID NVARCHAR(100),
											FULLNAME NVARCHAR(100),
											BIRTHDAY NVARCHAR(100),
											GENDER NVARCHAR(100),
											STARTWORK NVARCHAR(100),
											DEPARTMENT NVARCHAR(100),
											PART NVARCHAR(50),
											POSITION  NVARCHAR(50),
											ISUED NVARCHAR(50),
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
								 @EMPID,
								 @FULLNAME,
								 @BIRTHDAY,
								 @GENDER,
								 @STARTWORK,
								 @DEPARTMENT,
								 @PART,
								 @POSITION,
								 @ISUED,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_EMPLOYEES WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_EMPLOYEES', @OldCompanyCode OUTPUT	
						
						
		INSERT INTO STB_EMPLOYEES
						(
						   	EMPID,
							FULLNAME,
							BIRTHDAY,
							GENDER,
							STARTWORK,
							DEPARTMENT,
							PART,
							POSITION,
							ISUED,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
						@EMPID,
						@FULLNAME,
						@BIRTHDAY,
						@GENDER,
						@STARTWORK,
						@DEPARTMENT,
						@PART,
						@POSITION,
						@ISUED,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
							
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_EMPLOYEES

						SET
							EMPID =   CASE
						                WHEN @EMPID IS NOT NULL THEN @EMPID
						                ELSE EMPID
						            END,
						FULLNAME =   CASE
						                WHEN @FULLNAME IS NOT NULL THEN @FULLNAME
						                ELSE FULLNAME
						            END,

							 BIRTHDAY =   CASE
						                WHEN @BIRTHDAY IS NOT NULL THEN @BIRTHDAY
						                ELSE BIRTHDAY
						            END,

							 GENDER =   CASE
						                WHEN @GENDER IS NOT NULL THEN @GENDER
						                ELSE GENDER
						            END,
							 STARTWORK =   CASE
						                WHEN @STARTWORK IS NOT NULL THEN @STARTWORK
						                ELSE STARTWORK
						            END,
						 DEPARTMENT =   CASE
						                WHEN @DEPARTMENT IS NOT NULL THEN @DEPARTMENT
						                ELSE DEPARTMENT
						            END,

						 PART =   CASE
						                WHEN @PART IS NOT NULL THEN @PART
						                ELSE PART
						            END,

						 POSITION =   CASE
						                WHEN @POSITION IS NOT NULL THEN @POSITION
						                ELSE POSITION
						            END,

						 ISUED =   CASE
						                WHEN @ISUED IS NOT NULL THEN @ISUED
						                ELSE ISUED
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE
						    ID = @OldCompanyCode

			  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_EMPLOYEES
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