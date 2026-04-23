
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-05-25
-- Browsable : true
-- Group : 시스템관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_EAWorkInfo_iud]
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
  DECLARE @OldEAWorkNo VARCHAR(20)
  DECLARE @EAWorkNo VARCHAR(20)
  DECLARE @RequestContent VARCHAR(4000)
  DECLARE @RequestDeptCode VARCHAR(20)
  DECLARE @RequestWorkerCode VARCHAR(20)
  DECLARE @RequestDateTime DATETIME
  DECLARE @DueDate DATETIME
  DECLARE @ProcessingWorkerCode VARCHAR(20)
  DECLARE @FinishDateTime DATETIME
  DECLARE @IsFinish BIT
  DECLARE @Remark VARCHAR(4000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @RequestMenuPath NVARCHAR(500)
  DECLARE @ProcessingContent NVARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_EAWorkInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_EAWorkInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldEAWorkNo IS NULL THEN EAWorkNo
							    ELSE OldEAWorkNo
							END AS OldEAWorkNo,
							EAWorkNo,
							RequestContent,
							RequestDeptCode,
							RequestWorkerCode,
							RequestDateTime,
							DueDate,
							ProcessingWorkerCode,
							FinishDateTime,
							IsFinish,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							RequestMenuPath,
							ProcessingContent
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldEAWorkNo VARCHAR(20),
										EAWorkNo VARCHAR(20),
										RequestContent VARCHAR(4000),
										RequestDeptCode VARCHAR(20),
										RequestWorkerCode VARCHAR(20),
										RequestDateTime DATETIMEOFFSET,
										DueDate DATETIMEOFFSET,
										ProcessingWorkerCode VARCHAR(20),
										FinishDateTime DATETIMEOFFSET,
										IsFinish BIT,
										Remark VARCHAR(4000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										RequestMenuPath NVARCHAR(500),
										ProcessingContent NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.EAWorkNo = SourceTable.EAWorkNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					EAWorkNo = ISNULL(SourceTable.EAWorkNo,TargetTable.EAWorkNo),
					RequestContent = ISNULL(SourceTable.RequestContent,TargetTable.RequestContent),
					RequestDeptCode = ISNULL(SourceTable.RequestDeptCode,TargetTable.RequestDeptCode),
					RequestWorkerCode = ISNULL(SourceTable.RequestWorkerCode,TargetTable.RequestWorkerCode),
					RequestDateTime = ISNULL(SourceTable.RequestDateTime,TargetTable.RequestDateTime),
					DueDate = ISNULL(SourceTable.DueDate,TargetTable.DueDate),
					ProcessingWorkerCode = ISNULL(SourceTable.ProcessingWorkerCode,TargetTable.ProcessingWorkerCode),
					FinishDateTime = ISNULL(SourceTable.FinishDateTime,TargetTable.FinishDateTime),
					IsFinish = ISNULL(SourceTable.IsFinish,TargetTable.IsFinish),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					RequestMenuPath = ISNULL(SourceTable.RequestMenuPath,TargetTable.RequestMenuPath),
					ProcessingContent = ISNULL(SourceTable.ProcessingContent,TargetTable.ProcessingContent)
			WHEN NOT MATCHED THEN
				INSERT
					(
						EAWorkNo,
						RequestContent,
						RequestDeptCode,
						RequestWorkerCode,
						RequestDateTime,
						DueDate,
						ProcessingWorkerCode,
						FinishDateTime,
						IsFinish,
						Remark,
						CreateDateTime,
						CreateUserID,
						RequestMenuPath,
						ProcessingContent
					)
				VALUES
					(
							SourceTable.EAWorkNo,
							SourceTable.RequestContent,
							SourceTable.RequestDeptCode,
							SourceTable.RequestWorkerCode,
							SourceTable.RequestDateTime,
							SourceTable.DueDate,
							SourceTable.ProcessingWorkerCode,
							SourceTable.FinishDateTime,
							SourceTable.IsFinish,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.RequestMenuPath,
							SourceTable.ProcessingContent
					);


			-- Process Update Table
            MERGE STB_EAWorkInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldEAWorkNo IS NULL THEN EAWorkNo
							    ELSE OldEAWorkNo
							END AS OldEAWorkNo,
							EAWorkNo,
							RequestContent,
							RequestDeptCode,
							RequestWorkerCode,
							RequestDateTime,
							DueDate,
							ProcessingWorkerCode,
							FinishDateTime,
							IsFinish,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							RequestMenuPath,
							ProcessingContent
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldEAWorkNo VARCHAR(20),
										EAWorkNo VARCHAR(20),
										RequestContent VARCHAR(4000),
										RequestDeptCode VARCHAR(20),
										RequestWorkerCode VARCHAR(20),
										RequestDateTime DATETIMEOFFSET,
										DueDate DATETIMEOFFSET,
										ProcessingWorkerCode VARCHAR(20),
										FinishDateTime DATETIMEOFFSET,
										IsFinish BIT,
										Remark VARCHAR(4000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										RequestMenuPath NVARCHAR(500),
										ProcessingContent NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.EAWorkNo = SourceTable.OldEAWorkNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					EAWorkNo = ISNULL(SourceTable.EAWorkNo,TargetTable.EAWorkNo),
					RequestContent = ISNULL(SourceTable.RequestContent,TargetTable.RequestContent),
					RequestDeptCode = ISNULL(SourceTable.RequestDeptCode,TargetTable.RequestDeptCode),
					RequestWorkerCode = ISNULL(SourceTable.RequestWorkerCode,TargetTable.RequestWorkerCode),
					RequestDateTime = ISNULL(SourceTable.RequestDateTime,TargetTable.RequestDateTime),
					DueDate = ISNULL(SourceTable.DueDate,TargetTable.DueDate),
					ProcessingWorkerCode = ISNULL(SourceTable.ProcessingWorkerCode,TargetTable.ProcessingWorkerCode),
					FinishDateTime = ISNULL(SourceTable.FinishDateTime,TargetTable.FinishDateTime),
					IsFinish = ISNULL(SourceTable.IsFinish,TargetTable.IsFinish),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					RequestMenuPath = ISNULL(SourceTable.RequestMenuPath,TargetTable.RequestMenuPath),
					ProcessingContent = ISNULL(SourceTable.ProcessingContent,TargetTable.ProcessingContent)
			WHEN NOT MATCHED THEN
				INSERT
					(
						EAWorkNo,
						RequestContent,
						RequestDeptCode,
						RequestWorkerCode,
						RequestDateTime,
						DueDate,
						ProcessingWorkerCode,
						FinishDateTime,
						IsFinish,
						Remark,
						CreateDateTime,
						CreateUserID,
						RequestMenuPath,
						ProcessingContent
					)
				VALUES
					(
							SourceTable.EAWorkNo,
							SourceTable.RequestContent,
							SourceTable.RequestDeptCode,
							SourceTable.RequestWorkerCode,
							SourceTable.RequestDateTime,
							SourceTable.DueDate,
							SourceTable.ProcessingWorkerCode,
							SourceTable.FinishDateTime,
							SourceTable.IsFinish,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.RequestMenuPath,
							SourceTable.ProcessingContent
					);


			-- Process Delete Table
            MERGE STB_EAWorkInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldEAWorkNo IS NULL THEN EAWorkNo
							    ELSE OldEAWorkNo
							END AS OldEAWorkNo,
							EAWorkNo,
							RequestContent,
							RequestDeptCode,
							RequestWorkerCode,
							RequestDateTime,
							DueDate,
							ProcessingWorkerCode,
							FinishDateTime,
							IsFinish,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							RequestMenuPath,
							ProcessingContent
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldEAWorkNo VARCHAR(20),
										EAWorkNo VARCHAR(20),
										RequestContent VARCHAR(4000),
										RequestDeptCode VARCHAR(20),
										RequestWorkerCode VARCHAR(20),
										RequestDateTime DATETIMEOFFSET,
										DueDate DATETIMEOFFSET,
										ProcessingWorkerCode VARCHAR(20),
										FinishDateTime DATETIMEOFFSET,
										IsFinish BIT,
										Remark VARCHAR(4000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										RequestMenuPath NVARCHAR(500),
										ProcessingContent NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.EAWorkNo = SourceTable.EAWorkNo
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
									OldEAWorkNo,
									EAWorkNo,
									RequestContent,
									RequestDeptCode,
									RequestWorkerCode,
									RequestDateTime,
									DueDate,
									ProcessingWorkerCode,
									FinishDateTime,
									IsFinish,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									RequestMenuPath,
									ProcessingContent
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldEAWorkNo VARCHAR(20),
											 EAWorkNo VARCHAR(20),
											 RequestContent VARCHAR(4000),
											 RequestDeptCode VARCHAR(20),
											 RequestWorkerCode VARCHAR(20),
											 RequestDateTime DATETIMEOFFSET,
											 DueDate DATETIMEOFFSET,
											 ProcessingWorkerCode VARCHAR(20),
											 FinishDateTime DATETIMEOFFSET,
											 IsFinish BIT,
											 Remark VARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 RequestMenuPath NVARCHAR(500),
											 ProcessingContent NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldEAWorkNo IS NULL THEN EAWorkNo
										ELSE OldEAWorkNo
									END AS OldEAWorkNo,
									EAWorkNo,
									RequestContent,
									RequestDeptCode,
									RequestWorkerCode,
									RequestDateTime,
									DueDate,
									ProcessingWorkerCode,
									FinishDateTime,
									IsFinish,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									RequestMenuPath,
									ProcessingContent
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldEAWorkNo VARCHAR(20),
											 EAWorkNo VARCHAR(20),
											 RequestContent VARCHAR(4000),
											 RequestDeptCode VARCHAR(20),
											 RequestWorkerCode VARCHAR(20),
											 RequestDateTime DATETIMEOFFSET,
											 DueDate DATETIMEOFFSET,
											 ProcessingWorkerCode VARCHAR(20),
											 FinishDateTime DATETIMEOFFSET,
											 IsFinish BIT,
											 Remark VARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 RequestMenuPath NVARCHAR(500),
											 ProcessingContent NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldEAWorkNo IS NULL THEN EAWorkNo
										ELSE OldEAWorkNo
									END AS OldEAWorkNo,
									EAWorkNo,
									RequestContent,
									RequestDeptCode,
									RequestWorkerCode,
									RequestDateTime,
									DueDate,
									ProcessingWorkerCode,
									FinishDateTime,
									IsFinish,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									RequestMenuPath,
									ProcessingContent
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldEAWorkNo VARCHAR(20),
											 EAWorkNo VARCHAR(20),
											 RequestContent VARCHAR(4000),
											 RequestDeptCode VARCHAR(20),
											 RequestWorkerCode VARCHAR(20),
											 RequestDateTime DATETIMEOFFSET,
											 DueDate DATETIMEOFFSET,
											 ProcessingWorkerCode VARCHAR(20),
											 FinishDateTime DATETIMEOFFSET,
											 IsFinish BIT,
											 Remark VARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 RequestMenuPath NVARCHAR(500),
											 ProcessingContent NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldEAWorkNo,
								 @EAWorkNo,
								 @RequestContent,
								 @RequestDeptCode,
								 @RequestWorkerCode,
								 @RequestDateTime,
								 @DueDate,
								 @ProcessingWorkerCode,
								 @FinishDateTime,
								 @IsFinish,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @RequestMenuPath,
								 @ProcessingContent


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_EAWorkInfo WHERE EAWorkNo = @EAWorkNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @EAWorkNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_EAWorkInfo',@EAWorkNo OUTPUT
                    END

                    INSERT INTO STB_EAWorkInfo
						(
						    EAWorkNo,
						    RequestContent,
						    RequestDeptCode,
						    RequestWorkerCode,
						    RequestDateTime,
						    DueDate,
						    ProcessingWorkerCode,
						    FinishDateTime,
						    IsFinish,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    RequestMenuPath,
						    ProcessingContent
						)
						VALUES
						(
						    @EAWorkNo,
						    @RequestContent,
						    @RequestDeptCode,
						    @RequestWorkerCode,
						    @RequestDateTime,
						    @DueDate,
						    @ProcessingWorkerCode,
						    @FinishDateTime,
						    @IsFinish,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @RequestMenuPath,
						    @ProcessingContent
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_EAWorkInfo
						SET
						    EAWorkNo =   ISNULL(@EAWorkNo,EAWorkNo),
						    RequestContent =   ISNULL(@RequestContent,RequestContent),
						    RequestDeptCode =   ISNULL(@RequestDeptCode,RequestDeptCode),
						    RequestWorkerCode =   ISNULL(@RequestWorkerCode,RequestWorkerCode),
						    RequestDateTime =   ISNULL(@RequestDateTime,RequestDateTime),
						    DueDate =   ISNULL(@DueDate,DueDate),
						    ProcessingWorkerCode =   ISNULL(@ProcessingWorkerCode,ProcessingWorkerCode),
						    IsFinish =   ISNULL(@IsFinish,IsFinish),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    RequestMenuPath =   ISNULL(@RequestMenuPath,RequestMenuPath),
						    ProcessingContent =   ISNULL(@ProcessingContent,ProcessingContent)
						WHERE
						    EAWorkNo = @OldEAWorkNo

					IF @IsFinish = CONVERT(BIT, 1) BEGIN
						UPDATE STB_EAWorkInfo
						   SET FinishDateTime = GETDATE()
						 WHERE EAWorkNo = @OldEAWorkNo
					END ELSE BEGIN
						UPDATE STB_EAWorkInfo
						   SET FinishDateTime = NULL
						 WHERE EAWorkNo = @OldEAWorkNo
					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_EAWorkInfo
						WHERE
						    EAWorkNo = @OldEAWorkNo
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
