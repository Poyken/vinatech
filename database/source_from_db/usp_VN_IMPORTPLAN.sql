CREATE PROC [dbo].[usp_VN_IMPORTPLAN]
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
	DECLARE @DATEPLANS DATETIME
	DECLARE @MONTHPLAN NVARCHAR(50)
	DECLARE @MODEL NVARCHAR(50)
	DECLARE @GROUPSIZE NVARCHAR(50)
	DECLARE @DAILYTARGET NVARCHAR(50)
	DECLARE @REMARK NVARCHAR(MAX)
	DECLARE @TYPEDATA NVARCHAR(50)
	DECLARE @ISUSED BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @CompanyCode NVARCHAR(50)
	DECLARE @WorkCenterCode NVARCHAR(50)
	DECLARE @iDoc INT


	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PLAN_VN',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		 BEGIN TRY
				
					 MERGE STB_PLAN_VN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.DATEPLANS,
							XMLData.MONTHPLAN,
							XMLData.MODEL,
							XMLData.GROUPSIZE,
							XMLData.DAILYTARGET,
							XMLData.REMARK,
							XMLData.TYPEDATA,
							XMLData.ISUSED,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										DATEPLANS DATETIME,
										MONTHPLAN NVARCHAR(100),
										MODEL NVARCHAR(200),
										GROUPSIZE NVARCHAR(200),
										DAILYTARGET NVARCHAR(200),
										REMARK NVARCHAR(200),
										TYPEDATA NVARCHAR(100),
										ISUSED BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CompanyCode NVARCHAR(50),
										WorkCenterCode NVARCHAR(50)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)

				
WHEN MATCHED THEN
				UPDATE SET

					DATEPLANS = SourceTable.DATEPLANS,
					MONTHPLAN = SourceTable.MONTHPLAN,
					MODEL = SourceTable.MODEL,
					GROUPSIZE = SourceTable.GROUPSIZE,
					DAILYTARGET = SourceTable.DAILYTARGET,
					REMARK = SourceTable.REMARK,
					TYPEDATA = SourceTable.TYPEDATA,
					ISUSED= SourceTable.ISUSED,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode

					WHEN NOT MATCHED THEN

				INSERT
					(
						DATEPLANS,
						MONTHPLAN,
						MODEL,
						GROUPSIZE,
						DAILYTARGET,
						REMARK,
						TYPEDATA,
						ISUSED,
						CreateDateTime,
						CreateUserID,
						CompanyCode,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.DATEPLANS,
							SourceTable.MONTHPLAN,
							SourceTable.MODEL,
							SourceTable.GROUPSIZE,
							SourceTable.DAILYTARGET,
							SourceTable.REMARK,
							SourceTable.TYPEDATA,
							SourceTable.ISUSED,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CompanyCode,
						    SourceTable.WorkCenterCode
					);	


					MERGE STB_PLAN_VN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.DATEPLANS,
							XMLData.MONTHPLAN,
							XMLData.MODEL,
							XMLData.GROUPSIZE,
							XMLData.DAILYTARGET,
							XMLData.REMARK,
							XMLData.TYPEDATA,
							XMLData.ISUSED,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										DATEPLANS DATETIME,
										MONTHPLAN NVARCHAR(100),
										MODEL NVARCHAR(200),
										GROUPSIZE NVARCHAR(200),
										DAILYTARGET NVARCHAR(200),
										REMARK NVARCHAR(200),
										TYPEDATA NVARCHAR(100),
										ISUSED NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CompanyCode NVARCHAR(50),
										WorkCenterCode NVARCHAR(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)	

				
WHEN MATCHED THEN
				UPDATE SET
					DATEPLANS = SourceTable.DATEPLANS,
					MONTHPLAN = SourceTable.MONTHPLAN,
					MODEL = SourceTable.MODEL,
					GROUPSIZE = SourceTable.GROUPSIZE,
					DAILYTARGET = SourceTable.DAILYTARGET,
					REMARK = SourceTable.REMARK,
					TYPEDATA = SourceTable.TYPEDATA,
					ISUSED = SourceTable.ISUSED,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode
					
			WHEN NOT MATCHED THEN

			INSERT
					(
						DATEPLANS,
						MONTHPLAN,
						MODEL,
						GROUPSIZE,
						DAILYTARGET,
						REMARK,
						TYPEDATA,
						ISUSED,
						CreateDateTime,
						CreateUserID,
						CompanyCode,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.DATEPLANS,
							SourceTable.MONTHPLAN,
							SourceTable.MODEL,
							SourceTable.GROUPSIZE,
							SourceTable.DAILYTARGET,
							SourceTable.REMARK,
							SourceTable.TYPEDATA,
							SourceTable.ISUSED,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode
					);

								-- Process Delete Table
            MERGE STB_PLAN_VN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.DATEPLANS,
							XMLData.MONTHPLAN,
							XMLData.MODEL,
							XMLData.GROUPSIZE,
							XMLData.DAILYTARGET,
							XMLData.REMARK,
							XMLData.TYPEDATA,
							XMLData.ISUSED,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										DATEPLANS DATETIME,
										MONTHPLAN NVARCHAR(100),
										MODEL NVARCHAR(200),
										GROUPSIZE NVARCHAR(200),
										DAILYTARGET NVARCHAR(200),
										REMARK NVARCHAR(200),
										TYPEDATA NVARCHAR(100),
										ISUSED NVARCHAR(500),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CompanyCode NVARCHAR(50),
										WorkCenterCode NVARCHAR(50)
										
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
									XMLData.DATEPLANS,
									XMLData.MONTHPLAN,
									XMLData.MODEL,
									XMLData.GROUPSIZE,
									XMLData.DAILYTARGET,
									XMLData.REMARK,
									XMLData.TYPEDATA,
									XMLData.ISUSED,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 DATEPLANS DATETIME,
											 MONTHPLAN NVARCHAR(100),
											 MODEL NVARCHAR(200),
											 GROUPSIZE NVARCHAR(200),
											 DAILYTARGET NVARCHAR(200),
											 REMARK NVARCHAR(MAX),
											 TYPEDATA NVARCHAR(200),
											 ISUSED NVARCHAR(100),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CompanyCode NVARCHAR(50),
											 WorkCenterCode NVARCHAR(50)
											) XMLData
									UNION ALL


									SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.DATEPLANS,
									XMLData.MONTHPLAN,
									XMLData.MODEL,
									XMLData.GROUPSIZE,
									XMLData.DAILYTARGET,
									XMLData.REMARK,
									XMLData.TYPEDATA,
									XMLData.ISUSED,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 DATEPLANS DATETIME,
											 MONTHPLAN NVARCHAR(100),
											 MODEL NVARCHAR(200),
											 GROUPSIZE NVARCHAR(200),
											 DAILYTARGET NVARCHAR(200),
											 REMARK NVARCHAR(200),
											 TYPEDATA NVARCHAR(100),
											 ISUSED BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CompanyCode NVARCHAR(50),
											 WorkCenterCode NVARCHAR(50)
											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.DATEPLANS,
									XMLData.MONTHPLAN,
									XMLData.MODEL,
									XMLData.GROUPSIZE,
									XMLData.DAILYTARGET,
									XMLData.REMARK,
									XMLData.TYPEDATA,
									XMLData.ISUSED,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 DATEPLANS DATETIME,
											 MONTHPLAN NVARCHAR(100),
											 MODEL NVARCHAR(200),
											 GROUPSIZE NVARCHAR(200),
											 DAILYTARGET NVARCHAR(200),
											 REMARK NVARCHAR(200),
											 TYPEDATA NVARCHAR(200),
											 ISUSED BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CompanyCode NVARCHAR(50),
											 WorkCenterCode NVARCHAR(50)
											) XMLData

								 OPEN SourceData

					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @DATEPLANS,
								 @MONTHPLAN,
								 @MODEL,
								 @GROUPSIZE,
								 @DAILYTARGET,
								 @REMARK,
								 @TYPEDATA,
								 @ISUSED,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @CompanyCode,
								 @WorkCenterCode
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PLAN_VN WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END

					IF @IsAutoKey = 0 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PLAN_VN', @OldCompanyCode OUTPUT

			
						INSERT INTO STB_PLAN_VN
						(
						    DATEPLANS,
						    MONTHPLAN,
						    MODEL,
						    GROUPSIZE,
						    DAILYTARGET,
						    REMARK,
							TYPEDATA,
							ISUSED,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    CompanyCode,
							WorkCenterCode
						)
						VALUES
						(
						    
						    @DATEPLANS,
						    @MONTHPLAN,
						    @MODEL,
						    @GROUPSIZE,
						    @DAILYTARGET,
							@REMARK,
							@TYPEDATA,
							@ISUSED,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@CompanyCode,
						    @WorkCenterCode
						)


						
						END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_PLAN_VN
						SET
							DATEPLANS =   CASE
						                WHEN @DATEPLANS IS NOT NULL THEN @DATEPLANS
						                ELSE DATEPLANS
						            END,
						MONTHPLAN =   CASE
						                WHEN @MONTHPLAN IS NOT NULL THEN @MONTHPLAN
						                ELSE MONTHPLAN
						            END,

							 MODEL =   CASE
						                WHEN @MODEL IS NOT NULL THEN @MODEL
						                ELSE MODEL
						            END,

							 GROUPSIZE =   CASE
						                WHEN @GROUPSIZE IS NOT NULL THEN @GROUPSIZE
						                ELSE GROUPSIZE
						            END,
							 DAILYTARGET =   CASE
						                WHEN @DAILYTARGET IS NOT NULL THEN @DAILYTARGET
						                ELSE DAILYTARGET
						            END,
						 REMARK =   CASE
						                WHEN @REMARK IS NOT NULL THEN @REMARK
						                ELSE REMARK
						            END,
						 TYPEDATA =   CASE
						                WHEN @TYPEDATA IS NULL THEN @TYPEDATA
						                ELSE TYPEDATA
						            END,
						 ISUSED =   CASE
						                WHEN @ISUSED IS NOT NULL THEN @ISUSED
						                ELSE ISUSED
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_PLAN_VN
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
