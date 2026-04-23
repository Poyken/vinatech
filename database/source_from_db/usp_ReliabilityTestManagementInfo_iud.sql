
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-12-03
-- Browsable : true
-- Group : 신뢰성관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestManagementInfo_iud]
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

    -- Declare Columns Variable
  DECLARE @OldRTSampleNo VARCHAR(20)
  DECLARE @RTSampleNo VARCHAR(20)
  DECLARE @RTReceptionNo VARCHAR(20)
  DECLARE @RTStatusCode VARCHAR(10)
  DECLARE @RTStatusDetail VARCHAR(100)
  DECLARE @RTReceptionDate DATETIME
  DECLARE @RTFinishDate DATE
  DECLARE @TestName VARCHAR(200)
  DECLARE @RTSampleInfo VARCHAR(MAX)
  DECLARE @RTReportFile VARBINARY(MAX)
  DECLARE @RTRemark VARCHAR(MAX)
  DECLARE @RTFeedbackReport VARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ReliabilityTestManagementInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ReliabilityTestManagementInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTSampleNo IS NULL THEN RTSampleNo
							    ELSE OldRTSampleNo
							END AS OldRTSampleNo,
							RTSampleNo,
							RTReceptionNo,
							RTStatusCode,
							RTStatusDetail,
							RTReceptionDate,
							RTFinishDate,
							TestName,
							RTSampleInfo,
							dbo.fnBase64ToBinary(RTReportFile) as RTReportFile,
							RTRemark,
							RTFeedbackReport,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRTSampleNo VARCHAR(20),
										RTSampleNo VARCHAR(20),
										RTReceptionNo VARCHAR(20),
										RTStatusCode VARCHAR(10),
										RTStatusDetail VARCHAR(100),
										RTReceptionDate DATETIMEOFFSET,
										RTFinishDate DATETIMEOFFSET,
										TestName VARCHAR(200),
										RTSampleInfo VARCHAR(MAX),
										RTReportFile NVARCHAR(MAX),
										RTRemark VARCHAR(MAX),
										RTFeedbackReport VARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTSampleNo = SourceTable.RTSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RTStatusCode = ISNULL(SourceTable.RTStatusCode,TargetTable.RTStatusCode),
					RTStatusDetail = ISNULL(SourceTable.RTStatusDetail,TargetTable.RTStatusDetail),
					RTReceptionDate = ISNULL(SourceTable.RTReceptionDate,TargetTable.RTReceptionDate),
					RTFinishDate = ISNULL(SourceTable.RTFinishDate,TargetTable.RTFinishDate),
					TestName = ISNULL(SourceTable.TestName,TargetTable.TestName),
					RTSampleInfo = ISNULL(SourceTable.RTSampleInfo,TargetTable.RTSampleInfo),
					RTReportFile = ISNULL(SourceTable.RTReportFile,TargetTable.RTReportFile),
					RTRemark = ISNULL(SourceTable.RTRemark,TargetTable.RTRemark),
					RTFeedbackReport = ISNULL(SourceTable.RTFeedbackReport,TargetTable.RTFeedbackReport),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RTSampleNo,
						RTStatusCode,
						RTStatusDetail,
						RTReceptionDate,
						RTFinishDate,
						TestName,
						RTSampleInfo,
						RTReportFile,
						RTRemark,
						RTFeedbackReport,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.RTSampleNo,
							SourceTable.RTStatusCode,
							SourceTable.RTStatusDetail,
							SourceTable.RTReceptionDate,
							SourceTable.RTFinishDate,
							SourceTable.TestName,
							SourceTable.RTSampleInfo,
							SourceTable.RTReportFile,
							SourceTable.RTRemark,
							SourceTable.RTFeedbackReport,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ReliabilityTestManagementInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTSampleNo IS NULL THEN RTSampleNo
							    ELSE OldRTSampleNo
							END AS OldRTSampleNo,
							RTSampleNo,
							RTReceptionNo,
							RTStatusCode,
							RTStatusDetail,
							RTReceptionDate,
							RTFinishDate,
							TestName,
							RTSampleInfo,
							dbo.fnBase64ToBinary(RTReportFile) as RTReportFile,
							RTRemark,
							RTFeedbackReport,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRTSampleNo VARCHAR(20),
										RTSampleNo VARCHAR(20),
										RTReceptionNo VARCHAR(20),
										RTStatusCode VARCHAR(10),
										RTStatusDetail VARCHAR(100),
										RTReceptionDate DATETIMEOFFSET,
										RTFinishDate DATETIMEOFFSET,
										TestName VARCHAR(200),
										RTSampleInfo VARCHAR(MAX),
										RTReportFile NVARCHAR(MAX),
										RTRemark VARCHAR(MAX),
										RTFeedbackReport VARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTSampleNo = SourceTable.OldRTSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RTStatusCode = ISNULL(SourceTable.RTStatusCode,TargetTable.RTStatusCode),
					RTStatusDetail = ISNULL(SourceTable.RTStatusDetail,TargetTable.RTStatusDetail),
					RTReceptionDate = ISNULL(SourceTable.RTReceptionDate,TargetTable.RTReceptionDate),
					RTFinishDate = ISNULL(SourceTable.RTFinishDate,TargetTable.RTFinishDate),
					TestName = ISNULL(SourceTable.TestName,TargetTable.TestName),
					RTSampleInfo = ISNULL(SourceTable.RTSampleInfo,TargetTable.RTSampleInfo),
					RTReportFile = ISNULL(SourceTable.RTReportFile,TargetTable.RTReportFile),
					RTRemark = ISNULL(SourceTable.RTRemark,TargetTable.RTRemark),
					RTFeedbackReport = ISNULL(SourceTable.RTFeedbackReport,TargetTable.RTFeedbackReport),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RTSampleNo,
						RTStatusCode,
						RTStatusDetail,
						RTReceptionDate,
						RTFinishDate,
						TestName,
						RTSampleInfo,
						RTReportFile,
						RTRemark,
						RTFeedbackReport,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.RTSampleNo,
							SourceTable.RTStatusCode,
							SourceTable.RTStatusDetail,
							SourceTable.RTReceptionDate,
							SourceTable.RTFinishDate,
							SourceTable.TestName,
							SourceTable.RTSampleInfo,
							SourceTable.RTReportFile,
							SourceTable.RTRemark,
							SourceTable.RTFeedbackReport,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ReliabilityTestManagementInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTSampleNo IS NULL THEN RTSampleNo
							    ELSE OldRTSampleNo
							END AS OldRTSampleNo,
							RTSampleNo,
							RTReceptionNo,
							RTStatusCode,
							RTStatusDetail,
							RTReceptionDate,
							RTFinishDate,
							TestName,
							RTSampleInfo,
							dbo.fnBase64ToBinary(RTReportFile) as RTReportFile,
							RTRemark,
							RTFeedbackReport,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRTSampleNo VARCHAR(20),
										RTSampleNo VARCHAR(20),
										RTReceptionNo VARCHAR(20),
										RTStatusCode VARCHAR(10),
										RTStatusDetail VARCHAR(100),
										RTReceptionDate DATETIMEOFFSET,
										RTFinishDate DATETIMEOFFSET,
										TestName VARCHAR(200),
										RTSampleInfo VARCHAR(MAX),
										RTReportFile NVARCHAR(MAX),
										RTRemark VARCHAR(MAX),
										RTFeedbackReport VARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTSampleNo = SourceTable.RTSampleNo
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
									OldRTSampleNo,
									RTSampleNo,
									RTReceptionNo,
									RTStatusCode,
									RTStatusDetail,
									RTReceptionDate,
									RTFinishDate,
									TestName,
									RTSampleInfo,
									dbo.fnBase64ToBinary(RTReportFile) as RTReportFile,
									RTRemark,
									RTFeedbackReport,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRTSampleNo VARCHAR(20),
											 RTSampleNo VARCHAR(20),
											 RTReceptionNo VARCHAR(20),
											 RTStatusCode VARCHAR(10),
											 RTStatusDetail VARCHAR(100),
											 RTReceptionDate DATETIMEOFFSET,
											 RTFinishDate DATETIMEOFFSET,
											 TestName VARCHAR(200),
											 RTSampleInfo VARCHAR(MAX),
											 RTReportFile NVARCHAR(MAX),
											 RTRemark VARCHAR(MAX),
											 RTFeedbackReport VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRTSampleNo IS NULL THEN RTSampleNo
										ELSE OldRTSampleNo
									END AS OldRTSampleNo,
									RTSampleNo,
									RTReceptionNo,
									RTStatusCode,
									RTStatusDetail,
									RTReceptionDate,
									RTFinishDate,
									TestName,
									RTSampleInfo,
									dbo.fnBase64ToBinary(RTReportFile) as RTReportFile,
									RTRemark,
									RTFeedbackReport,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRTSampleNo VARCHAR(20),
											 RTSampleNo VARCHAR(20),
											 RTReceptionNo VARCHAR(20),
											 RTStatusCode VARCHAR(10),
											 RTStatusDetail VARCHAR(100),
											 RTReceptionDate DATETIMEOFFSET,
											 RTFinishDate DATETIMEOFFSET,
											 TestName VARCHAR(200),
											 RTSampleInfo VARCHAR(MAX),
											 RTReportFile NVARCHAR(MAX),
											 RTRemark VARCHAR(MAX),
											 RTFeedbackReport VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRTSampleNo IS NULL THEN RTSampleNo
										ELSE OldRTSampleNo
									END AS OldRTSampleNo,
									RTSampleNo,
									RTReceptionNo,
									RTStatusCode,
									RTStatusDetail,
									RTReceptionDate,
									RTFinishDate,
									TestName,
									RTSampleInfo,
									dbo.fnBase64ToBinary(RTReportFile) as RTReportFile,
									RTRemark,
									RTFeedbackReport,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRTSampleNo VARCHAR(20),
											 RTSampleNo VARCHAR(20),
											 RTReceptionNo VARCHAR(20),
											 RTStatusCode VARCHAR(10),
											 RTStatusDetail VARCHAR(100),
											 RTReceptionDate DATETIMEOFFSET,
											 RTFinishDate DATETIMEOFFSET,
											 TestName VARCHAR(200),
											 RTSampleInfo VARCHAR(MAX),
											 RTReportFile NVARCHAR(MAX),
											 RTRemark VARCHAR(MAX),
											 RTFeedbackReport VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRTSampleNo,
								 @RTSampleNo,
								 @RTReceptionNo,
								 @RTStatusCode,
								 @RTStatusDetail,
								 @RTReceptionDate,
								 @RTFinishDate,
								 @TestName,
								 @RTSampleInfo,
								 @RTReportFile,
								 @RTRemark,
								 @RTFeedbackReport,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ReliabilityTestManagementInfo WHERE RTSampleNo = @RTSampleNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RTSampleNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ReliabilityTestManagementInfo',@RTSampleNo OUTPUT
                    END

                    INSERT INTO STB_ReliabilityTestManagementInfo
						(
						    RTSampleNo,
						    RTStatusCode,
						    RTStatusDetail,
						    RTReceptionDate,
						    RTFinishDate,
						    TestName,
						    RTSampleInfo,
						    RTReportFile,
						    RTRemark,
						    RTFeedbackReport,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @RTSampleNo,
						    @RTStatusCode,
						    @RTStatusDetail,
						    @RTReceptionDate,
						    @RTFinishDate,
						    @TestName,
						    @RTSampleInfo,
						    @RTReportFile,
						    @RTRemark,
						    @RTFeedbackReport,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ReliabilityTestManagementInfo
						SET
						    RTStatusCode =   ISNULL(@RTStatusCode,RTStatusCode),
						    RTStatusDetail =   ISNULL(@RTStatusDetail,RTStatusDetail),
						    RTReceptionDate =   ISNULL(@RTReceptionDate,RTReceptionDate),
						    RTFinishDate =   ISNULL(@RTFinishDate,RTFinishDate),
						    TestName =   ISNULL(@TestName,TestName),
						    RTSampleInfo =   ISNULL(@RTSampleInfo,RTSampleInfo),
						    RTReportFile =   ISNULL(@RTReportFile,RTReportFile),
						    RTRemark =   ISNULL(@RTRemark,RTRemark),
						    RTFeedbackReport =   ISNULL(@RTFeedbackReport,RTFeedbackReport),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    RTSampleNo = @OldRTSampleNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ReliabilityTestManagementInfo
						WHERE
						    RTSampleNo = @OldRTSampleNo
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
