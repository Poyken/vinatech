
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-07-11
-- Browsable : true
-- Group : 생산관리공용
-- Description:	라인마스터를 추가/수정/삭제합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
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

    -- Declare Columns Variable
  DECLARE @OldLineCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineName NVARCHAR(50)
  DECLARE @LineDesc NVARCHAR(200)
  DECLARE @LineType VARCHAR(10)
  DECLARE @LineBarcode VARCHAR(10)
  DECLARE @ErpCode VARCHAR(20)
  DECLARE @MonitoringGroup NVARCHAR(50)
  DECLARE @MonitoringName NVARCHAR(50)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  -- STB_LineInfo 컬럼추가 : 일상점검모니터링여부
  DECLARE @IsCheckScheduleMonitoring BIT
    DECLARE @ChildLines VARCHAR(255)
	DECLARE @MaterialWarehouseCode VARCHAR(50)
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_LineInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_LineInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							LineCode,
							CompanyCode,
							WorkCenterCode,
							LineName,
							LineDesc,
							LineType,
							LineBarcode,
							ErpCode,
							MonitoringGroup,
							MonitoringName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsCheckScheduleMonitoring,
							ChildLines ,
							MaterialWarehouseCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										LineCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineName NVARCHAR(50),
										LineDesc NVARCHAR(200),
										LineType VARCHAR(10),
										LineBarcode VARCHAR(10),
										ErpCode VARCHAR(20),
										MonitoringGroup NVARCHAR(50),
										MonitoringName NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsCheckScheduleMonitoring BIT,
										ChildLines VARCHAR(255),
										MaterialWarehouseCode VARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.LineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineName = ISNULL(SourceTable.LineName,TargetTable.LineName),
					LineDesc = ISNULL(SourceTable.LineDesc,TargetTable.LineDesc),
					LineType = ISNULL(SourceTable.LineType,TargetTable.LineType),
					--LineBarcode = ISNULL(SourceTable.LineBarcode,TargetTable.LineBarcode),
					ErpCode = ISNULL(SourceTable.ErpCode,TargetTable.ErpCode),
					MonitoringGroup = ISNULL(SourceTable.MonitoringGroup,TargetTable.MonitoringGroup),
					MonitoringName = ISNULL(SourceTable.MonitoringName,TargetTable.MonitoringName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsCheckScheduleMonitoring = ISNULL(SourceTable.IsCheckScheduleMonitoring,TargetTable.IsCheckScheduleMonitoring),
					ChildLines = ISNULL(SourceTable.ChildLines,TargetTable.ChildLines),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode)


			
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						CompanyCode,
						WorkCenterCode,
						LineName,
						LineDesc,
						LineType,
						--LineBarcode,
						ErpCode,
						MonitoringGroup,
						MonitoringName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsCheckScheduleMonitoring,
						ChildLines,
						MaterialWarehouseCode
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineName,
							SourceTable.LineDesc,
							SourceTable.LineType,
							--SourceTable.LineBarcode,
							SourceTable.ErpCode,
							SourceTable.MonitoringGroup,
							SourceTable.MonitoringName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsCheckScheduleMonitoring,
							SourceTable.ChildLines,
							SourceTable.MaterialWarehouseCode


									
					);


			-- Process Update Table
            MERGE STB_LineInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							LineCode,
							CompanyCode,
							WorkCenterCode,
							LineName,
							LineDesc,
							LineType,
							LineBarcode,
							ErpCode,
							MonitoringGroup,
							MonitoringName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsCheckScheduleMonitoring,
							ChildLines,
							MaterialWarehouseCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										LineCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineName NVARCHAR(50),
										LineDesc NVARCHAR(200),
										LineType VARCHAR(10),
										LineBarcode VARCHAR(10),
										ErpCode VARCHAR(20),
										MonitoringGroup NVARCHAR(50),
										MonitoringName NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsCheckScheduleMonitoring BIT,
										ChildLines VARCHAR(255),
										MaterialWarehouseCode VARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.OldLineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineName = ISNULL(SourceTable.LineName,TargetTable.LineName),
					LineDesc = ISNULL(SourceTable.LineDesc,TargetTable.LineDesc),
					LineType = ISNULL(SourceTable.LineType,TargetTable.LineType),
					--LineBarcode = ISNULL(SourceTable.LineBarcode,TargetTable.LineBarcode),
					ErpCode = ISNULL(SourceTable.ErpCode,TargetTable.ErpCode),
					MonitoringGroup = ISNULL(SourceTable.MonitoringGroup,TargetTable.MonitoringGroup),
					MonitoringName = ISNULL(SourceTable.MonitoringName,TargetTable.MonitoringName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsCheckScheduleMonitoring = ISNULL(SourceTable.IsCheckScheduleMonitoring,TargetTable.IsCheckScheduleMonitoring),
					ChildLines = ISNULL(SourceTable.ChildLines,TargetTable.ChildLines),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode)


			
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						CompanyCode,
						WorkCenterCode,
						LineName,
						LineDesc,
						LineType,
						--LineBarcode,
						ErpCode,
						MonitoringGroup,
						MonitoringName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsCheckScheduleMonitoring,
						ChildLines ,
						MaterialWarehouseCode
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineName,
							SourceTable.LineDesc,
							SourceTable.LineType,
							--SourceTable.LineBarcode,
							SourceTable.ErpCode,
							SourceTable.MonitoringGroup,
							SourceTable.MonitoringName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsCheckScheduleMonitoring,
							SourceTable.ChildLines ,
							SourceTable.MaterialWarehouseCode


									
					);


			-- Process Delete Table
            MERGE STB_LineInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							LineCode,
							CompanyCode,
							WorkCenterCode,
							LineName,
							LineDesc,
							LineType,
							LineBarcode,
							ErpCode,
							MonitoringGroup,
							MonitoringName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsCheckScheduleMonitoring,
							ChildLines ,
							MaterialWarehouseCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										LineCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineName NVARCHAR(50),
										LineDesc NVARCHAR(200),
										LineType VARCHAR(10),
										LineBarcode VARCHAR(10),
										ErpCode VARCHAR(20),
										MonitoringGroup NVARCHAR(50),
										MonitoringName NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsCheckScheduleMonitoring BIT,
										ChildLines VARCHAR(255),
										MaterialWarehouseCode VARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.LineCode
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
									OldLineCode,
									LineCode,
									CompanyCode,
									WorkCenterCode,
									LineName,
									LineDesc,
									LineType,
									LineBarcode,
									ErpCode,
									MonitoringGroup,
									MonitoringName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsCheckScheduleMonitoring,
									ChildLines,
									MaterialWarehouseCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineName NVARCHAR(50),
											 LineDesc NVARCHAR(200),
											 LineType VARCHAR(10),
											 LineBarcode VARCHAR(10),
											 ErpCode VARCHAR(20),
											 MonitoringGroup NVARCHAR(50),
											 MonitoringName NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsCheckScheduleMonitoring BIT,
											 ChildLines VARCHAR(255),
											 MaterialWarehouseCode VARCHAR(50)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									LineCode,
									CompanyCode,
									WorkCenterCode,
									LineName,
									LineDesc,
									LineType,
									LineBarcode,
									ErpCode,
									MonitoringGroup,
									MonitoringName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsCheckScheduleMonitoring,
									ChildLines ,
									MaterialWarehouseCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineName NVARCHAR(50),
											 LineDesc NVARCHAR(200),
											 LineType VARCHAR(10),
											 LineBarcode VARCHAR(10),
											 ErpCode VARCHAR(20),
											 MonitoringGroup NVARCHAR(50),
											 MonitoringName NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsCheckScheduleMonitoring BIT,
											 ChildLines VARCHAR(255),
											 MaterialWarehouseCode VARCHAR(50)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									LineCode,
									CompanyCode,
									WorkCenterCode,
									LineName,
									LineDesc,
									LineType,
									LineBarcode,
									ErpCode,
									MonitoringGroup,
									MonitoringName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsCheckScheduleMonitoring,
									ChildLines ,
									MaterialWarehouseCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineName NVARCHAR(50),
											 LineDesc NVARCHAR(200),
											 LineType VARCHAR(10),
											 LineBarcode VARCHAR(10),
											 ErpCode VARCHAR(20),
											 MonitoringGroup NVARCHAR(50),
											 MonitoringName NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsCheckScheduleMonitoring BIT,
											 ChildLines VARCHAR(255),
											 MaterialWarehouseCode VARCHAR(50)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLineCode,
								 @LineCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineName,
								 @LineDesc,
								 @LineType,
								 @LineBarcode,
								 @ErpCode,
								 @MonitoringGroup,
								 @MonitoringName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsCheckScheduleMonitoring,
								 @ChildLines ,
								 @MaterialWarehouseCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LineInfo WHERE LineCode = @LineCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_LineInfo', @LineCode OUTPUT
                    END

                    INSERT INTO STB_LineInfo
						(
						    LineCode,
						    CompanyCode,
						    WorkCenterCode,
						    LineName,
						    LineDesc,
						    LineType,
						    --LineBarcode,
						    ErpCode,
						    MonitoringGroup,
						    MonitoringName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsCheckScheduleMonitoring,
							ChildLines ,
							MaterialWarehouseCode
						)
						VALUES
						(
						    @LineCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @LineName,
						    @LineDesc,
						    @LineType,
						    --@LineBarcode,
						    @ErpCode,
						    @MonitoringGroup,
						    @MonitoringName,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsCheckScheduleMonitoring,
							@ChildLines,
							@MaterialWarehouseCode 
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_LineInfo
						SET
						    LineCode =   ISNULL(@LineCode,LineCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineName =   ISNULL(@LineName,LineName),
						    LineDesc =   ISNULL(@LineDesc,LineDesc),
						    LineType =   ISNULL(@LineType,LineType),
						    --LineBarcode =   ISNULL(@LineBarcode,LineBarcode),
						    ErpCode =   ISNULL(@ErpCode,ErpCode),
						    MonitoringGroup =   ISNULL(@MonitoringGroup,MonitoringGroup),
						    MonitoringName =   ISNULL(@MonitoringName,MonitoringName),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							IsCheckScheduleMonitoring =   ISNULL(@IsCheckScheduleMonitoring,IsCheckScheduleMonitoring),
							ChildLines =   ISNULL(@ChildLines,ChildLines),
							MaterialWarehouseCode =   ISNULL(@MaterialWarehouseCode,MaterialWarehouseCode)


						
						WHERE
						    LineCode = @OldLineCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_LineInfo
						WHERE
						    LineCode = @LineCode
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
