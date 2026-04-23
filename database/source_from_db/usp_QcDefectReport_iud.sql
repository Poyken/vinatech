
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-05-27
-- Browsable : true
-- Group : 품질관리 > 부적합등록 (원본)
-- Description:	

-- Modified: 
-- 2020.11.11 
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReport_iud]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = null,
						@pQcDefectClassCode VARCHAR(10) = '01'
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
  DECLARE @ReceiveDeptCode VARCHAR(20)
  DECLARE @OccurProcessCode VARCHAR(10)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @ProdWorkerCode VARCHAR(20)
  DECLARE @JobDate DATETIME
  DECLARE @LotNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @MaterialName VARCHAR(100)
  DECLARE @MaterialSpec VARCHAR(20)
  DECLARE @LotNo2 VARCHAR(20)
  DECLARE @LotNo3 VARCHAR(20)
  DECLARE @LotNo4 VARCHAR(20)
  DECLARE @LotNo5 VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectLotSize INT
  DECLARE @DefectErrorCnt INT
  DECLARE @DefectSampleCnt INT
  DECLARE @LotLimitCnt INT
  DECLARE @ActionContent NVARCHAR(2000)
  DECLARE @ActionWorkerCode VARCHAR(20)
  DECLARE @QcOpinionContent NVARCHAR(2000)
  DECLARE @IsCustomerSendRequired BIT
  DECLARE @ProdCauseContent NVARCHAR(2000)
  DECLARE @ProdCauseImage VARBINARY(MAX)
  DECLARE @ProdMeasuresContent NVARCHAR(2000)
  DECLARE @ProdProcessContent NVARCHAR(2000)
  DECLARE @ProdProcessResultCode VARCHAR(3)
  DECLARE @LossCost DECIMAL(10,2)
  DECLARE @ProdProcessContentAuthorUserName VARCHAR(100)
  DECLARE @ProdProcessContentCheckUserName VARCHAR(100)
  DECLARE @QcMeasuresContent NVARCHAR(2000)
  DECLARE @QcFlwupCheckContent NVARCHAR(2000)
  DECLARE @IsQcAsSatisfaction BIT
  DECLARE @IsProdHeadConfirm BIT
  DECLARE @ProdHeadComment NVARCHAR(4000)
  DECLARE @IsQcHeadConfirm BIT
  DECLARE @QcHeadComment NVARCHAR(4000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ProdProcessResultFile BIGINT
  DECLARE @MachineImage BIGINT
  DECLARE @NameVendor NVARCHAR(50)
  DECLARE @NameEmp NVARCHAR(50)

  Declare @QcDefectClassCode VARCHAR(10) = @pQcDefectClassCode


  --FileUpload 관련 변수 추가 
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)  
  DECLARE @iDoc INT

  --외관검사자코드 추가 2022.02.07 이미정 차장 요청 by Jackaroe
  Declare @VisualInspWorkerCode VARCHAR(20)

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QcDefectReport',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
		PRINT 'No Used Merge'
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
									ReceiveDeptCode,
									OccurProcessCode,
									MachineCode,
									ProdWorkerCode,
									JobDate,
									LotNo,
									MaterialCode,
									MaterialName,
									MaterialSpec,
									LotNo2,
									LotNo3,
									LotNo4,
									LotNo5,
									DefectCode,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									DefectLotSize,
									DefectErrorCnt,
									DefectSampleCnt,
									LotLimitCnt,
									ActionContent,
									ActionWorkerCode,
									QcOpinionContent,
									IsCustomerSendRequired,
									ProdCauseContent,
									dbo.fnBase64ToBinary(ProdCauseImage) as ProdCauseImage,
									ProdMeasuresContent,
									ProdProcessContent,
									ProdProcessResultCode,
									LossCost,
									ProdProcessContentAuthorUserName,
									ProdProcessContentCheckUserName,
									QcMeasuresContent,
									QcFlwupCheckContent,
									IsQcAsSatisfaction,
									IsProdHeadConfirm,
									ProdHeadComment,
									IsQcHeadConfirm,
									QcHeadComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData),
									NameVendor,
									NameEmp,
									VisualInspWorkerCode

							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 ReceiveDeptCode VARCHAR(20),
											 OccurProcessCode VARCHAR(10),
											 MachineCode VARCHAR(20),
											 ProdWorkerCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 LotNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 MaterialName VARCHAR(100),
											 MaterialSpec VARCHAR(20),
											 LotNo2 VARCHAR(20),
											 LotNo3 VARCHAR(20),
											 LotNo4 VARCHAR(20),
											 LotNo5 VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectImage NVARCHAR(MAX),
											 DefectLotSize INT,
											 DefectErrorCnt INT,
											 DefectSampleCnt INT,
											 LotLimitCnt INT,
											 ActionContent NVARCHAR(2000),
											 ActionWorkerCode VARCHAR(20),
											 QcOpinionContent NVARCHAR(2000),
											 IsCustomerSendRequired BIT,
											 ProdCauseContent NVARCHAR(2000),
											 ProdCauseImage NVARCHAR(MAX),
											 ProdMeasuresContent NVARCHAR(2000),
											 ProdProcessContent NVARCHAR(2000),
											 ProdProcessResultCode VARCHAR(3),
											 LossCost DECIMAL(10,2),
											 ProdProcessContentAuthorUserName VARCHAR(100),
											 ProdProcessContentCheckUserName VARCHAR(100),
											 QcMeasuresContent NVARCHAR(2000),
											 QcFlwupCheckContent NVARCHAR(2000),
											 IsQcAsSatisfaction BIT,
											 IsProdHeadConfirm BIT,
											 ProdHeadComment NVARCHAR(4000),
											 IsQcHeadConfirm BIT,
											 QcHeadComment NVARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 NameVendor NVARCHAR(50),
											 NameEmp NVARCHAR(50),
											 VisualInspWorkerCode VARCHAR(20)
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
									ReceiveDeptCode,
									OccurProcessCode,
									MachineCode,
									ProdWorkerCode,
									JobDate,
									LotNo,
									MaterialCode,
									MaterialName,
									MaterialSpec,
									LotNo2,
									LotNo3,
									LotNo4,
									LotNo5,
									DefectCode,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									DefectLotSize,
									DefectErrorCnt,
									DefectSampleCnt,
									LotLimitCnt,
									ActionContent,
									ActionWorkerCode,
									QcOpinionContent,
									IsCustomerSendRequired,
									ProdCauseContent,
									dbo.fnBase64ToBinary(ProdCauseImage) as ProdCauseImage,
									ProdMeasuresContent,
									ProdProcessContent,
									ProdProcessResultCode,
									LossCost,
									ProdProcessContentAuthorUserName,
									ProdProcessContentCheckUserName,
									QcMeasuresContent,
									QcFlwupCheckContent,
									IsQcAsSatisfaction,
									IsProdHeadConfirm,
									ProdHeadComment,
									IsQcHeadConfirm,
									QcHeadComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData),
									NameVendor,
									NameEmp,
									VisualInspWorkerCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 ReceiveDeptCode VARCHAR(20),
											 OccurProcessCode VARCHAR(10),
											 MachineCode VARCHAR(20),
											 ProdWorkerCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 LotNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 MaterialName VARCHAR(100),
											 MaterialSpec VARCHAR(20),
											 LotNo2 VARCHAR(20),
											 LotNo3 VARCHAR(20),
											 LotNo4 VARCHAR(20),
											 LotNo5 VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectImage NVARCHAR(MAX),
											 DefectLotSize INT,
											 DefectErrorCnt INT,
											 DefectSampleCnt INT,
											 LotLimitCnt INT,
											 ActionContent NVARCHAR(2000),
											 ActionWorkerCode VARCHAR(20),
											 QcOpinionContent NVARCHAR(2000),
											 IsCustomerSendRequired BIT,
											 ProdCauseContent NVARCHAR(2000),
											 ProdCauseImage NVARCHAR(MAX),
											 ProdMeasuresContent NVARCHAR(2000),
											 ProdProcessContent NVARCHAR(2000),
											 ProdProcessResultCode VARCHAR(3),
											 LossCost DECIMAL(10,2),
											 ProdProcessContentAuthorUserName VARCHAR(100),
											 ProdProcessContentCheckUserName VARCHAR(100),
											 QcMeasuresContent NVARCHAR(2000),
											 QcFlwupCheckContent NVARCHAR(2000),
											 IsQcAsSatisfaction BIT,
											 IsProdHeadConfirm BIT,
											 ProdHeadComment NVARCHAR(4000),
											 IsQcHeadConfirm BIT,
											 QcHeadComment NVARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 NameVendor NVARCHAR(50),
											 NameEmp NVARCHAR(50),
											 VisualInspWorkerCode VARCHAR(20)
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
									ReceiveDeptCode,
									OccurProcessCode,
									MachineCode,
									ProdWorkerCode,
									JobDate,
									LotNo,
									MaterialCode,
									MaterialName,
									MaterialSpec,
									LotNo2,
									LotNo3,
									LotNo4,
									LotNo5,
									DefectCode,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									DefectLotSize,
									DefectErrorCnt,
									DefectSampleCnt,
									LotLimitCnt,
									ActionContent,
									ActionWorkerCode,
									QcOpinionContent,
									IsCustomerSendRequired,
									ProdCauseContent,
									dbo.fnBase64ToBinary(ProdCauseImage) as ProdCauseImage,
									ProdMeasuresContent,
									ProdProcessContent,
									ProdProcessResultCode,
									LossCost,
									ProdProcessContentAuthorUserName,
									ProdProcessContentCheckUserName,
									QcMeasuresContent,
									QcFlwupCheckContent,
									IsQcAsSatisfaction,
									IsProdHeadConfirm,
									ProdHeadComment,
									IsQcHeadConfirm,
									QcHeadComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData),
									NameVendor,
									NameEmp,
									VisualInspWorkerCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 ReceiveDeptCode VARCHAR(20),
											 OccurProcessCode VARCHAR(10),
											 MachineCode VARCHAR(20),
											 ProdWorkerCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 LotNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 MaterialName VARCHAR(100),
											 MaterialSpec VARCHAR(20),
											 LotNo2 VARCHAR(20),
											 LotNo3 VARCHAR(20),
											 LotNo4 VARCHAR(20),
											 LotNo5 VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectImage NVARCHAR(MAX),
											 DefectLotSize INT,
											 DefectErrorCnt INT,
											 DefectSampleCnt INT,
											 LotLimitCnt INT,
											 ActionContent NVARCHAR(2000),
											 ActionWorkerCode VARCHAR(20),
											 QcOpinionContent NVARCHAR(2000),
											 IsCustomerSendRequired BIT,
											 ProdCauseContent NVARCHAR(2000),
											 ProdCauseImage NVARCHAR(MAX),
											 ProdMeasuresContent NVARCHAR(2000),
											 ProdProcessContent NVARCHAR(2000),
											 ProdProcessResultCode VARCHAR(3),
											 LossCost DECIMAL(10,2),
											 ProdProcessContentAuthorUserName VARCHAR(100),
											 ProdProcessContentCheckUserName VARCHAR(100),
											 QcMeasuresContent NVARCHAR(2000),
											 QcFlwupCheckContent NVARCHAR(2000),
											 IsQcAsSatisfaction BIT,
											 IsProdHeadConfirm BIT,
											 ProdHeadComment NVARCHAR(4000),
											 IsQcHeadConfirm BIT,
											 QcHeadComment NVARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 NameVendor NVARCHAR(50),
											 NameEmp NVARCHAR(50),
											 VisualInspWorkerCode VARCHAR(20)
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
								 @ReceiveDeptCode,
								 @OccurProcessCode,
								 @MachineCode,
								 @ProdWorkerCode,
								 @JobDate,
								 @LotNo,
								 @MaterialCode,
								 @MaterialName,
								 @MaterialSpec,
								 @LotNo2,
								 @LotNo3,
								 @LotNo4,
								 @LotNo5,
								 @DefectCode,
								 @DefectImage,
								 @DefectLotSize,
								 @DefectErrorCnt,
								 @DefectSampleCnt,
								 @LotLimitCnt,
								 @ActionContent,
								 @ActionWorkerCode,
								 @QcOpinionContent,
								 @IsCustomerSendRequired,
								 @ProdCauseContent,
								 @ProdCauseImage,
								 @ProdMeasuresContent,
								 @ProdProcessContent,
								 @ProdProcessResultCode,
								 @LossCost,
								 @ProdProcessContentAuthorUserName,
								 @ProdProcessContentCheckUserName,
								 @QcMeasuresContent,
								 @QcFlwupCheckContent,
								 @IsQcAsSatisfaction,
								 @IsProdHeadConfirm,
								 @ProdHeadComment,
								 @IsQcHeadConfirm,
								 @QcHeadComment,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ProdProcessResultFile,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @NameVendor,
								 @NameEmp,
								 @VisualInspWorkerCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				-- 문서를 생성한 사람의 사업장과 문서를 수정하려는 사람의 사업장이 다르면 수정할 수 없다
				-- 2020.07.07 By Jackaroe
				Declare @BefCompanyCode VARCHAR(20)
				       ,@AftCompanyCode VARCHAR(20)

				SELECT @BefCompanyCode = CompanyCode
				  FROM STB_UserInfo
				 WHERE UserID = @CreateUserID


				SELECT @AftCompanyCode = CompanyCode
				  FROM STB_UserInfo
				 WHERE UserID = @pProcessUserID

				--IF @BefCompanyCode <> @AftCompanyCode BEGIN
				--	EXEC usp_RaiseLocalizedError @pProcessLanguage, '문서 등록자와 수정자의 사업장 정보가 일치하지 않습니다.'
				--	RETURN
				--END

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QcDefectReport WHERE DefectReportNo = @DefectReportNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectReportNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						IF @QcDefectClassCode = '01' BEGIN -- 부적합
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport',@DefectReportNo OUTPUT
							SET @DefectReportNo = 'VN' + @DefectReportNo
						END ELSE BEGIN  -- 공정이상품
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport2',@DefectReportNo OUTPUT
							SET @DefectReportNo = 'VPN' + @DefectReportNo
						END
                        
						--부적합보고서 번호는 VN을 추가한다. 
						--부적합 유형별로 머리글이 달랐으나 VN으로 통일함
                        --SET @DefectReportNo = 'VN' + @DefectReportNo
                    END

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_QcDefectReport',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT

                    INSERT INTO STB_QcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						    ReceiveDeptCode,
						    OccurProcessCode,
						    MachineCode,
						    ProdWorkerCode,
						    JobDate,
						    LotNo,
						    MaterialCode,
						    MaterialName,
						    MaterialSpec,
						    LotNo2,
						    LotNo3,
						    LotNo4,
						    LotNo5,
						    DefectCode,
						    DefectImage,
						    DefectLotSize,
						    DefectErrorCnt,
						    DefectSampleCnt,
						    LotLimitCnt,
						    ActionContent,
						    ActionWorkerCode,
						    QcOpinionContent,
						    IsCustomerSendRequired,
						    ProdCauseContent,
						    ProdCauseImage,
						    ProdMeasuresContent,
						    ProdProcessContent,
						    ProdProcessResultCode,
						    LossCost,
						    ProdProcessContentAuthorUserName,
						    ProdProcessContentCheckUserName,
						    QcMeasuresContent,
						    QcFlwupCheckContent,
						    IsQcAsSatisfaction,
						    IsProdHeadConfirm,
						    ProdHeadComment,
						    IsQcHeadConfirm,
						    QcHeadComment,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
							NameVendor,
							NameEmp,
							VisualInspWorkerCode,
							QcDefectClassCode
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @ReceiveDeptCode,
						    @OccurProcessCode,
						    @MachineCode,
						    @ProdWorkerCode,
						    @JobDate,
						    @LotNo,
						    @MaterialCode,
						    @MaterialName,
						    @MaterialSpec,
						    @LotNo2,
						    @LotNo3,
						    @LotNo4,
						    @LotNo5,
						    @DefectCode,
						    @DefectImage,
						    @DefectLotSize,
						    @DefectErrorCnt,
						    @DefectSampleCnt,
						    @LotLimitCnt,
						    @ActionContent,
						    @ActionWorkerCode,
						    @QcOpinionContent,
						    @IsCustomerSendRequired,
						    @ProdCauseContent,
						    @ProdCauseImage,
						    @ProdMeasuresContent,
						    @ProdProcessContent,
						    @ProdProcessResultCode,
						    @LossCost,
						    @ProdProcessContentAuthorUserName,
						    @ProdProcessContentCheckUserName,
						    @QcMeasuresContent,
						    @QcFlwupCheckContent,
						    @IsQcAsSatisfaction,
						    @IsProdHeadConfirm,
						    @ProdHeadComment,
						    @IsQcHeadConfirm,
						    @QcHeadComment,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
							@NameVendor,
							@NameEmp,
							@VisualInspWorkerCode,
							@QcDefectClassCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					-- 일단 파일업로드 처리하고...

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_QcDefectReport',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT

					-- 보고서번호가 존재하면 UPDATE
					IF EXISTS (SELECT 1 FROM STB_QcDefectReport WHERE DefectReportNo = @DefectReportNo) BEGIN

						UPDATE STB_QcDefectReport
						SET
						    DefectReportNo =   ISNULL(@DefectReportNo,DefectReportNo),
						    DefectDivisionCode =   ISNULL(@DefectDivisionCode,DefectDivisionCode),
						    PublishDeptCode =   ISNULL(@PublishDeptCode,PublishDeptCode),
						    PublishEmpID =   ISNULL(@PublishEmpID,PublishEmpID),
						    ReceiveDeptCode =   ISNULL(@ReceiveDeptCode,ReceiveDeptCode),
						    OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    ProdWorkerCode =   ISNULL(@ProdWorkerCode,ProdWorkerCode),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    MaterialSpec =   ISNULL(@MaterialSpec,MaterialSpec),
						    LotNo2 =   ISNULL(@LotNo2,LotNo2),
						    LotNo3 =   ISNULL(@LotNo3,LotNo3),
						    LotNo4 =   ISNULL(@LotNo4,LotNo4),
						    LotNo5 =   ISNULL(@LotNo5,LotNo5),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    DefectImage =   ISNULL(@DefectImage,DefectImage),
						    DefectLotSize =   ISNULL(@DefectLotSize,DefectLotSize),
						    DefectErrorCnt =   ISNULL(@DefectErrorCnt,DefectErrorCnt),
						    DefectSampleCnt =   ISNULL(@DefectSampleCnt,DefectSampleCnt),
						    LotLimitCnt =   ISNULL(@LotLimitCnt,LotLimitCnt),
						    ActionContent =   ISNULL(@ActionContent,ActionContent),
						    ActionWorkerCode =   ISNULL(@ActionWorkerCode,ActionWorkerCode),
						    QcOpinionContent =   ISNULL(@QcOpinionContent,QcOpinionContent),
						    IsCustomerSendRequired =   ISNULL(@IsCustomerSendRequired,IsCustomerSendRequired),
						    ProdCauseContent =   ISNULL(@ProdCauseContent,ProdCauseContent),
						    ProdCauseImage =   ISNULL(@ProdCauseImage,ProdCauseImage),
						    ProdMeasuresContent =   ISNULL(@ProdMeasuresContent,ProdMeasuresContent),
						    ProdProcessContent =   ISNULL(@ProdProcessContent,ProdProcessContent),
						    ProdProcessResultCode =   ISNULL(@ProdProcessResultCode,ProdProcessResultCode),
						    LossCost =   ISNULL(@LossCost,LossCost),
						    ProdProcessContentAuthorUserName =   ISNULL(@ProdProcessContentAuthorUserName,ProdProcessContentAuthorUserName),
						    ProdProcessContentCheckUserName =   ISNULL(@ProdProcessContentCheckUserName,ProdProcessContentCheckUserName),
						    QcMeasuresContent =   ISNULL(@QcMeasuresContent,QcMeasuresContent),
						    QcFlwupCheckContent =   ISNULL(@QcFlwupCheckContent,QcFlwupCheckContent),
						    IsQcAsSatisfaction =   ISNULL(@IsQcAsSatisfaction,IsQcAsSatisfaction),
						    IsProdHeadConfirm =   ISNULL(@IsProdHeadConfirm,IsProdHeadConfirm),
						    ProdHeadComment =   ISNULL(@ProdHeadComment,ProdHeadComment),
						    IsQcHeadConfirm =   ISNULL(@IsQcHeadConfirm,IsQcHeadConfirm),
						    QcHeadComment =   ISNULL(@QcHeadComment,QcHeadComment),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    ProdProcessResultFile =   ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
							NameVendor = @NameVendor,
							NameEmp = @NameEmp,
							VisualInspWorkerCode = @VisualInspWorkerCode,
							QcDefectClassCode = @QcDefectClassCode
						WHERE
						    DefectReportNo = @OldDefectReportNo

						-- 변경된 데이터를 VECS_QC_RPT 테이블에 반영한다. 생산출력용
						-- Turbo ERP 서버 사고 이후 데이터베이스 소실로 동기화 중지 2023.04-13
						--BEGIN TRY  
						--		 exec usp_DoSyncDefectReportData @OldDefectReportNo
						--END TRY  

						--BEGIN CATCH  
						--		exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서 데이터 동기화를 실패하였습니다. 관련 프로세스를 점검하시기 바랍니다'
						--END CATCH 

					END ELSE BEGIN -- 그렇지 않으면 Insert
						----신규의 경우 @DefectReportNo = '자동채번'이므로 일치하는 번호가 없음.
						----Dummy쿼리의 자동채번 로직을 삭제하고 이 곳에서 신규로 채번함.
						----2020.07.07 By Jackaroe

						---- @DefectReportNo 채번
						--SELECT @DefectReportNo = 'VN' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' 
						--							  + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
						--  FROM STB_QcDefectReport
						-- WHERE DefectReportNo LIKE 'VN' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'

						IF @IsAutoKey = 1 BEGIN
							IF @QcDefectClassCode = '01' BEGIN -- 부적합
								EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport',@DefectReportNo OUTPUT
								SET @DefectReportNo = 'VN' + @DefectReportNo
							END ELSE BEGIN  -- 공정이상품
								EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport2',@DefectReportNo OUTPUT
								SET @DefectReportNo = 'VPN' + @DefectReportNo
							END
                        
							--부적합보고서 번호는 VN을 추가한다. 
							--부적합 유형별로 머리글이 달랐으나 VN으로 통일함
							--SET @DefectReportNo = 'VN' + @DefectReportNo
						END

					-- 중복제거 (엄제식님 요청)
					 IF EXISTS (SELECT 1 FROM STB_QcDefectReport WHERE LotNo = @LotNo AND  DefectCode = @DefectCode  ) 
					 BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage, '동일한 Lot번호에 동일한 불량유형이 등록된 이력이 있습니다.'
						RETURN
					 END

						INSERT INTO STB_QcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						    ReceiveDeptCode,
						    OccurProcessCode,
						    MachineCode,
						    ProdWorkerCode,
						    JobDate,
						    LotNo,
						    MaterialCode,
						    MaterialName,
						    MaterialSpec,
						    LotNo2,
						    LotNo3,
						    LotNo4,
						    LotNo5,
						    DefectCode,
						    DefectImage,
						    DefectLotSize,
						    DefectErrorCnt,
						    DefectSampleCnt,
						    LotLimitCnt,
						    ActionContent,
						    ActionWorkerCode,
						    QcOpinionContent,
						    IsCustomerSendRequired,
						    ProdCauseContent,
						    ProdCauseImage,
						    ProdMeasuresContent,
						    ProdProcessContent,
						    ProdProcessResultCode,
						    LossCost,
						    ProdProcessContentAuthorUserName,
						    ProdProcessContentCheckUserName,
						    QcMeasuresContent,
						    QcFlwupCheckContent,
						    IsQcAsSatisfaction,
						    IsProdHeadConfirm,
						    ProdHeadComment,
						    IsQcHeadConfirm,
						    QcHeadComment,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
							NameVendor,
							NameEmp,
							VisualInspWorkerCode,
							QcDefectClassCode
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @ReceiveDeptCode,
						    @OccurProcessCode,
						    @MachineCode,
						    @ProdWorkerCode,
						    @JobDate,
						    @LotNo,
						    @MaterialCode,
						    @MaterialName,
						    @MaterialSpec,
						    @LotNo2,
						    @LotNo3,
						    @LotNo4,
						    @LotNo5,
						    @DefectCode,
						    @DefectImage,
						    @DefectLotSize,
						    @DefectErrorCnt,
						    @DefectSampleCnt,
						    @LotLimitCnt,
						    @ActionContent,
						    @ActionWorkerCode,
						    @QcOpinionContent,
						    @IsCustomerSendRequired,
						    @ProdCauseContent,
						    @ProdCauseImage,
						    @ProdMeasuresContent,
						    @ProdProcessContent,
						    @ProdProcessResultCode,
						    @LossCost,
						    @ProdProcessContentAuthorUserName,
						    @ProdProcessContentCheckUserName,
						    @QcMeasuresContent,
						    @QcFlwupCheckContent,
						    @IsQcAsSatisfaction,
						    @IsProdHeadConfirm,
						    @ProdHeadComment,
						    @IsQcHeadConfirm,
						    @QcHeadComment,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
							@NameVendor,
							@NameEmp,
							@VisualInspWorkerCode,
							@QcDefectClassCode
						)

						-- 입력된 데이터를 VECS_QC_RPT 테이블에 반영한다. 생산출력용
						--BEGIN TRY  
						--		 exec usp_DoSyncDefectReportData @DefectReportNo
						--END TRY  
						--BEGIN CATCH  
						--		exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서 데이터 동기화를 실패하였습니다. 관련 프로세스를 점검하시기 바랍니다'
						--END CATCH 

						-- 최초 입력 후 겜바워크 그룹 메시지 발생
						-- 본사 발행 부적합 보고서만 전파 2020.06.23 이미정 차장 요청. By Jackaroe
						IF @PublishDeptCode = '4000' BEGIN
							exec usp_DoSendLineMessageForDefectReport '', '', @DefectReportNo
						END

						-- 추가 이메일 발송 처리 : 수신처가 베트남 생산부문이 아니면 무조건 발송 2020.09.19 이미정차장 요청. By Jackaroe
						-- 수신처가 베트남 생산부문이어도 무조건 발송. 베트남 현지 스탭 추가 부분은 usp_DoSendEmailForDefectReport 에서 처리함.
						-- 2020.10.15 이미정차장 요청 By Jackaroe
						BEGIN TRY  
								exec usp_DoSendEmailForDefectReport @pProcessUserID, @pProcessLanguage, @DefectReportNo
						END TRY  
						BEGIN CATCH  
								exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서 이메일 발송을 실패하였습니다. 관련 프로세스를 점검하시기 바랍니다'
						END CATCH  
					END

                    
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_QcDefectReport
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
