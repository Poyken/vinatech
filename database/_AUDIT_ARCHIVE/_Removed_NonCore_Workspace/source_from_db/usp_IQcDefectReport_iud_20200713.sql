
-- =============================================
-- Author:	    kilee
-- Create date: 2020-07-10
-- Browsable : true
-- Group : 품질관리>수입검사
-- Description:	
--					2020-07-15 자동 NCRNO부분 추가
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_IQcDefectReport_iud_20200713]
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
  DECLARE @OldDefectReportNo VARCHAR(20)
  DECLARE @DefectReportNo VARCHAR(20)
  DECLARE @DefectDivisionCode VARCHAR(3)
  DECLARE @PublishDeptCode VARCHAR(20)
  DECLARE @PublishEmpID VARCHAR(20)
  DECLARE @OccurProcessCode VARCHAR(3)
  DECLARE @JobDate DATETIME
  DECLARE @LotNo VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectLotSize INT
  DECLARE @ActionCode VARCHAR(20)
  DECLARE @ImmediateAction NVARCHAR(4000)
  DECLARE @CauseInvestigation NVARCHAR(4000)
  DECLARE @PreventionRecurrence NVARCHAR(4000)
  DECLARE @DetectionCounterMeasures NVARCHAR(4000)
  DECLARE @CheckingCorrectiveAction NVARCHAR(4000)
  DECLARE @Validation NVARCHAR(4000)
  DECLARE @Nonconformity NVARCHAR(4000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ProdProcessResultFile BIGINT
  DECLARE @ApprovalStepID INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule  
			@pTableName = 'STB_IQcDefectReport',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_IQcDefectReport AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							DefectReportNo,
							DefectDivisionCode,
							PublishDeptCode,
							PublishEmpID,
							OccurProcessCode,
							JobDate,
							LotNo,
						--	DefectCode,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							DefectLotSize,
						--	ActionCode,
							ImmediateAction,
							CauseInvestigation,
							PreventionRecurrence,
							DetectionCounterMeasures,
							CheckingCorrectiveAction,
							Validation,
							Nonconformity,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ProdProcessResultFile,
							ApprovalStepID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectDivisionCode VARCHAR(3),
										PublishDeptCode VARCHAR(20),
										PublishEmpID VARCHAR(20),
										OccurProcessCode VARCHAR(3),
										JobDate DATETIMEOFFSET,
										LotNo VARCHAR(20),
								--		DefectCode VARCHAR(20),
										DefectImage NVARCHAR(MAX),
										DefectLotSize INT,
								--		ActionCode VARCHAR(20),
										ImmediateAction NVARCHAR(4000),
										CauseInvestigation NVARCHAR(4000),
										PreventionRecurrence NVARCHAR(4000),
										DetectionCounterMeasures NVARCHAR(4000),
										CheckingCorrectiveAction NVARCHAR(4000),
										Validation NVARCHAR(4000),
										Nonconformity NVARCHAR(4000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										ApprovalStepID INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.DefectReportNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectReportNo = ISNULL(SourceTable.DefectReportNo,TargetTable.DefectReportNo),
					DefectDivisionCode = ISNULL(SourceTable.DefectDivisionCode,TargetTable.DefectDivisionCode),
					PublishDeptCode = ISNULL(SourceTable.PublishDeptCode,TargetTable.PublishDeptCode),
					PublishEmpID = ISNULL(SourceTable.PublishEmpID,TargetTable.PublishEmpID),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					--DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectLotSize = ISNULL(SourceTable.DefectLotSize,TargetTable.DefectLotSize),
					--ActionCode = ISNULL(SourceTable.ActionCode,TargetTable.ActionCode),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CauseInvestigation = ISNULL(SourceTable.CauseInvestigation,TargetTable.CauseInvestigation),
					PreventionRecurrence = ISNULL(SourceTable.PreventionRecurrence,TargetTable.PreventionRecurrence),
					DetectionCounterMeasures = ISNULL(SourceTable.DetectionCounterMeasures,TargetTable.DetectionCounterMeasures),
					CheckingCorrectiveAction = ISNULL(SourceTable.CheckingCorrectiveAction,TargetTable.CheckingCorrectiveAction),
					Validation = ISNULL(SourceTable.Validation,TargetTable.Validation),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ProdProcessResultFile = ISNULL(SourceTable.ProdProcessResultFile,TargetTable.ProdProcessResultFile),
					ApprovalStepID = ISNULL(SourceTable.ApprovalStepID,TargetTable.ApprovalStepID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectDivisionCode,
						PublishDeptCode,
						PublishEmpID,
						OccurProcessCode,
						JobDate,
						LotNo,
					--	DefectCode,
						DefectImage,
						DefectLotSize,
					--	ActionCode,
						ImmediateAction,
						CauseInvestigation,
						PreventionRecurrence,
						DetectionCounterMeasures,
						CheckingCorrectiveAction,
						Validation,
						Nonconformity,
						CreateDateTime,
						CreateUserID,
						ProdProcessResultFile,
						ApprovalStepID
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectDivisionCode,
							SourceTable.PublishDeptCode,
							SourceTable.PublishEmpID,
							SourceTable.OccurProcessCode,
							SourceTable.JobDate,
							SourceTable.LotNo,
						--	SourceTable.DefectCode,
							SourceTable.DefectImage,
							SourceTable.DefectLotSize,
						--	SourceTable.ActionCode,
							SourceTable.ImmediateAction,
							SourceTable.CauseInvestigation,
							SourceTable.PreventionRecurrence,
							SourceTable.DetectionCounterMeasures,
							SourceTable.CheckingCorrectiveAction,
							SourceTable.Validation,
							SourceTable.Nonconformity,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ProdProcessResultFile,
							SourceTable.ApprovalStepID
					);


			-- Process Update Table
            MERGE STB_IQcDefectReport AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							DefectReportNo,
							DefectDivisionCode,
							PublishDeptCode,
							PublishEmpID,
							OccurProcessCode,
							JobDate,
							LotNo,
						--	DefectCode,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							DefectLotSize,
						--	ActionCode,
							ImmediateAction,
							CauseInvestigation,
							PreventionRecurrence,
							DetectionCounterMeasures,
							CheckingCorrectiveAction,
							Validation,
							Nonconformity,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ProdProcessResultFile,
							ApprovalStepID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectDivisionCode VARCHAR(3),
										PublishDeptCode VARCHAR(20),
										PublishEmpID VARCHAR(20),
										OccurProcessCode VARCHAR(3),
										JobDate DATETIMEOFFSET,
										LotNo VARCHAR(20),
									--	DefectCode VARCHAR(20),
										DefectImage NVARCHAR(MAX),
										DefectLotSize INT,
									--	ActionCode VARCHAR(20),
										ImmediateAction NVARCHAR(4000),
										CauseInvestigation NVARCHAR(4000),
										PreventionRecurrence NVARCHAR(4000),
										DetectionCounterMeasures NVARCHAR(4000),
										CheckingCorrectiveAction NVARCHAR(4000),
										Validation NVARCHAR(4000),
										Nonconformity NVARCHAR(4000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										ApprovalStepID INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.OldDefectReportNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectReportNo = ISNULL(SourceTable.DefectReportNo,TargetTable.DefectReportNo),
					DefectDivisionCode = ISNULL(SourceTable.DefectDivisionCode,TargetTable.DefectDivisionCode),
					PublishDeptCode = ISNULL(SourceTable.PublishDeptCode,TargetTable.PublishDeptCode),
					PublishEmpID = ISNULL(SourceTable.PublishEmpID,TargetTable.PublishEmpID),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					--DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectLotSize = ISNULL(SourceTable.DefectLotSize,TargetTable.DefectLotSize),
					--ActionCode = ISNULL(SourceTable.ActionCode,TargetTable.ActionCode),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CauseInvestigation = ISNULL(SourceTable.CauseInvestigation,TargetTable.CauseInvestigation),
					PreventionRecurrence = ISNULL(SourceTable.PreventionRecurrence,TargetTable.PreventionRecurrence),
					DetectionCounterMeasures = ISNULL(SourceTable.DetectionCounterMeasures,TargetTable.DetectionCounterMeasures),
					CheckingCorrectiveAction = ISNULL(SourceTable.CheckingCorrectiveAction,TargetTable.CheckingCorrectiveAction),
					Validation = ISNULL(SourceTable.Validation,TargetTable.Validation),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ProdProcessResultFile = ISNULL(SourceTable.ProdProcessResultFile,TargetTable.ProdProcessResultFile),
					ApprovalStepID = ISNULL(SourceTable.ApprovalStepID,TargetTable.ApprovalStepID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectDivisionCode,
						PublishDeptCode,
						PublishEmpID,
						OccurProcessCode,
						JobDate,
						LotNo,
						--DefectCode,
						DefectImage,
						DefectLotSize,
						--ActionCode,
						ImmediateAction,
						CauseInvestigation,
						PreventionRecurrence,
						DetectionCounterMeasures,
						CheckingCorrectiveAction,
						Validation,
						Nonconformity,
						CreateDateTime,
						CreateUserID,
						ProdProcessResultFile,
						ApprovalStepID
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectDivisionCode,
							SourceTable.PublishDeptCode,
							SourceTable.PublishEmpID,
							SourceTable.OccurProcessCode,
							SourceTable.JobDate,
							SourceTable.LotNo,
							--SourceTable.DefectCode,
							SourceTable.DefectImage,
							SourceTable.DefectLotSize,
							--SourceTable.ActionCode,
							SourceTable.ImmediateAction,
							SourceTable.CauseInvestigation,
							SourceTable.PreventionRecurrence,
							SourceTable.DetectionCounterMeasures,
							SourceTable.CheckingCorrectiveAction,
							SourceTable.Validation,
							SourceTable.Nonconformity,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ProdProcessResultFile,
							SourceTable.ApprovalStepID
					);


			-- Process Delete Table
            MERGE STB_IQcDefectReport AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							DefectReportNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.DefectReportNo
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
									OldDefectReportNo,
									DefectReportNo,
									DefectDivisionCode,
									PublishDeptCode,
									PublishEmpID,
									OccurProcessCode,
									JobDate,
									LotNo,
									--DefectCode,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									DefectLotSize,
									--ActionCode,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									Nonconformity,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 JobDate DATETIMEOFFSET,
											 LotNo VARCHAR(20),
											 --DefectCode VARCHAR(20),
											 DefectImage NVARCHAR(MAX),
											 DefectLotSize INT,
											-- ActionCode VARCHAR(20),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 Nonconformity NVARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectReportNo IS NULL THEN DefectReportNo
										ELSE OldDefectReportNo
									END AS OldDefectReportNo,
									DefectReportNo,
									DefectDivisionCode,
									PublishDeptCode,
									PublishEmpID,
									OccurProcessCode,
									JobDate,
									LotNo,
									--DefectCode,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									DefectLotSize,
									--ActionCode,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									Nonconformity,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 JobDate DATETIMEOFFSET,
											 LotNo VARCHAR(20),
											-- DefectCode VARCHAR(20),
											 DefectImage NVARCHAR(MAX),
											 DefectLotSize INT,
											 --ActionCode VARCHAR(20),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 Nonconformity NVARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectReportNo IS NULL THEN DefectReportNo
										ELSE OldDefectReportNo
									END AS OldDefectReportNo,
									DefectReportNo,
									DefectDivisionCode,
									PublishDeptCode,
									PublishEmpID,
									OccurProcessCode,
									JobDate,
									LotNo,
									--DefectCode,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									DefectLotSize,
									--ActionCode,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									Nonconformity,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 JobDate DATETIMEOFFSET,
											 LotNo VARCHAR(20),
											 --DefectCode VARCHAR(20),
											 DefectImage NVARCHAR(MAX),
											 DefectLotSize INT,
											 --ActionCode VARCHAR(20),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 Nonconformity NVARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectReportNo,
								 @DefectReportNo,
								 @DefectDivisionCode,
								 @PublishDeptCode,
								 @PublishEmpID,
								 @OccurProcessCode,
								 @JobDate,
								 @LotNo,
								-- @DefectCode,
								 @DefectImage,
								 @DefectLotSize,
								 --@ActionCode,
								 @ImmediateAction,
								 @CauseInvestigation,
								 @PreventionRecurrence,
								 @DetectionCounterMeasures,
								 @CheckingCorrectiveAction,
								 @Validation,
								 @Nonconformity,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ProdProcessResultFile,
								 @ApprovalStepID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectReportNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_IQcDefectReport',@DefectReportNo OUTPUT
                    END

                    INSERT INTO STB_IQcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						    OccurProcessCode,
						    JobDate,
						    LotNo,
						  --  DefectCode,
						    DefectImage,
						    DefectLotSize,
						   -- ActionCode,
						    ImmediateAction,
						    CauseInvestigation,
						    PreventionRecurrence,
						    DetectionCounterMeasures,
						    CheckingCorrectiveAction,
						    Validation,
						    Nonconformity,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
						    ApprovalStepID
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @OccurProcessCode,
						    @JobDate,
						    @LotNo,
						   -- @DefectCode,
						    @DefectImage,
						    @DefectLotSize,
						    --@ActionCode,
						    @ImmediateAction,
						    @CauseInvestigation,
						    @PreventionRecurrence,
						    @DetectionCounterMeasures,
						    @CheckingCorrectiveAction,
						    @Validation,
						    @Nonconformity,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
						    @ApprovalStepID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
      --              UPDATE STB_IQcDefectReport
						--SET
						--    DefectReportNo =   ISNULL(@DefectReportNo,DefectReportNo),
						--    DefectDivisionCode =   ISNULL(@DefectDivisionCode,DefectDivisionCode),
						--    PublishDeptCode =   ISNULL(@PublishDeptCode,PublishDeptCode),
						--    PublishEmpID =   ISNULL(@PublishEmpID,PublishEmpID),
						--    OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
						--    JobDate =   ISNULL(@JobDate,JobDate),
						--    LotNo =   ISNULL(@LotNo,LotNo),
						--    DefectCode =   ISNULL(@DefectCode,DefectCode),
						--    DefectImage =   ISNULL(@DefectImage,DefectImage),
						--    DefectLotSize =   ISNULL(@DefectLotSize,DefectLotSize),
						--    ActionCode =   ISNULL(@ActionCode,ActionCode),
						--    ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
						--    CauseInvestigation =   ISNULL(@CauseInvestigation,CauseInvestigation),
						--    PreventionRecurrence =   ISNULL(@PreventionRecurrence,PreventionRecurrence),
						--    DetectionCounterMeasures =   ISNULL(@DetectionCounterMeasures,DetectionCounterMeasures),
						--    CheckingCorrectiveAction =   ISNULL(@CheckingCorrectiveAction,CheckingCorrectiveAction),
						--    Validation =   ISNULL(@Validation,Validation),
						--    Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
						--    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						--    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						--    ChangeDateTime = GETDATE(),
						--    ChangeUserID = @pProcessUserID,
						--    ProdProcessResultFile =   ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
						--    ApprovalStepID =   ISNULL(@ApprovalStepID,ApprovalStepID)
						--WHERE
						--    DefectReportNo = @OldDefectReportNo



               ----------------- 이부분부터 START
						-- 보고서번호가 존재하면 UPDATE
					IF EXISTS (SELECT 1 FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo) BEGIN

						UPDATE STB_QcDefectReport
						SET
						    DefectReportNo =   ISNULL(@DefectReportNo,DefectReportNo),
						    DefectDivisionCode =   ISNULL(@DefectDivisionCode,DefectDivisionCode),
						    PublishDeptCode =   ISNULL(@PublishDeptCode,PublishDeptCode),
						    PublishEmpID =   ISNULL(@PublishEmpID,PublishEmpID),
						    --ReceiveDeptCode =   ISNULL(@ReceiveDeptCode,ReceiveDeptCode),
						    OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
						   -- MachineCode =   ISNULL(@MachineCode,MachineCode),
						    --ProdWorkerCode =   ISNULL(@ProdWorkerCode,ProdWorkerCode),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    --MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    --MaterialName =   ISNULL(@MaterialName,MaterialName),
						   -- MaterialSpec =   ISNULL(@MaterialSpec,MaterialSpec),
						    --LotNo2 =   ISNULL(@LotNo2,LotNo2),
						    --LotNo3 =   ISNULL(@LotNo3,LotNo3),
						    --LotNo4 =   ISNULL(@LotNo4,LotNo4),
						    --LotNo5 =   ISNULL(@LotNo5,LotNo5),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    DefectImage =   ISNULL(@DefectImage,DefectImage),
						    DefectLotSize =   ISNULL(@DefectLotSize,DefectLotSize),
						    --DefectErrorCnt =   ISNULL(@DefectErrorCnt,DefectErrorCnt),
						    --DefectSampleCnt =   ISNULL(@DefectSampleCnt,DefectSampleCnt),
						    --LotLimitCnt =   ISNULL(@LotLimitCnt,LotLimitCnt),
						    --ActionContent =   ISNULL(@ActionContent,ActionContent),
						    --ActionWorkerCode =   ISNULL(@ActionWorkerCode,ActionWorkerCode),
						    --QcOpinionContent =   ISNULL(@QcOpinionContent,QcOpinionContent),
						    --IsCustomerSendRequired =   ISNULL(@IsCustomerSendRequired,IsCustomerSendRequired),
						    --ProdCauseContent =   ISNULL(@ProdCauseContent,ProdCauseContent),
						    --ProdCauseImage =   ISNULL(@ProdCauseImage,ProdCauseImage),
						    --ProdMeasuresContent =   ISNULL(@ProdMeasuresContent,ProdMeasuresContent),
						    --ProdProcessContent =   ISNULL(@ProdProcessContent,ProdProcessContent),
						    --ProdProcessResultCode =   ISNULL(@ProdProcessResultCode,ProdProcessResultCode),
						    --LossCost =   ISNULL(@LossCost,LossCost),
						    --ProdProcessContentAuthorUserName =   ISNULL(@ProdProcessContentAuthorUserName,ProdProcessContentAuthorUserName),
						    --ProdProcessContentCheckUserName =   ISNULL(@ProdProcessContentCheckUserName,ProdProcessContentCheckUserName),
						    --QcMeasuresContent =   ISNULL(@QcMeasuresContent,QcMeasuresContent),
						    --QcFlwupCheckContent =   ISNULL(@QcFlwupCheckContent,QcFlwupCheckContent),
						    --IsQcAsSatisfaction =   ISNULL(@IsQcAsSatisfaction,IsQcAsSatisfaction),
						    --IsProdHeadConfirm =   ISNULL(@IsProdHeadConfirm,IsProdHeadConfirm),
						    --ProdHeadComment =   ISNULL(@ProdHeadComment,ProdHeadComment),
						    --IsQcHeadConfirm =   ISNULL(@IsQcHeadConfirm,IsQcHeadConfirm),
						    --QcHeadComment =   ISNULL(@QcHeadComment,QcHeadComment),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    ProdProcessResultFile =   ISNULL(@ProdProcessResultFile,ProdProcessResultFile)
						WHERE
						    DefectReportNo = @OldDefectReportNo
					END ELSE BEGIN -- 그렇지 않으면 Insert
						--신규의 경우 @DefectReportNo = '자동채번'이므로 일치하는 번호가 없음.
						--Dummy쿼리의 자동채번 로직을 삭제하고 이 곳에서 신규로 채번함.
						--2020.07.07 By Jackaroe

						-- @DefectReportNo 채번
						SELECT @DefectReportNo = 'VNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' 
													  + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
						  FROM STB_QcDefectReport
						 WHERE DefectReportNo LIKE 'VNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'

						INSERT INTO STB_IQcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						   -- ReceiveDeptCode,
						    OccurProcessCode,
						    --MachineCode,
						    --ProdWorkerCode,
						    JobDate,
						    LotNo,
						    --MaterialCode,
						    --MaterialName,
						    --MaterialSpec,
						    --LotNo2,
						    --LotNo3,
						    --LotNo4,
						    --LotNo5,
						  --  DefectCode,
						    DefectImage,
						    DefectLotSize,
						    --DefectErrorCnt,
						    --DefectSampleCnt,
						    --LotLimitCnt,
						    --ActionContent,
						    --ActionWorkerCode,
						    --QcOpinionContent,
						    --IsCustomerSendRequired,
						    --ProdCauseContent,
						    --ProdCauseImage,
						    --ProdMeasuresContent,
						    --ProdProcessContent,
						    --ProdProcessResultCode,
						    --LossCost,
						    --ProdProcessContentAuthorUserName,
						    --ProdProcessContentCheckUserName,
						    --QcMeasuresContent,
						    --QcFlwupCheckContent,
						    --IsQcAsSatisfaction,
						    --IsProdHeadConfirm,
						    --ProdHeadComment,
						    --IsQcHeadConfirm,
						    --QcHeadComment,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    --@ReceiveDeptCode,
						    @OccurProcessCode,
						    --@MachineCode,
						    --@ProdWorkerCode,
						    @JobDate,
						    @LotNo,
						    --@MaterialCode,
						    --@MaterialName,
						    --@MaterialSpec,
						    --@LotNo2,
						    --@LotNo3,
						    --@LotNo4,
						    --@LotNo5,
						  --  @DefectCode,
						    @DefectImage,
						    @DefectLotSize,
						    --@DefectErrorCnt,
						    --@DefectSampleCnt,
						    --@LotLimitCnt,
						    --@ActionContent,
						    --@ActionWorkerCode,
						    --@QcOpinionContent,
						    --@IsCustomerSendRequired,
						    --@ProdCauseContent,
						    --@ProdCauseImage,
						    --@ProdMeasuresContent,
						    --@ProdProcessContent,
						    --@ProdProcessResultCode,
						    --@LossCost,
						    --@ProdProcessContentAuthorUserName,
						    --@ProdProcessContentCheckUserName,
						    --@QcMeasuresContent,
						    --@QcFlwupCheckContent,
						    --@IsQcAsSatisfaction,
						    --@IsProdHeadConfirm,
						    --@ProdHeadComment,
						    --@IsQcHeadConfirm,
						    --@QcHeadComment,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile
						)

						-- 최초 입력 후 겜바워크 그룹 메시지 발생
						-- 본사 발행 부적합 보고서만 전파 2020.06.23 이미정 차장 요청. By Jackaroe
					--	IF @PublishDeptCode = '4000' BEGIN
					--		exec usp_DoSendLineMessageForDefectReport '', '', @DefectReportNo
					--	END

					END

					--------------------------------------- 이부분까지임.



                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_IQcDefectReport
						WHERE
						    DefectReportNo = @OldDefectReportNo
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
