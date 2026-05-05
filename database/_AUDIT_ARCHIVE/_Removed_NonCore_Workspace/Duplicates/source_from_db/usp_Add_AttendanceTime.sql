CREATE PROC usp_Add_AttendanceTime
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
	 DECLARE @EMPLOYEES_ID NVARCHAR(50)
	 DECLARE @EMPLOYEES_NAME NVARCHAR(100)
	 DECLARE @CODE_LINE NVARCHAR(50)
	 DECLARE @NAME_LINE NVARCHAR(50)
	 DECLARE @WORK_DATE DATETIME
	 DECLARE @START_TIME DATETIME
	 DECLARE @END_TIME DATETIME
	 DECLARE @TOTAL_TIME INT
	 DECLARE @CREATEDATETIME DATETIME
	 DECLARE @CREATEUSSERID NVARCHAR(50)
	 DECLARE @CHANGEDATETIME DATETIME
	 DECLARE @CHANGEUSERID NVARCHAR(50)
	 DECLARE @iDoc INT

	 	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_ATTENDANCE_TIME',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		 BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_ATTENDANCE_TIME AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.EMPLOYEES_ID,
							XMLData.EMPLOYEES_NAME,
							XMLData.CODE_LINE,
							XMLData.NAME_LINE,
							XMLData.WORK_DATE,
							XMLData.START_TIME,
							XMLData.END_TIME,
							XMLData.TOTAL_TIME,
							 DATEADD(HH, -2, GETDATE()) AS CREATEDATETIME,
							@pProcessUserID AS CREATEUSSERID,
							 DATEADD(HH, -2, GETDATE()) AS CHANGEDATETIME,
							@pProcessUserID AS CHANGEUSERID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										EMPLOYEES_ID NVARCHAR(50),
										EMPLOYEES_NAME NVARCHAR(100),
										CODE_LINE NVARCHAR(50),
										NAME_LINE NVARCHAR(50),
										WORK_DATE DATETIME,
										START_TIME NVARCHAR(50),
										END_TIME NVARCHAR(50),
										TOTAL_TIME INT,
										CREATEDATETIME  DATETIMEOFFSET,
										CREATEUSSERID NVARCHAR(50),
										CHANGEDATETIME  DATETIMEOFFSET,
										CHANGEUSERID NVARCHAR(50)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)
WHEN MATCHED THEN
				UPDATE SET
					EMPLOYEES_ID = SourceTable.EMPLOYEES_ID,
					EMPLOYEES_NAME = SourceTable.EMPLOYEES_NAME,
					CODE_LINE = SourceTable.CODE_LINE,
					WORK_DATE = SourceTable.WORK_DATE,
					START_TIME = SourceTable.START_TIME,
					END_TIME = SourceTable.END_TIME,
					TOTAL_TIME = SourceTable.TOTAL_TIME,
					CHANGEDATETIME = SourceTable.CHANGEDATETIME,
					CHANGEUSERID = SourceTable.CHANGEUSERID
		WHEN NOT MATCHED THEN
				INSERT
					(
						EMPLOYEES_ID,
						EMPLOYEES_NAME,
						CODE_LINE,
						NAME_LINE,
						WORK_DATE,
						START_TIME,
						END_TIME,
						TOTAL_TIME,
						CREATEDATETIME,
						CREATEUSSERID
						
					)
				VALUES
					(
							SourceTable.EMPLOYEES_ID,
							SourceTable.EMPLOYEES_NAME,
							SourceTable.CODE_LINE,
							SourceTable.NAME_LINE,
							SourceTable.WORK_DATE,
							SourceTable.START_TIME,
							SourceTable.END_TIME,
							SourceTable.TOTAL_TIME,
							SourceTable.CREATEDATETIME,
							SourceTable.CREATEUSSERID
					);

-- Process Update Table
	 MERGE STB_VN_ATTENDANCE_TIME AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.EMPLOYEES_ID,
							XMLData.EMPLOYEES_NAME,
							XMLData.CODE_LINE,
							XMLData.NAME_LINE,
							XMLData.WORK_DATE,
							XMLData.START_TIME,
							XMLData.END_TIME,
							XMLData.TOTAL_TIME,
							 DATEADD(HH, -2, GETDATE()) AS CREATEDATETIME,
							@pProcessUserID AS CREATEUSSERID,
							 DATEADD(HH, -2, GETDATE()) AS CHANGEDATETIME,
							@pProcessUserID AS CHANGEUSERID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										EMPLOYEES_ID NVARCHAR(50),
										EMPLOYEES_NAME NVARCHAR(100),
										CODE_LINE NVARCHAR(50),
										NAME_LINE NVARCHAR(50),
										WORK_DATE DATETIME,
										START_TIME NVARCHAR(50),
										END_TIME NVARCHAR(50),
										TOTAL_TIME INT,
										CREATEDATETIME  DATETIMEOFFSET,
										CREATEUSSERID  NVARCHAR(50),
										CHANGEDATETIME  DATETIMEOFFSET,
										CHANGEUSERID  NVARCHAR(50)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)

		WHEN MATCHED THEN

				UPDATE SET

					EMPLOYEES_ID = SourceTable.EMPLOYEES_ID,
					EMPLOYEES_NAME = SourceTable.EMPLOYEES_NAME,
					CODE_LINE = SourceTable.CODE_LINE,
					NAME_LINE = SourceTable.NAME_LINE,
					WORK_DATE = SourceTable.WORK_DATE,
					START_TIME = SourceTable.START_TIME,
					END_TIME = SourceTable.END_TIME,
					TOTAL_TIME = SourceTable.TOTAL_TIME,
					CHANGEDATETIME = SourceTable.CHANGEDATETIME,
					CHANGEUSERID = SourceTable.CHANGEUSERID
				
			WHEN NOT MATCHED THEN
		INSERT
					(
						EMPLOYEES_ID,
						EMPLOYEES_NAME,
						CODE_LINE,
						NAME_LINE,
						WORK_DATE,
						START_TIME,
						END_TIME,
						TOTAL_TIME,
						CREATEDATETIME,
						CREATEUSSERID
						
					)
				VALUES
					(
							SourceTable.EMPLOYEES_ID,
							SourceTable.EMPLOYEES_NAME,
							SourceTable.CODE_LINE,
							SourceTable.NAME_LINE,
							SourceTable.WORK_DATE,
							SourceTable.START_TIME,
							SourceTable.END_TIME,
							SourceTable.TOTAL_TIME,
							SourceTable.CREATEDATETIME,
							SourceTable.CREATEUSSERID
							
					);

					
			-- Process Delete Table
            MERGE STB_VN_ATTENDANCE_TIME AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.EMPLOYEES_ID,
							XMLData.EMPLOYEES_NAME,
							XMLData.CODE_LINE,
							XMLData.NAME_LINE,
							XMLData.WORK_DATE,
							XMLData.START_TIME,
							XMLData.END_TIME,
							XMLData.TOTAL_TIME,
							 DATEADD(HH, -2, GETDATE()) AS CREATEDATETIME,
							@pProcessUserID AS CREATEUSSERID,
							 DATEADD(HH, -2, GETDATE()) AS CHANGEDATETIME,
							@pProcessUserID AS CHANGEUSERID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										EMPLOYEES_ID NVARCHAR(50),
										EMPLOYEES_NAME NVARCHAR(100),
										CODE_LINE NVARCHAR(50),
										NAME_LINE NVARCHAR(50),
										WORK_DATE DATETIME,
										START_TIME NVARCHAR(50),
										END_TIME NVARCHAR(50) ,
										TOTAL_TIME INT,
										CREATEDATETIME  DATETIMEOFFSET,
										CREATEUSSERID NVARCHAR(50),
										CHANGEDATETIME  DATETIMEOFFSET,
										CHANGEUSERID NVARCHAR(50)
										
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
									XMLData.EMPLOYEES_ID,
									XMLData.EMPLOYEES_NAME,
									XMLData.CODE_LINE,
									XMLData.NAME_LINE,
									XMLData.WORK_DATE,
									XMLData.START_TIME,
									XMLData.END_TIME,
									XMLData.TOTAL_TIME,
									XMLData.CREATEDATETIME,
									XMLData.CREATEUSSERID,
									XMLData.CHANGEDATETIME,
									XMLData.CHANGEUSERID
								
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 EMPLOYEES_ID NVARCHAR(50),
											 EMPLOYEES_NAME NVARCHAR(100),
											 CODE_LINE NVARCHAR(50),
											 NAME_LINE NVARCHAR(50),
											 WORK_DATE DATETIME,
											 START_TIME NVARCHAR(50),
											 END_TIME NVARCHAR(50),
											 TOTAL_TIME INT,
											 CREATEDATETIME  DATETIMEOFFSET,
											 CREATEUSSERID VARCHAR(20),
											 CHANGEDATETIME  DATETIMEOFFSET,
											 CHANGEUSERID VARCHAR(20)
											
											) XMLData
									UNION ALL
			SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.EMPLOYEES_ID,
									XMLData.EMPLOYEES_NAME,
									XMLData.CODE_LINE,
									XMLData.NAME_LINE,
									XMLData.WORK_DATE,
									XMLData.START_TIME,
									XMLData.END_TIME,
									XMLData.TOTAL_TIME,
									XMLData.CREATEDATETIME,
									XMLData.CREATEUSSERID,
									XMLData.CHANGEDATETIME,
									XMLData.CHANGEUSERID
								
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 EMPLOYEES_ID NVARCHAR(50),
											 EMPLOYEES_NAME NVARCHAR(100),
											 CODE_LINE NVARCHAR(50),
											 NAME_LINE NVARCHAR(50),
											 WORK_DATE DATETIME,
											 START_TIME NVARCHAR(50),
											 END_TIME NVARCHAR(50),
											 TOTAL_TIME INT,
											 CREATEDATETIME  DATETIMEOFFSET,
											 CREATEUSSERID NVARCHAR(50),
											 CHANGEDATETIME  DATETIMEOFFSET,
											 CHANGEUSERID NVARCHAR(50)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.EMPLOYEES_ID,
									XMLData.EMPLOYEES_NAME,
									XMLData.CODE_LINE,
									XMLData.NAME_LINE,
									XMLData.WORK_DATE,
									XMLData.START_TIME,
									XMLData.END_TIME,
									XMLData.TOTAL_TIME,
									XMLData.CREATEDATETIME,
									XMLData.CREATEUSSERID,
									XMLData.CHANGEDATETIME,
									XMLData.CHANGEUSERID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 EMPLOYEES_ID NVARCHAR(50),
											 EMPLOYEES_NAME NVARCHAR(100),
											 CODE_LINE NVARCHAR(50),
											 NAME_LINE NVARCHAR(50),
											 WORK_DATE DATETIME,
											 START_TIME NVARCHAR(50),
											 END_TIME NVARCHAR(50),
											 TOTAL_TIME INT,
											 CREATEDATETIME  DATETIMEOFFSET,
											 CREATEUSSERID NVARCHAR(50),
											 CHANGEDATETIME  DATETIMEOFFSET,
											 CHANGEUSERID VARCHAR(20)
											
											) XMLData
					 OPEN SourceData

		
					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @EMPLOYEES_ID,
								 @EMPLOYEES_NAME,
								 @CODE_LINE,
								 @NAME_LINE,
								 @WORK_DATE,
								 @START_TIME,
								 @END_TIME,
								 @TOTAL_TIME,
								 @CREATEDATETIME,
								 @CREATEUSSERID,
								 @CHANGEDATETIME,
								 @CHANGEUSERID
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_ATTENDANCE_TIME WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_ATTENDANCE_TIME', @OldCompanyCode OUTPUT

							INSERT INTO STB_VN_ATTENDANCE_TIME
						(
						    EMPLOYEES_ID,
						    EMPLOYEES_NAME,
						    CODE_LINE,
						    NAME_LINE,
						    WORK_DATE,
						    START_TIME,
							END_TIME,
							TOTAL_TIME,
						    CREATEDATETIME,
						    CREATEUSSERID,
						    CHANGEDATETIME,
						    CHANGEUSERID
							
						)
						VALUES
						(
						    @EMPLOYEES_ID,
						    @EMPLOYEES_NAME,
						    @CODE_LINE,
						    @NAME_LINE,
						    @WORK_DATE,
						    @START_TIME,
							@END_TIME,
							@TOTAL_TIME,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

						END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_VN_ATTENDANCE_TIME
						SET

						EMPLOYEES_ID = CASE
									WHEN @EMPLOYEES_ID IS NOT NULL THEN @EMPLOYEES_ID
									ELSE EMPLOYEES_ID
									END,
							EMPLOYEES_NAME =   CASE
						                WHEN @EMPLOYEES_NAME IS NOT NULL THEN @EMPLOYEES_NAME
						                ELSE EMPLOYEES_NAME
						            END,
						CODE_LINE =   CASE
						                WHEN @CODE_LINE IS NOT NULL THEN @CODE_LINE
						                ELSE CODE_LINE
						            END,

							 NAME_LINE =   CASE
						                WHEN @NAME_LINE IS NOT NULL THEN @NAME_LINE
						                ELSE NAME_LINE
						            END,

							 WORK_DATE =   CASE
						                WHEN @WORK_DATE IS NOT NULL THEN @WORK_DATE
						                ELSE WORK_DATE
						            END,

							 START_TIME =   CASE
						                WHEN @START_TIME IS NOT NULL THEN @START_TIME
						                ELSE START_TIME
						            END,
						 END_TIME =   CASE
						                WHEN @END_TIME IS NOT NULL THEN @END_TIME
						                ELSE END_TIME
						            END,
						 TOTAL_TIME =   CASE
						                WHEN @TOTAL_TIME IS NOT NULL THEN @TOTAL_TIME
						                ELSE TOTAL_TIME
						            END,
					
						    CHANGEDATETIME = DATEADD(HH, -2, GETDATE()),
						    CHANGEUSERID = @pProcessUserID
						
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_PRODUCTION_ERROR
						WHERE
						    IDPE = @OldCompanyCode
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