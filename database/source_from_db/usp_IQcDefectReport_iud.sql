
-- =================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-07-13
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사
-- Description:	수입검사용 부적합등록!!!! 
-- Modified:
--                2020.07.15 DefectImage2 추가 
--                2020.12.16 QcOpinionContent 품질부서의견 / ActionContent Lot조치사항 추가
-- ==================================================================
CREATE PROCEDURE [dbo].[usp_IQcDefectReport_iud]
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
  DECLARE @LotNo VARCHAR(20)
  DECLARE @ProdProcessResultCode VARCHAR(2)
  DECLARE @CorrectiveActionCode VARCHAR(2)
  DECLARE @CorrectiveActionName VARCHAR(50)
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectImage2 VARBINARY(MAX)
  DECLARE @DefectLotSize INT
  DECLARE @IsActionCode BIT
  DECLARE @Nonconformity NVARCHAR(4000)
  DECLARE @ImmediateAction NVARCHAR(4000)
  DECLARE @CauseInvestigation NVARCHAR(4000)
  DECLARE @PreventionRecurrence NVARCHAR(4000)
  DECLARE @DetectionCounterMeasures NVARCHAR(4000)
  DECLARE @CheckingCorrectiveAction NVARCHAR(4000)

  DECLARE @QcOpinionContent NVARCHAR(4000)               -- 2020.12.16 추가
  DECLARE @ActionContent NVARCHAR(4000)                    -- 2020.12.16 추가
  
  DECLARE @Validation NVARCHAR(4000)
  DECLARE @JobDate DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ProdProcessResultFile BIGINT
  DECLARE @ApprovalStepID INT

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule
			@pTableName = 'STB_IQcDefectReport',               -- 수입검사용 부적합테이블
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
							LotNo,
							ProdProcessResultCode,
							CorrectiveActionCode,
							CorrectiveActionName,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							DefectLotSize,
							IsActionCode,
							Nonconformity,
							ImmediateAction,
							CauseInvestigation,
							PreventionRecurrence,
							DetectionCounterMeasures,
							CheckingCorrectiveAction,
							Validation,
							JobDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ProdProcessResultFile,
							ApprovalStepID,
							QcOpinionContent,
							ActionContent
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectDivisionCode VARCHAR(3),
										PublishDeptCode VARCHAR(20),
										PublishEmpID VARCHAR(20),
										OccurProcessCode VARCHAR(3),
										LotNo VARCHAR(20),
										ProdProcessResultCode VARCHAR(2),
										CorrectiveActionCode VARCHAR(2),
										CorrectiveActionName VARCHAR(50),
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										DefectLotSize INT,
										IsActionCode BIT,
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CauseInvestigation NVARCHAR(4000),
										PreventionRecurrence NVARCHAR(4000),
										DetectionCounterMeasures NVARCHAR(4000),
										CheckingCorrectiveAction NVARCHAR(4000),
										Validation NVARCHAR(4000),
										JobDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										ApprovalStepID INT,
										QcOpinionContent NVARCHAR(4000),
										ActionContent NVARCHAR(4000)
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
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					ProdProcessResultCode = ISNULL(SourceTable.ProdProcessResultCode,TargetTable.ProdProcessResultCode),
					CorrectiveActionCode = ISNULL(SourceTable.CorrectiveActionCode,TargetTable.CorrectiveActionCode),
					CorrectiveActionName = ISNULL(SourceTable.CorrectiveActionName,TargetTable.CorrectiveActionName),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2),
					DefectLotSize = ISNULL(SourceTable.DefectLotSize,TargetTable.DefectLotSize),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CauseInvestigation = ISNULL(SourceTable.CauseInvestigation,TargetTable.CauseInvestigation),
					PreventionRecurrence = ISNULL(SourceTable.PreventionRecurrence,TargetTable.PreventionRecurrence),
					DetectionCounterMeasures = ISNULL(SourceTable.DetectionCounterMeasures,TargetTable.DetectionCounterMeasures),
					CheckingCorrectiveAction = ISNULL(SourceTable.CheckingCorrectiveAction,TargetTable.CheckingCorrectiveAction),
					Validation = ISNULL(SourceTable.Validation,TargetTable.Validation),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ProdProcessResultFile = ISNULL(SourceTable.ProdProcessResultFile,TargetTable.ProdProcessResultFile),
					ApprovalStepID = ISNULL(SourceTable.ApprovalStepID,TargetTable.ApprovalStepID),
					QcOpinionContent = ISNULL(SourceTable.QcOpinionContent,TargetTable.QcOpinionContent),
					ActionContent = ISNULL(SourceTable.ActionContent,TargetTable.ActionContent)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectDivisionCode,
						PublishDeptCode,
						PublishEmpID,
						OccurProcessCode,
						LotNo,
						ProdProcessResultCode,
						CorrectiveActionCode,
						CorrectiveActionName,
						DefectImage,
						DefectImage2,
						DefectLotSize,
						IsActionCode,
						Nonconformity,
						ImmediateAction,
						CauseInvestigation,
						PreventionRecurrence,
						DetectionCounterMeasures,
						CheckingCorrectiveAction,
						Validation,
						JobDate,
						CreateDateTime,
						CreateUserID,
						ProdProcessResultFile,
						ApprovalStepID,
						QcOpinionContent,
						ActionContent
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectDivisionCode,
							SourceTable.PublishDeptCode,
							SourceTable.PublishEmpID,
							SourceTable.OccurProcessCode,
							SourceTable.LotNo,
							SourceTable.ProdProcessResultCode,
							SourceTable.CorrectiveActionCode,
							SourceTable.CorrectiveActionName,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.DefectLotSize,
							SourceTable.IsActionCode,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CauseInvestigation,
							SourceTable.PreventionRecurrence,
							SourceTable.DetectionCounterMeasures,
							SourceTable.CheckingCorrectiveAction,
							SourceTable.Validation,
							SourceTable.JobDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ProdProcessResultFile,
							SourceTable.ApprovalStepID,
							SourceTable.QcOpinionContent,
							SourceTable.ActionContent
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
							LotNo,
							ProdProcessResultCode,
							CorrectiveActionCode,
							CorrectiveActionName,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							DefectLotSize,
							IsActionCode,
							Nonconformity,
							ImmediateAction,
							CauseInvestigation,
							PreventionRecurrence,
							DetectionCounterMeasures,
							CheckingCorrectiveAction,
							Validation,
							JobDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ProdProcessResultFile,
							ApprovalStepID,
							QcOpinionContent,
							ActionContent
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectDivisionCode VARCHAR(3),
										PublishDeptCode VARCHAR(20),
										PublishEmpID VARCHAR(20),
										OccurProcessCode VARCHAR(3),
										LotNo VARCHAR(20),
										ProdProcessResultCode VARCHAR(2),
										CorrectiveActionCode VARCHAR(2),
										CorrectiveActionName VARCHAR(50),
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										DefectLotSize INT,
										IsActionCode BIT,
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CauseInvestigation NVARCHAR(4000),
										PreventionRecurrence NVARCHAR(4000),
										DetectionCounterMeasures NVARCHAR(4000),
										CheckingCorrectiveAction NVARCHAR(4000),
										Validation NVARCHAR(4000),
										JobDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										ApprovalStepID INT,
										QcOpinionContent NVARCHAR(4000),
										ActionContent NVARCHAR(4000)
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
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					ProdProcessResultCode = ISNULL(SourceTable.ProdProcessResultCode,TargetTable.ProdProcessResultCode),
					CorrectiveActionCode = ISNULL(SourceTable.CorrectiveActionCode,TargetTable.CorrectiveActionCode),
					CorrectiveActionName = ISNULL(SourceTable.CorrectiveActionName,TargetTable.CorrectiveActionName),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2),
					DefectLotSize = ISNULL(SourceTable.DefectLotSize,TargetTable.DefectLotSize),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CauseInvestigation = ISNULL(SourceTable.CauseInvestigation,TargetTable.CauseInvestigation),
					PreventionRecurrence = ISNULL(SourceTable.PreventionRecurrence,TargetTable.PreventionRecurrence),
					DetectionCounterMeasures = ISNULL(SourceTable.DetectionCounterMeasures,TargetTable.DetectionCounterMeasures),
					CheckingCorrectiveAction = ISNULL(SourceTable.CheckingCorrectiveAction,TargetTable.CheckingCorrectiveAction),
					Validation = ISNULL(SourceTable.Validation,TargetTable.Validation),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ProdProcessResultFile = ISNULL(SourceTable.ProdProcessResultFile,TargetTable.ProdProcessResultFile),
					ApprovalStepID = ISNULL(SourceTable.ApprovalStepID,TargetTable.ApprovalStepID),
					QcOpinionContent = ISNULL(SourceTable.QcOpinionContent,TargetTable.QcOpinionContent),
					ActionContent = ISNULL(SourceTable.ActionContent,TargetTable.ActionContent)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectDivisionCode,
						PublishDeptCode,
						PublishEmpID,
						OccurProcessCode,
						LotNo,
						ProdProcessResultCode,
						CorrectiveActionCode,
						CorrectiveActionName,
						DefectImage,
						DefectImage2,
						DefectLotSize,
						IsActionCode,
						Nonconformity,
						ImmediateAction,
						CauseInvestigation,
						PreventionRecurrence,
						DetectionCounterMeasures,
						CheckingCorrectiveAction,
						Validation,
						JobDate,
						CreateDateTime,
						CreateUserID,
						ProdProcessResultFile,
						ApprovalStepID,
						QcOpinionContent,
						ActionContent
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectDivisionCode,
							SourceTable.PublishDeptCode,
							SourceTable.PublishEmpID,
							SourceTable.OccurProcessCode,
							SourceTable.LotNo,
							SourceTable.ProdProcessResultCode,
							SourceTable.CorrectiveActionCode,
							SourceTable.CorrectiveActionName,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.DefectLotSize,
							SourceTable.IsActionCode,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CauseInvestigation,
							SourceTable.PreventionRecurrence,
							SourceTable.DetectionCounterMeasures,
							SourceTable.CheckingCorrectiveAction,
							SourceTable.Validation,
							SourceTable.JobDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ProdProcessResultFile,
							SourceTable.ApprovalStepID,
							SourceTable.QcOpinionContent,
							SourceTable.ActionContent
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
									LotNo,
									ProdProcessResultCode,
									CorrectiveActionCode,
									CorrectiveActionName,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									DefectLotSize,
									IsActionCode,
									Nonconformity,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									JobDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID,
									QcOpinionContent,
									ActionContent
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 LotNo VARCHAR(20),
											 ProdProcessResultCode VARCHAR(2),
											 CorrectiveActionCode VARCHAR(2),
											 CorrectiveActionName VARCHAR(50),
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 DefectLotSize INT,
											 IsActionCode BIT,
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 JobDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT,
											 QcOpinionContent NVARCHAR(4000),
											 ActionContent NVARCHAR(4000)
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
									LotNo,
									ProdProcessResultCode,
									CorrectiveActionCode,
									CorrectiveActionName,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage,
									DefectLotSize,
									IsActionCode,
									Nonconformity,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									JobDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID,
									QcOpinionContent,
									ActionContent
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 LotNo VARCHAR(20),
											 ProdProcessResultCode VARCHAR(2),
											 CorrectiveActionCode VARCHAR(2),
											 CorrectiveActionName VARCHAR(50),
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 DefectLotSize INT,
											 IsActionCode BIT,
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 JobDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT,
											 QcOpinionContent NVARCHAR(4000),
											 ActionContent NVARCHAR(4000)
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
									LotNo,
									ProdProcessResultCode,
									CorrectiveActionCode,
									CorrectiveActionName,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									DefectLotSize,
									IsActionCode,
									Nonconformity,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									JobDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID,
									QcOpinionContent,
									ActionContent
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 LotNo VARCHAR(20),
											 ProdProcessResultCode VARCHAR(2),
											 CorrectiveActionCode VARCHAR(2),
											 CorrectiveActionName VARCHAR(50),
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 DefectLotSize INT,
											 IsActionCode BIT,
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 JobDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT,
											 QcOpinionContent  NVARCHAR(4000),
											 ActionContent NVARCHAR(4000)
											) 
            OPEN SourceData

            WHILE 1 = 1 
			
			BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectReportNo,
								 @DefectReportNo,
								 @DefectDivisionCode,
								 @PublishDeptCode,
								 @PublishEmpID,
								 @OccurProcessCode,
								 @LotNo,
								 @ProdProcessResultCode,
								 @CorrectiveActionCode,
								 @CorrectiveActionName,
								 @DefectImage,
								 @DefectImage2,
								 @DefectLotSize,
								 @IsActionCode,
								 @Nonconformity,
								 @ImmediateAction,
								 @CauseInvestigation,
								 @PreventionRecurrence,
								 @DetectionCounterMeasures,
								 @CheckingCorrectiveAction,
								 @Validation,
								 @JobDate,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ProdProcessResultFile,
								 @ApprovalStepID,
								 @QcOpinionContent,
								 @ActionContent


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
						    LotNo,
						    ProdProcessResultCode,
						    CorrectiveActionCode,
						    CorrectiveActionName,
						    DefectImage,
							DefectImage2,
						    DefectLotSize,
						    IsActionCode,
						    Nonconformity,
						    ImmediateAction,
						    CauseInvestigation,
						    PreventionRecurrence,
						    DetectionCounterMeasures,
						    CheckingCorrectiveAction,
						    Validation,
						    JobDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
						    ApprovalStepID,
							QcOpinionContent,
							ActionContent
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @OccurProcessCode,
						    @LotNo,
						    @ProdProcessResultCode,
						    @CorrectiveActionCode,
						    @CorrectiveActionName,
						    @DefectImage,
							@DefectImage2,
						    @DefectLotSize,
						    @IsActionCode,
						    @Nonconformity,
						    @ImmediateAction,
						    @CauseInvestigation,
						    @PreventionRecurrence,
						    @DetectionCounterMeasures,
						    @CheckingCorrectiveAction,
						    @Validation,
						    @JobDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
						    @ApprovalStepID,
							@QcOpinionContent,
							@ActionContent
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN


 ----------------- 이부분부터 START
						
					IF EXISTS (SELECT 1 FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo)      -- 보고서번호가 존재하면 UPDATE
					
					BEGIN

						UPDATE STB_IQcDefectReport            -- 테이블명 중요 (STB_IQcDefectReport)
						      SET
									DefectReportNo =   ISNULL(@DefectReportNo,DefectReportNo),
									DefectDivisionCode =   ISNULL(@DefectDivisionCode,DefectDivisionCode),
									PublishDeptCode =   ISNULL(@PublishDeptCode,PublishDeptCode),
									PublishEmpID =   ISNULL(@PublishEmpID,PublishEmpID),
									OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
									LotNo =   ISNULL(@LotNo,LotNo),
									ProdProcessResultCode =   ISNULL(@ProdProcessResultCode,ProdProcessResultCode),
									CorrectiveActionCode =   ISNULL(@CorrectiveActionCode,CorrectiveActionCode),
									CorrectiveActionName =   ISNULL(@CorrectiveActionName,CorrectiveActionName),
									DefectImage =   ISNULL(@DefectImage,DefectImage),
									DefectImage2 = ISNULL(@DefectImage2,DefectImage2),
									DefectLotSize =   ISNULL(@DefectLotSize,DefectLotSize),
									IsActionCode =   ISNULL(@IsActionCode,IsActionCode),
									Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
									ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
									CauseInvestigation =   ISNULL(@CauseInvestigation,CauseInvestigation),
									PreventionRecurrence =   ISNULL(@PreventionRecurrence,PreventionRecurrence),
									DetectionCounterMeasures =   ISNULL(@DetectionCounterMeasures,DetectionCounterMeasures),
									CheckingCorrectiveAction =   ISNULL(@CheckingCorrectiveAction,CheckingCorrectiveAction),
									Validation =   ISNULL(@Validation,Validation),
									JobDate =   ISNULL(@JobDate,JobDate),
									CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
									CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID,
									ProdProcessResultFile =   ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
									ApprovalStepID =   ISNULL(@ApprovalStepID,ApprovalStepID),
									QcOpinionContent = ISNULL(@QcOpinionContent,QcOpinionContent),
									ActionContent = ISNULL(@ActionContent,ActionContent)
						WHERE
						         DefectReportNo = @OldDefectReportNo
						
					END ELSE BEGIN -- 그렇지 않으면 Insert
						--신규의 경우 @DefectReportNo = '자동채번'이므로 일치하는 번호가 없음.
						--Dummy쿼리의 자동채번 로직을 삭제하고 이 곳에서 신규로 채번함.
						--2020.07.07 By Jackaroe
					
						
							IF @PublishDeptCode = '4000'    -- @DefectReportNo 채번 (본사)
								 BEGIN
									SELECT @DefectReportNo = 'VNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
									  FROM STB_IQcDefectReport
									 WHERE DefectReportNo LIKE 'VNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'									
								 END
						 											
							ELSE      -- 법인의 경우   --IF @PublishDeptCode = '9000' 							
								   BEGIN
										SELECT @DefectReportNo = 'VVNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
										  FROM STB_IQcDefectReport
										 WHERE DefectReportNo LIKE 'VVNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'
									 END
                      

                        INSERT INTO STB_IQcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						    OccurProcessCode,
						    LotNo,
						    ProdProcessResultCode,
						    CorrectiveActionCode,
						    CorrectiveActionName,
						    DefectImage,
							DefectImage2,
						    DefectLotSize,
						    IsActionCode,
						    Nonconformity,
						    ImmediateAction,
						    CauseInvestigation,
						    PreventionRecurrence,
						    DetectionCounterMeasures,
						    CheckingCorrectiveAction,
						    Validation,
						    JobDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
						    ApprovalStepID,
							QcOpinionContent,
							ActionContent
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @OccurProcessCode,
						    @LotNo,
						    @ProdProcessResultCode,
						    @CorrectiveActionCode,
						    @CorrectiveActionName,
						    @DefectImage,
							@DefectImage2,
						    @DefectLotSize,
						    @IsActionCode,
						    @Nonconformity,
						    @ImmediateAction,
						    @CauseInvestigation,
						    @PreventionRecurrence,
						    @DetectionCounterMeasures,
						    @CheckingCorrectiveAction,
						    @Validation,
						    @JobDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
						    @ApprovalStepID,
							@QcOpinionContent,
							@ActionContent
						)


		 -- 2.  STB_NCR_Report을 INSERT하다
		  INSERT INTO STB_NCR_Report 
							( NCRNO, JOBDATE, CompanyCode, OccurProcessCode, MaterialName, CustomName, StandardName, LotNo, Qty, InspectionQty, BadQty, PPM, InQty, BadLotQty
							, DefectiveRate, CreateUserID, Nonconformity, ImmediateAction, CustomImmediateAction, IsActionCode, EffectivenessCheck, DefectImage, DefectImage2 )
		
		-- 2020.12.12 수정
				   SELECT Top 1 @DefectReportNo                                                        --Top1
							, CONVERT(VARCHAR(10), SIQ.CreateDateTime, 121)   As JobDate			   
							, Case When @PublishDeptCode = '4000' Then '한국본사'
							         When @PublishDeptCode = '9000' Then '베트남' Else '' End As CompanyCode
							,  BC1.Description   As OccurProcessCode                  
							,  PG.ProductGroupCode  As MaterialName			                      -- 자재그룹명
							,  C.CustomerName         As  CustomName
							,  MM.MaterialName        As StandardName                      --품목명
							, SIQ.lotno As LotNo
							, MQI.QcQty As Qty                      --입고수
							, 0              As InspectionQty
							, MQI.DefectSampleQty As BadQty
							, Case when  MQI.ActualSampleQty =0 then 0 when MQI.DefectSampleQty = 0  then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) end as PPM 
							, MQI.QcQty As InQty
							, MQI.DefectSampleQty As BadLotQty
							--, Isnull((MQI.DefectSampleQty / MQI.QcQty * 100), 0.000) As DefectiveRate			
							, Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate   -- Lot불량율(%)    
							, MQI.CreateUserID         As CreateUserID
							,  SIQ.Nonconformity
							,  SIQ.ImmediateAction
							, '' as CustomImmediateAction
							, 0 As IsActionCode
							, '' as EffectivenessCheck
							,  SIQ.DefectImage
							,  SIQ.DefectImage2		
					FROM
							STB_MaterialQcInfo MQI WITH(NOLOCK)
							LEFT OUTER JOIN (
															SELECT DISTINCT MDD.MaterialDocNo as MaterialDocNo,
																				MDD.MaterialIqcNo as MaterialIqcNo ,
																				Count(MDLI.LotNo)	as LotNoQty            -- 2020-09-06 추가 	
															FROM
																					 STB_MaterialDocDetail MDD WITH(NOLOCK)
																	INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
																	INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
																	INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
															WHERE 1=1														
															Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            
													) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

							LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				ON MDI.MaterialDocNo = MDD.MaterialDocNo
							LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
							LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MQI.MaterialCode = MM.MaterialCode
							LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode  
							LEFT OUTER JOIN [SmartFramework].[dbo].[STB_UserInfo] PW WITH (NOLOCK)				ON PW.UserID = CASE WHEN ISNULL(MQI.DecisionUserID,'') = '' THEN @pProcessUserID ELSE MQI.DecisionUserID END
							LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MM.MaterialCode
							LEFT OUTER JOIN STB_IQcDefectReport SIQ WITH(NOLOCK)	ON SIQ.LotNo = MQI.IQCSampleLotList            
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	ON SIQ.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	ON SIQ.PublishDeptCode = BC2.ItemCode	       AND BC2.CodeGroup = 'PublishDeptCode'	         -- 부적합발행부서
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	ON SIQ.CorrectiveActionCode = BC3.ItemCode   AND BC3.CodeGroup = 'CorrectiveActionCode'
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	ON SIQ.ProdProcessResultCode = BC5.ItemCode AND BC5.CodeGroup = 'ProdProcessResultCode'  -- 생산부문처리결과코드
					WHERE	1=1	  
						AND DefectReportNo = @DefectReportNo

		 	 --최초 입력 후 겜바워크 그룹 메시지 발생
						 --본사 발행 부적합 보고서만 전파 2020.07.16 박진호 대리요청
						IF @PublishDeptCode = '4000' BEGIN
							Exec usp_DoSendLineMessageForDefectReport2 '', '', @DefectReportNo               -- LINE 메세지 (수입검사): usp_DoSendLineMessageForDefectReport2 뒤에 2가 붙음
						END

									 BEGIN TRY  						               									 
											 Exec usp_DoSendEmailForDefectReportIQC  @pProcessUserID, @pProcessLanguage, @DefectReportNo           -- 수입검사용 이메일발송 프로시저임 (kilee)										
											 --Exec usp_DoSendEmailForDefectReportIQC '','','VNI201022-01'
									END TRY  

									BEGIN CATCH  			
											Exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서(수입검사)  E-Mail 발송을 실패하였습니다. 관련 프로세스를 점검바랍니다 ' 
									END CATCH  

					END


--- DELETE 부분            
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