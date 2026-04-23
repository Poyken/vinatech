-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-06
-- Browsable : true
-- Group : 품질관리 > 고객불만현황 저장버튼
-- Description:	
-- Modified:
-- 2021.03.16  @DefectImage 이미지 추가 항목 (이미정)
-- 2021.03.18  대책서 삭제후 저장부분 처리 (이미정)

-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerComplaintsManagementInfo_iud]
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

    -- Declare Columns Variable
  DECLARE @OldCustomerComplaintsManagementNo VARCHAR(20)
  DECLARE @CustomerComplaintsManagementNo VARCHAR(20)
  DECLARE @ReceiptDate DATE
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @ProductSize VARCHAR(20)
  DECLARE @CustomerComplaintsDefectTypeCode VARCHAR(20)
  DECLARE @ProductionCompanyCode VARCHAR(20)
  DECLARE @CustomerComplaintsContents NVARCHAR(MAX)
  DECLARE @Barcode NVARCHAR(1000)
  DECLARE @MarkingLetter NVARCHAR(1000)
  DECLARE @DefectQty NUMERIC(10,2)
  DECLARE @ResponsibilityCompanyCode VARCHAR(20)
  DECLARE @CustomerComplaintsDefectCode VARCHAR(20)
  DECLARE @CauseContents NVARCHAR(MAX)
  DECLARE @ActionContents NVARCHAR(MAX)
  DECLARE @ActionDocSubmissionDate DATETIME
  DECLARE @ActionDocFileID BIGINT
  DECLARE @OldActionDocFileID BIGINT                          -- 추가사항 (이미정님, 2021-03-22)

  DECLARE @CreateDateTime DATE
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  --FileUpload 관련 변수 추가 
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)

  --유효성 검증 관련 변수 추가 
  DECLARE @IsValidation1 BIT
  DECLARE @IsValidation2 BIT
  DECLARE @IsValidation3 BIT

  DECLARE @ValidationDocContent1 NVARCHAR(MAX)
  DECLARE @ValidationDocContent2 NVARCHAR(MAX)
  DECLARE @ValidationDocContent3 NVARCHAR(MAX)

  DECLARE @msg NVARCHAR(100)

  --실적반영 필드 추가 품질 이미정 님 요청 2021.01.06 by Jackaroe
  DECLARE @IsPerformance BIT


  DECLARE @DefectImage VARBINARY(MAX)  -- 2021.03.16 추가

  -- 사업장, 작업장 코드 추가 2024.03.08 최동찬 매니저 요청 by Jackaroe
  Declare @CompanyCode VARCHAR(20)
  Declare @WorkCenterCode VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CustomerComplaintsManagementInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								OldCustomerComplaintsManagementNo,
								CustomerComplaintsManagementNo,
								ReceiptDate,
								CustomerCode,
								MaterialCode,
								ProductSize,
								CustomerComplaintsDefectTypeCode,
								ProductionCompanyCode,
								CustomerComplaintsContents,
								Barcode,
								MarkingLetter,
								DefectQty,
								ResponsibilityCompanyCode,
								CustomerComplaintsDefectCode,
								CauseContents,
								ActionContents,
								ActionDocSubmissionDate,
								ActionDocFileID,
								OldActionDocFileID,     --추가
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								[FileName],
								FileSize,
								dbo.fnBase64ToBinary(FileData),
							    IsPerformance,
								dbo.fnBase64ToBinary(DefectImage) as DefectImage,
								IsValidation1,
								IsValidation2,
								IsValidation3,
								ValidationDocContent1,
								ValidationDocContent2,
								ValidationDocContent3,
								CompanyCode,
								WorkCenterCode

						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
											OldCustomerComplaintsManagementNo VARCHAR(20),
											CustomerComplaintsManagementNo VARCHAR(20),
											ReceiptDate DATETIMEOFFSET,
											CustomerCode VARCHAR(20),
											MaterialCode VARCHAR(20),
											ProductSize VARCHAR(20),
											CustomerComplaintsDefectTypeCode VARCHAR(20),
											ProductionCompanyCode VARCHAR(20),
											CustomerComplaintsContents NVARCHAR(MAX),
											Barcode NVARCHAR(1000),
											MarkingLetter NVARCHAR(1000),
											DefectQty NUMERIC(10,2),
											ResponsibilityCompanyCode VARCHAR(20),
											CustomerComplaintsDefectCode VARCHAR(20),
											CauseContents NVARCHAR(MAX),
											ActionContents NVARCHAR(MAX),
											ActionDocSubmissionDate DATETIMEOFFSET,
											ActionDocFileID BIGINT,
											OldActionDocFileID BIGINT,               -- 추가
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											[FileName] NVARCHAR(255),
											FileSize BIGINT,
											FileData NVARCHAR(MAX),
											IsPerformance BIT,
											DefectImage NVARCHAR(MAX),
											IsValidation1 BIT,
											IsValidation2 BIT,
											IsValidation3 BIT,
											ValidationDocContent1 NVARCHAR(MAX),
											ValidationDocContent2 NVARCHAR(MAX),
											ValidationDocContent3 NVARCHAR(MAX),
											CompanyCode VARCHAR(20),
											WorkCenterCode VARCHAR(20)
										)
						UNION ALL

						-- UPDATE 
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldCustomerComplaintsManagementNo IS NULL THEN CustomerComplaintsManagementNo
									ELSE OldCustomerComplaintsManagementNo
								END AS OldCustomerComplaintsManagementNo,
								CustomerComplaintsManagementNo,
								ReceiptDate,
								CustomerCode,
								MaterialCode,
								ProductSize,
								CustomerComplaintsDefectTypeCode,
								ProductionCompanyCode,
								CustomerComplaintsContents,
								Barcode,
								MarkingLetter,
								DefectQty,
								ResponsibilityCompanyCode,
								CustomerComplaintsDefectCode,
								CauseContents,
								ActionContents,
								ActionDocSubmissionDate,
								ActionDocFileID,
								OldActionDocFileID,       --추가
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								[FileName],
								FileSize,
								dbo.fnBase64ToBinary(FileData),
								IsPerformance,
								dbo.fnBase64ToBinary(DefectImage) as DefectImage,
								IsValidation1,
								IsValidation2,
								IsValidation3,
								ValidationDocContent1,
								ValidationDocContent2,
								ValidationDocContent3,
								CompanyCode,
								WorkCenterCode
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldCustomerComplaintsManagementNo VARCHAR(20),
											CustomerComplaintsManagementNo VARCHAR(20),
											ReceiptDate DATETIMEOFFSET,
											CustomerCode VARCHAR(20),
											MaterialCode VARCHAR(20),
											ProductSize VARCHAR(20),
											CustomerComplaintsDefectTypeCode VARCHAR(20),
											ProductionCompanyCode VARCHAR(20),
											CustomerComplaintsContents NVARCHAR(MAX),
											Barcode NVARCHAR(1000),
											MarkingLetter NVARCHAR(1000),
											DefectQty NUMERIC(10,2),
											ResponsibilityCompanyCode VARCHAR(20),
											CustomerComplaintsDefectCode VARCHAR(20),
											CauseContents NVARCHAR(MAX),
											ActionContents NVARCHAR(MAX),
											ActionDocSubmissionDate DATETIMEOFFSET,
											ActionDocFileID BIGINT,
											OldActionDocFileID BIGINT,                  --추가
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											[FileName] NVARCHAR(255),
											FileSize BIGINT,
											FileData NVARCHAR(MAX),
											IsPerformance BIT,
											DefectImage NVARCHAR(MAX),
											IsValidation1 BIT,
											IsValidation2 BIT,
											IsValidation3 BIT,
											ValidationDocContent1 NVARCHAR(MAX),
											ValidationDocContent2 NVARCHAR(MAX),
											ValidationDocContent3 NVARCHAR(MAX),
											CompanyCode VARCHAR(20),
											WorkCenterCode VARCHAR(20)
										)
						UNION ALL


					
							 



						-- Delete
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN OldCustomerComplaintsManagementNo IS NULL THEN CustomerComplaintsManagementNo
									ELSE OldCustomerComplaintsManagementNo
								END AS OldCustomerComplaintsManagementNo,
								CustomerComplaintsManagementNo,
								ReceiptDate,
								CustomerCode,
								MaterialCode,
								ProductSize,
								CustomerComplaintsDefectTypeCode,
								ProductionCompanyCode,
								CustomerComplaintsContents,
								Barcode,
								MarkingLetter,
								DefectQty,
								ResponsibilityCompanyCode,
								CustomerComplaintsDefectCode,
								CauseContents,
								ActionContents,
								ActionDocSubmissionDate,
								ActionDocFileID,
								OldActionDocFileID,        --추가
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								[FileName],
								FileSize,
								dbo.fnBase64ToBinary(FileData),
								IsPerformance,
								dbo.fnBase64ToBinary(DefectImage) as DefectImage,
								IsValidation1,
								IsValidation2,
								IsValidation3,
								ValidationDocContent1,
								ValidationDocContent2,
								ValidationDocContent3,
								CompanyCode,
								WorkCenterCode
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
											OldCustomerComplaintsManagementNo VARCHAR(20),
											CustomerComplaintsManagementNo VARCHAR(20),
											ReceiptDate DATETIMEOFFSET,
											CustomerCode VARCHAR(20),
											MaterialCode VARCHAR(20),
											ProductSize VARCHAR(20),
											CustomerComplaintsDefectTypeCode VARCHAR(20),
											ProductionCompanyCode VARCHAR(20),
											CustomerComplaintsContents NVARCHAR(MAX),
											Barcode NVARCHAR(1000),
											MarkingLetter NVARCHAR(1000),
											DefectQty NUMERIC(10,2),
											ResponsibilityCompanyCode VARCHAR(20),
											CustomerComplaintsDefectCode VARCHAR(20),
											CauseContents NVARCHAR(MAX),
											ActionContents NVARCHAR(MAX),
											ActionDocSubmissionDate DATETIMEOFFSET,
											ActionDocFileID BIGINT,
											OldActionDocFileID BIGINT,                                    --추가
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											[FileName] NVARCHAR(255),
											FileSize BIGINT,
											FileData NVARCHAR(MAX),
											IsPerformance BIT,
											DefectImage NVARCHAR(MAX),
											IsValidation1 BIT,
											IsValidation2 BIT,
											IsValidation3 BIT,
											ValidationDocContent1 NVARCHAR(MAX),
											ValidationDocContent2 NVARCHAR(MAX),
											ValidationDocContent3 NVARCHAR(MAX),
											CompanyCode VARCHAR(20),
											WorkCenterCode VARCHAR(20)
										) 


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldCustomerComplaintsManagementNo,
								@CustomerComplaintsManagementNo,
								@ReceiptDate,
								@CustomerCode,
								@MaterialCode,
								@ProductSize,
								@CustomerComplaintsDefectTypeCode,
								@ProductionCompanyCode,
								@CustomerComplaintsContents,
								@Barcode,
								@MarkingLetter,
								@DefectQty,
								@ResponsibilityCompanyCode,
								@CustomerComplaintsDefectCode,
								@CauseContents,
								@ActionContents,
								@ActionDocSubmissionDate,
								@ActionDocFileID,
								@OldActionDocFileID , ---추가
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@FileName,
								@FileSize,
								@FileData,
								@IsPerformance,
								@DefectImage,
								@IsValidation1,
								@IsValidation2,
								@IsValidation3,
								@ValidationDocContent1,
								@ValidationDocContent2,
								@ValidationDocContent3,
								@CompanyCode,
								@WorkCenterCode


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END


            IF @IUD_FLAG = 'INSERT'
			
			 BEGIN
						IF EXISTS (SELECT 1 FROM STB_CustomerComplaintsManagementInfo WHERE CustomerComplaintsManagementNo = @CustomerComplaintsManagementNo) BEGIN
							RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CustomerComplaintsManagementNo)
				END

                --EXEC usp_DoCreateSerial 'STB_CustomerComplaintsManagementInfo',@CustomerComplaintsManagementNo OUTPUT
				--자체관리룰 대로 생성함.
				--VJQA04SC22-040
				--이후 사업장별로 별도의 기준이 생길 수 있음.
				IF @CompanyCode = 'VNT' BEGIN
					IF @WorkCenterCode = 'VNT_F2' BEGIN
						SELECT @CustomerComplaintsManagementNo = 'VJQA04FC22-' + RIGHT('00' + CONVERT(VARCHAR, CONVERT(INT, RIGHT(ISNULL(MAX(CustomerComplaintsManagementNo), 'VJQA04FC22-000'), 3)) + 1), 3)
							FROM STB_CustomerComplaintsManagementInfo
						WHERE CompanyCode = @CompanyCode
						   AND WorkCenterCode = @WorkCenterCode
					END ELSE IF @WorkCenterCode = 'VNT_F3'  BEGIN
						SELECT @CustomerComplaintsManagementNo = 'VJQA04PS22-' + RIGHT('00' + CONVERT(VARCHAR, CONVERT(INT, RIGHT(ISNULL(MAX(CustomerComplaintsManagementNo), 'VJQA04PS22-000'), 3)) + 1), 3)
							FROM STB_CustomerComplaintsManagementInfo
						WHERE CompanyCode = @CompanyCode
						   AND WorkCenterCode = @WorkCenterCode
					END ELSE BEGIN
						SELECT @CustomerComplaintsManagementNo = 'VJQA04SC22-' + RIGHT('00' + CONVERT(VARCHAR, CONVERT(INT, RIGHT(ISNULL(MAX(CustomerComplaintsManagementNo), 'VJQA04SC22-039'), 3)) + 1), 3)
							FROM STB_CustomerComplaintsManagementInfo
						 WHERE CompanyCode = @CompanyCode
						   AND WorkCenterCode = @WorkCenterCode
					END
				END ELSE BEGIN
					SELECT @CustomerComplaintsManagementNo = 'VVQA04PS22-' + RIGHT('00' + CONVERT(VARCHAR, CONVERT(INT, RIGHT(ISNULL(MAX(CustomerComplaintsManagementNo), 'VVQA04PS22-000'), 3)) + 1), 3)
					  FROM STB_CustomerComplaintsManagementInfo
				     WHERE CompanyCode = @CompanyCode
					   AND WorkCenterCode = @WorkCenterCode
				END

				-- 파일업로드
				EXEC SmartFramework.dbo.usp_DoSaveFile 
						@pSystemName = 'STB_CustomerComplaintsManagementInfo',
						@pFileContents = @FileData,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @ProcessUserID,
						@pFileID = @ActionDocFileID OUTPUT

                INSERT INTO STB_CustomerComplaintsManagementInfo
					(
						CustomerComplaintsManagementNo,
						ReceiptDate,
						CustomerCode,
						MaterialCode,
						ProductSize,
						CustomerComplaintsDefectTypeCode,
						ProductionCompanyCode,
						CustomerComplaintsContents,
						Barcode,
						MarkingLetter,
						DefectQty,
						ResponsibilityCompanyCode,
						CustomerComplaintsDefectCode,
						CauseContents,
						ActionContents,
						ActionDocSubmissionDate,
						ActionDocFileID,
						--OldActionDocFileID , ---추가
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID,
						IsPerformance,
						DefectImage,
						IsValidation1,
						IsValidation2,
						IsValidation3,
						ValidationDocContent1,
						ValidationDocContent2,
						ValidationDocContent3,
						CompanyCode,
						WorkCenterCode
					)
					VALUES
					(
						@CustomerComplaintsManagementNo,
						@ReceiptDate,
						@CustomerCode,
						@MaterialCode,
						@ProductSize,
						@CustomerComplaintsDefectTypeCode,
						@ProductionCompanyCode,
						@CustomerComplaintsContents,
						@Barcode,
						@MarkingLetter,
						@DefectQty,
						@ResponsibilityCompanyCode,
						@CustomerComplaintsDefectCode,
						@CauseContents,
						@ActionContents,
						@ActionDocSubmissionDate,
						@ActionDocFileID,
						--@OldActionDocFileID,           --추가
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID,
						@IsPerformance,
						@DefectImage,
						@IsValidation1,
						@IsValidation2,
						@IsValidation3,
						@ValidationDocContent1,
						@ValidationDocContent2,
						@ValidationDocContent3,
						@CompanyCode,
						@WorkCenterCode
					)

			-- [UPDATE]
			END ELSE IF @IUD_FLAG = 'UPDATE' 
			
			BEGIN
				-- 파일업로드

					----- UPDATE 추가사항 (2021.03.18)
				IF @ActionDocFileID is NULL 
				BEGIN 	
					EXEC SmartFramework.dbo.usp_DoSaveFile 
					@pSystemName = 'STB_CustomerComplaintsManagementInfo',
					@pFileContents = @FileData,
					@pFileName = NULL,
					@pFileSize = @FileSize,
					@pUserID = @ProcessUserID,
					@pFileID = @OldActionDocFileID OUTPUT
				END 

				EXEC SmartFramework.dbo.usp_DoSaveFile 
						@pSystemName = 'STB_CustomerComplaintsManagementInfo',
						@pFileContents = @FileData,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @ProcessUserID,
						@pFileID = @ActionDocFileID OUTPUT

                UPDATE STB_CustomerComplaintsManagementInfo
					SET
						CustomerComplaintsManagementNo =   ISNULL(@CustomerComplaintsManagementNo,CustomerComplaintsManagementNo),
						ReceiptDate =   ISNULL(@ReceiptDate,ReceiptDate),
						CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
						MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						ProductSize =   ISNULL(@ProductSize,ProductSize),
						CustomerComplaintsDefectTypeCode =   ISNULL(@CustomerComplaintsDefectTypeCode,CustomerComplaintsDefectTypeCode),
						ProductionCompanyCode =   ISNULL(@ProductionCompanyCode,ProductionCompanyCode),
						CustomerComplaintsContents =   ISNULL(@CustomerComplaintsContents,CustomerComplaintsContents),
						Barcode =   ISNULL(@Barcode,Barcode),
						MarkingLetter =   ISNULL(@MarkingLetter,MarkingLetter),
						DefectQty =   ISNULL(@DefectQty,DefectQty),
						ResponsibilityCompanyCode =   ISNULL(@ResponsibilityCompanyCode,ResponsibilityCompanyCode),
						CustomerComplaintsDefectCode =   ISNULL(@CustomerComplaintsDefectCode,CustomerComplaintsDefectCode),
						CauseContents =   ISNULL(@CauseContents,CauseContents),
						ActionContents =   ISNULL(@ActionContents,ActionContents),
						ActionDocSubmissionDate =   ISNULL(@ActionDocSubmissionDate,ActionDocSubmissionDate),
						ActionDocFileID =   ISNULL(@ActionDocFileID,ActionDocFileID),                                                   -- 추가부분

						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID,
						IsPerformance = ISNULL(@IsPerformance,IsPerformance),
						DefectImage =   ISNULL(@DefectImage,DefectImage),                         --추가부분
						IsValidation1 = ISNULL(@IsValidation1,IsValidation1),
						IsValidation2 = ISNULL(@IsValidation2,IsValidation2),
						IsValidation3 = ISNULL(@IsValidation3,IsValidation3),
						ValidationDocContent1 = ISNULL(@ValidationDocContent1,ValidationDocContent1),
						ValidationDocContent2 = ISNULL(@ValidationDocContent2,ValidationDocContent2),
						ValidationDocContent3 = ISNULL(@ValidationDocContent3,ValidationDocContent3),
						CompanyCode = ISNULL(@CompanyCode,CompanyCode),
						WorkCenterCode = ISNULL(@WorkCenterCode,WorkCenterCode)

					WHERE
						CustomerComplaintsManagementNo = @OldCustomerComplaintsManagementNo

					
            END ELSE IF @IUD_FLAG = 'DELETE' 
			
			BEGIN
                DELETE FROM STB_CustomerComplaintsManagementInfo
					WHERE
						CustomerComplaintsManagementNo = @OldCustomerComplaintsManagementNo
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