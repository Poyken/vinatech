-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-24
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateQC4MChangeDataRecode_iud]
	-- Add the parameters for the stored procedure here
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
    DECLARE @QC4MNo VARCHAR(20)
    DECLARE @ApprovalType NVARCHAR(100)
    DECLARE @IssuingDepartment VARCHAR(10)
    DECLARE @ChangeType4M VARCHAR(50)
    DECLARE @Level NVARCHAR(50)
    DECLARE @Factory VARCHAR(10)
    DECLARE @Model VARCHAR(30)
    DECLARE @LineCode VARCHAR(20)
    DECLARE @RouteCode VARCHAR(20)
    DECLARE @LotNo1 VARCHAR(30)
    DECLARE @LotNo2 VARCHAR(30)
    DECLARE @LotNo3 VARCHAR(30)
    DECLARE @DetailedChangeCategories NVARCHAR(MAX)
    DECLARE @ReasonForChange NVARCHAR(MAX)
    DECLARE @ConditionsBefChange NVARCHAR(MAX)
    DECLARE @ConditionsAftChange NVARCHAR(MAX)
    DECLARE @QualityAssuranceContent NVARCHAR(MAX)
    DECLARE @ApprovalDate DATE
    DECLARE @EffectiveDate DATE
    DECLARE @Conclusion NVARCHAR(MAX)
    DECLARE @Inspector NVARCHAR(50)
    DECLARE @Change4MImage VARBINARY(MAX)
    DECLARE @Change4MImageUrl VARCHAR(500)
    DECLARE @ProdProcessResultFile BIGINT
    DECLARE @Status NVARCHAR(50)
    DECLARE @Note NVARCHAR(MAX)
    DECLARE @ConnectString VARCHAR(40)
    DECLARE @ShowData BIT
    DECLARE @CreateDateTime DATETIME
    DECLARE @CreateUserID VARCHAR(20)
    DECLARE @ChangeDateTime DATETIME
    DECLARE @ChangeUserID VARCHAR(20)


      --FileUpload 관련 변수 추가 
     DECLARE @FileName NVARCHAR(255)
     DECLARE @FileSize BIGINT
     DECLARE @FileData VARBINARY(MAX)  

      DECLARE @iDoc INT

  --외관검사자코드 추가 2022.02.07 이미정 차장 요청 by Jackaroe
  Declare @VisualInspWorkerCode VARCHAR(20)

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QC4MChangeDataRecord',
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
									QC4MNo,
									ApprovalType,
									IssuingDepartment,
									ChangeType4M,
									[Level],
									Factory,
									[Model],
									LineCode,
									RouteCode,
									LotNo1,
									LotNo2,
									LotNo3,
									DetailedChangeCategories,
									ReasonForChange,
									ConditionsBefChange,
									ConditionsAftChange,
									QualityAssuranceContent,
									ApprovalDate,
									EffectiveDate,
									Conclusion,
									Inspector,
									dbo.fnBase64ToBinary(Change4MImage) AS Change4MImage,
									Change4MImageUrl,
									--ProdProcessResultFile,
									[Status],
									Note,
									--ConnectString ,
									ShowData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData)

							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (

											QC4MNo VARCHAR(20),
											ApprovalType NVARCHAR(100),
											IssuingDepartment VARCHAR(10),
											ChangeType4M VARCHAR(50),
											[Level] NVARCHAR(50),
											Factory VARCHAR(10),
											[Model] VARCHAR(30),
											LineCode VARCHAR(20),
											RouteCode VARCHAR(20),
											LotNo1 VARCHAR(30),
											LotNo2 VARCHAR(30),
											LotNo3 VARCHAR(30),
											DetailedChangeCategories NVARCHAR(MAX),
											ReasonForChange NVARCHAR(MAX),
											ConditionsBefChange NVARCHAR(MAX),
											ConditionsAftChange NVARCHAR(MAX),
											QualityAssuranceContent NVARCHAR(MAX),
											ApprovalDate DATE,
											EffectiveDate DATE,
											Conclusion NVARCHAR(MAX),
											Inspector NVARCHAR(50),
											Change4MImage NVARCHAR(MAX),
											Change4MImageUrl VARCHAR(500),
											--ProdProcessResultFile BIGINT,
											[Status] NVARCHAR(50),
											Note NVARCHAR(MAX),
											--ConnectString VARCHAR(40),
											ShowData BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											ProdProcessResultFile BIGINT,
											[FileName] NVARCHAR(255),
											FileSize BIGINT,
											FileData NVARCHAR(MAX)
											)
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
									QC4MNo,
									ApprovalType,
									IssuingDepartment,
									ChangeType4M,
									[Level],
									Factory,
									[Model],
									LineCode,
									RouteCode,
									LotNo1,
									LotNo2,
									LotNo3,
									DetailedChangeCategories,
									ReasonForChange,
									ConditionsBefChange,
									ConditionsAftChange,
									QualityAssuranceContent,
									ApprovalDate,
									EffectiveDate,
									Conclusion,
									Inspector,
									dbo.fnBase64ToBinary(Change4MImage) AS Change4MImage,
									Change4MImageUrl,
									--ProdProcessResultFile,
									[Status],
									Note,
									--ConnectString ,
									ShowData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData)
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											QC4MNo VARCHAR(20),
											ApprovalType NVARCHAR(100),
											IssuingDepartment VARCHAR(10),
											ChangeType4M VARCHAR(50),
											[Level] NVARCHAR(50),
											Factory VARCHAR(10),
											[Model] VARCHAR(30),
											LineCode VARCHAR(20),
											RouteCode VARCHAR(20),
											LotNo1 VARCHAR(30),
											LotNo2 VARCHAR(30),
											LotNo3 VARCHAR(30),
											DetailedChangeCategories NVARCHAR(MAX),
											ReasonForChange NVARCHAR(MAX),
											ConditionsBefChange NVARCHAR(MAX),
											ConditionsAftChange NVARCHAR(MAX),
											QualityAssuranceContent NVARCHAR(MAX),
											ApprovalDate DATE,
											EffectiveDate DATE,
											Conclusion NVARCHAR(MAX),
											Inspector NVARCHAR(50),
											Change4MImage NVARCHAR(MAX),
											Change4MImageUrl VARCHAR(500),
											--ProdProcessResultFile BIGINT,
											[Status] NVARCHAR(50),
											Note NVARCHAR(MAX),
											--ConnectString VARCHAR(40),
											ShowData BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											ProdProcessResultFile BIGINT,
											[FileName] NVARCHAR(255),
											FileSize BIGINT,
											FileData NVARCHAR(MAX)
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									QC4MNo,
									ApprovalType,
									IssuingDepartment,
									ChangeType4M,
									[Level],
									Factory,
									[Model],
									LineCode,
									RouteCode,
									LotNo1,
									LotNo2,
									LotNo3,
									DetailedChangeCategories,
									ReasonForChange,
									ConditionsBefChange,
									ConditionsAftChange,
									QualityAssuranceContent,
									ApprovalDate,
									EffectiveDate,
									Conclusion,
									Inspector,
									dbo.fnBase64ToBinary(Change4MImage) AS Change4MImage,
									Change4MImageUrl,
									--ProdProcessResultFile,
									[Status],
									Note,
									--ConnectString ,
									ShowData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData)
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											QC4MNo VARCHAR(20),
											ApprovalType NVARCHAR(100),
											IssuingDepartment VARCHAR(10),
											ChangeType4M VARCHAR(50),
											[Level] NVARCHAR(50),
											Factory VARCHAR(10),
											[Model] VARCHAR(30),
											LineCode VARCHAR(20),
											RouteCode VARCHAR(20),
											LotNo1 VARCHAR(30),
											LotNo2 VARCHAR(30),
											LotNo3 VARCHAR(30),
											DetailedChangeCategories NVARCHAR(MAX),
											ReasonForChange NVARCHAR(MAX),
											ConditionsBefChange NVARCHAR(MAX),
											ConditionsAftChange NVARCHAR(MAX),
											QualityAssuranceContent NVARCHAR(MAX),
											ApprovalDate DATE,
											EffectiveDate DATE,
											Conclusion NVARCHAR(MAX),
											Inspector NVARCHAR(50),
											Change4MImage NVARCHAR(MAX),
											Change4MImageUrl VARCHAR(500),
											--ProdProcessResultFile BIGINT,
											[Status] NVARCHAR(50),
											Note NVARCHAR(MAX),
											--ConnectString VARCHAR(40),
											ShowData BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											ProdProcessResultFile BIGINT,
											[FileName] NVARCHAR(255),
											FileSize BIGINT,
											FileData NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@QC4MNo,
								@ApprovalType,
								@IssuingDepartment,
								@ChangeType4M,
								@Level,
								@Factory,
								@Model,
								@LineCode,
								@RouteCode,
								@LotNo1,
								@LotNo2,
								@LotNo3,
								@DetailedChangeCategories,
								@ReasonForChange,
								@ConditionsBefChange,
								@ConditionsAftChange,
								@QualityAssuranceContent,
								@ApprovalDate,
								@EffectiveDate,
								@Conclusion,
								@Inspector,
								@Change4MImage,
								@Change4MImageUrl,
								--@ProdProcessResultFile,
								@Status,
								@Note,
								--@ConnectString ,
								@ShowData,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@ProdProcessResultFile,
								@FileName,
								@FileSize,
								@FileData


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				-- 문서를 생성한 사람의 사업장과 문서를 수정하려는 사람의 사업장이 다르면 수정할 수 없다
				-- 2020.07.07 By Jackaroe
				--Declare @BefCompanyCode VARCHAR(20)
				--       ,@AftCompanyCode VARCHAR(20)

				--SELECT @BefCompanyCode = CompanyCode
				--  FROM STB_UserInfo
				-- WHERE UserID = @CreateUserID


				--SELECT @AftCompanyCode = CompanyCode
				--  FROM STB_UserInfo
				-- WHERE UserID = @pProcessUserID

				--IF @BefCompanyCode <> @AftCompanyCode BEGIN
				--	EXEC usp_RaiseLocalizedError @pProcessLanguage, '문서 등록자와 수정자의 사업장 정보가 일치하지 않습니다.'
				--	RETURN
				--END

                IF @IUD_FLAG = 'INSERT' 
					BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QC4MChangeDataRecord WHERE QC4MNo = @QC4MNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @QC4MNo)
					END

                    IF @IsAutoKey = 1 
						BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QC4MChangeDataRecord',@QC4MNo OUTPUT
							SET @QC4MNo = 'VN' + @QC4MNo
						END
                        
						--부적합보고서 번호는 VN을 추가한다. 
						--부적합 유형별로 머리글이 달랐으나 VN으로 통일함
                        --SET @DefectReportNo = 'VN' + @DefectReportNo
                   -- END

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_QC4MChangeDataRecord',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT

                    INSERT INTO STB_QC4MChangeDataRecord
						(
							QC4MNo,
							ApprovalType,
							IssuingDepartment,
							ChangeType4M,
							[Level],
							Factory,
							[Model],
							LineCode,
							RouteCode,
							LotNo1,
							LotNo2,
							LotNo3,
							DetailedChangeCategories,
							ReasonForChange,
							ConditionsBefChange,
							ConditionsAftChange,
							QualityAssuranceContent,
							ApprovalDate,
							EffectiveDate,
							Conclusion,
							Inspector,
							Change4MImage,
							Change4MImageUrl,
							ProdProcessResultFile,
							[Status],
							Note,
							ConnectString,
							ShowData,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
						    @QC4MNo,
							@ApprovalType,
							@IssuingDepartment,
							@ChangeType4M,
							@Level,
							@Factory,
							@Model,
							@LineCode,
							@RouteCode,
							@LotNo1,
							@LotNo2,
							@LotNo3,
							@DetailedChangeCategories,
							@ReasonForChange,
							@ConditionsBefChange,
							@ConditionsAftChange,
							@QualityAssuranceContent,
							@ApprovalDate,
							@EffectiveDate,
							@Conclusion,
							@Inspector,
							@Change4MImage,
							@Change4MImageUrl,
							@ProdProcessResultFile,
							@Status,
							@Note,
							@ConnectString,
							1,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						    
						)

				END 
				ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_QC4MChangeDataRecord',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT

					-- 보고서번호가 존재하면 UPDATE
					IF EXISTS (SELECT 1 FROM STB_QC4MChangeDataRecord WHERE QC4MNo = @QC4MNo) BEGIN

						UPDATE STB_QC4MChangeDataRecord
						SET
						    QC4MNo = ISNULL(@QC4MNo,QC4MNo),
							ApprovalType = ISNULL(@ApprovalType,ApprovalType),
							IssuingDepartment = ISNULL(@IssuingDepartment,IssuingDepartment),
							ChangeType4M = ISNULL(@ChangeType4M,ChangeType4M),
							Level = ISNULL(@Level,Level),
							Factory = ISNULL(@Factory,Factory),
							[Model] = ISNULL(@Model,Model),
							LineCode = ISNULL(@LineCode,LineCode),
							RouteCode = ISNULL(@RouteCode,RouteCode),
							LotNo1 = ISNULL(@LotNo1,LotNo1),
							LotNo2 = ISNULL(@LotNo2,LotNo2),
							LotNo3 = ISNULL(@LotNo3,LotNo3),
							DetailedChangeCategories = ISNULL(@DetailedChangeCategories,DetailedChangeCategories),
							ReasonForChange = ISNULL(@ReasonForChange,ReasonForChange),
							ConditionsBefChange = ISNULL(@ConditionsBefChange,ConditionsBefChange),
							ConditionsAftChange = ISNULL(@ConditionsAftChange,ConditionsAftChange),
							QualityAssuranceContent = ISNULL(@QualityAssuranceContent,QualityAssuranceContent),
							ApprovalDate = ISNULL(@ApprovalDate,ApprovalDate),
							EffectiveDate = ISNULL(@EffectiveDate,EffectiveDate),
							Conclusion = ISNULL(@Conclusion,Conclusion),
							Inspector = ISNULL(@Inspector,Inspector),
							Change4MImage = ISNULL(@Change4MImage,Change4MImage),
							Change4MImageUrl = ISNULL(@Change4MImageUrl,Change4MImageUrl),
							ProdProcessResultFile = ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
							[Status] = ISNULL(@Status,Status),
							Note = ISNULL(@Note,Note),
							ConnectString = ISNULL(@ConnectString,ConnectString),
							--ShowData = ISNULL(@ShowData,ShowData),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						    
							
						WHERE
						    QC4MNo = @QC4MNo

						-- 변경된 데이터를 VECS_QC_RPT 테이블에 반영한다. 생산출력용
						-- Turbo ERP 서버 사고 이후 데이터베이스 소실로 동기화 중지 2023.04-13
						--BEGIN TRY  
						--		 exec usp_DoSyncDefectReportData @OldDefectReportNo
						--END TRY  

						--BEGIN CATCH  
						--		exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서 데이터 동기화를 실패하였습니다. 관련 프로세스를 점검하시기 바랍니다'
						--END CATCH 

					END ELSE BEGIN -- 그렇지 않으면 Insert
					--	----신규의 경우 @DefectReportNo = '자동채번'이므로 일치하는 번호가 없음.
					--	----Dummy쿼리의 자동채번 로직을 삭제하고 이 곳에서 신규로 채번함.
					--	----2020.07.07 By Jackaroe

					--	---- @DefectReportNo 채번
					--	--SELECT @DefectReportNo = 'VN' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' 
					--	--							  + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
					--	--  FROM STB_QcDefectReport
					--	-- WHERE DefectReportNo LIKE 'VN' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'

						IF @IsAutoKey = 1 
							BEGIN
								EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QC4MChangeDataRecord',@QC4MNo OUTPUT
								SET @QC4MNo = 'VN' + @QC4MNo
							END
                        
							--부적합보고서 번호는 VN을 추가한다. 
							--부적합 유형별로 머리글이 달랐으나 VN으로 통일함
							--SET @DefectReportNo = 'VN' + @DefectReportNo
						--END

					-- 중복제거 (엄제식님 요청)
					 IF EXISTS (SELECT 1 FROM STB_QC4MChangeDataRecord WHERE QC4MNo = @QC4MNo) 
					 BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage, '동일한 Lot번호에 동일한 불량유형이 등록된 이력이 있습니다.'
						RETURN
					 END

						INSERT INTO STB_QC4MChangeDataRecord
						(
							QC4MNo,
							ApprovalType,
							IssuingDepartment,
							ChangeType4M,
							[Level],
							Factory,
							[Model],
							LineCode,
							RouteCode,
							LotNo1,
							LotNo2,
							LotNo3,
							DetailedChangeCategories,
							ReasonForChange,
							ConditionsBefChange,
							ConditionsAftChange,
							QualityAssuranceContent,
							ApprovalDate,
							EffectiveDate,
							Conclusion,
							Inspector,
							Change4MImage,
							Change4MImageUrl,
							ProdProcessResultFile,
							[Status],
							Note,
							ConnectString,
							ShowData,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
						    @QC4MNo,
							@ApprovalType,
							@IssuingDepartment,
							@ChangeType4M,
							@Level,
							@Factory,
							@Model,
							@LineCode,
							@RouteCode,
							@LotNo1,
							@LotNo2,
							@LotNo3,
							@DetailedChangeCategories,
							@ReasonForChange,
							@ConditionsBefChange,
							@ConditionsAftChange,
							@QualityAssuranceContent,
							@ApprovalDate,
							@EffectiveDate,
							@Conclusion,
							@Inspector,
							@Change4MImage,
							@Change4MImageUrl,
							@ProdProcessResultFile,
							@Status,
							@Note,
							@ConnectString,
							1,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						    
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
						--IF @PublishDeptCode = '4000' BEGIN
						--	exec usp_DoSendLineMessageForDefectReport '', '', @DefectReportNo
						--END

						-- 추가 이메일 발송 처리 : 수신처가 베트남 생산부문이 아니면 무조건 발송 2020.09.19 이미정차장 요청. By Jackaroe
						-- 수신처가 베트남 생산부문이어도 무조건 발송. 베트남 현지 스탭 추가 부분은 usp_DoSendEmailForDefectReport 에서 처리함.
						-- 2020.10.15 이미정차장 요청 By Jackaroe
						--BEGIN TRY  
						--		exec usp_DoSendEmailForDefectReport @pProcessUserID, @pProcessLanguage, @DefectReportNo
						--END TRY  
						--BEGIN CATCH  
						--		exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서 이메일 발송을 실패하였습니다. 관련 프로세스를 점검하시기 바랍니다'
						--END CATCH  
					END

                    
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_QC4MChangeDataRecord
						WHERE
						    QC4MNo = @QC4MNo
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
