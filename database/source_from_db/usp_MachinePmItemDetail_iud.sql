-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	설비정기점검항목상세 IUD(설비정기점검 이력 생성 및 업데이트)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachinePmItemDetail_iud]
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
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  
	DECLARE @MachinePmItemCode VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @MachineCode VARCHAR(20)
	DECLARE @PmItemName NVARCHAR(100)
	DECLARE @PmItemGroup NVARCHAR(100)
	DECLARE @PmItemSpec NVARCHAR(200)
	DECLARE @PmTermType VARCHAR(10)
	DECLARE @FinalPmDate DATE
	DECLARE @NextPmPlanDate DATE
  
	DECLARE @PmText NVARCHAR(100)
	DECLARE @IsFinishPm BIT
	DECLARE @MachinePmHistoryNo VARCHAR(20)
	DECLARE @MachineRepairWorkerCode VARCHAR(20)
  
  
	DECLARE @JobDate DATE
	DECLARE @CurrentDate DATE
	SET @CurrentDate = GETDATE()
  
	DECLARE @Result VARCHAR(10)
	DECLARE @InspectionValue NUMERIC(20,5)  

	-- 정기점검 결과 리포트 관련 변수 추가
	DECLARE @MachinePmResultReportFileID BIGINT
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)
   	

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			--@pTableName = 'STB_MachinePmItem',
			@pTableName = 'STB_MachinePmHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
			
			
    
	BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                
			SELECT
					'UPDATE' AS IUD_FLAG,
					XMLData.MachinePmHistoryNo,
					XMLData.MachinePmItemCode,
					XMLData.CompanyCode,
					XMLData.WorkCenterCode,
					XMLData.MachineCode,
					XMLData.PmItemName,
					XMLData.PmItemGroup,
					XMLData.PmItemSpec,
					XMLData.PmTermType,
					XMLData.FinalPmDate,
					XMLData.NextPmPlanDate,
					XMLData.PmText,
					XMLData.IsFinishPm,
					XMLData.MachineRepairWorkerCode,
					XMLData.Result,
					XMLData.InspectionValue,
					XMLData.MachinePmResultReportFileID,
					XMLData.FileName,
					dbo.fnBase64ToBinary(XMLData.FileData) AS FileData,
					XMLData.FileSize
			FROM
					OPENXML(@idoc , @UpdateTableName , 2)
			        WITH  (
							 MachinePmHistoryNo VARCHAR(20),
							 MachinePmItemCode VARCHAR(20),
							 CompanyCode VARCHAR(20),
							 WorkCenterCode VARCHAR(20),
							 MachineCode VARCHAR(20),
							 PmItemName NVARCHAR(100),
							 PmItemGroup NVARCHAR(100),
							 PmItemSpec NVARCHAR(200),
							 PmTermType VARCHAR(10),
							 FinalPmDate DATETIMEOFFSET,
							 NextPmPlanDate DATETIMEOFFSET,
							 PmText NVARCHAR(100),
							 IsFinishPm BIT,
							 MachineRepairWorkerCode VARCHAR(20),
							 Result VARCHAR(10),
							 InspectionValue NUMERIC(20,5),
							 MachinePmResultReportFileID BIGINT,
							 FileName NVARCHAR(255),
							 FileData NVARCHAR(MAX),
							 FileSize BIGINT
							) XMLData
							

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @MachinePmHistoryNo,
								 @MachinePmItemCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MachineCode,
								 @PmItemName,
								 @PmItemGroup,
								 @PmItemSpec,
								 @PmTermType,
								 @FinalPmDate,
								 @NextPmPlanDate,
								 @PmText,
								 @IsFinishPm,
								 @MachineRepairWorkerCode,
								 @Result,
								 @InspectionValue,
								 @MachinePmResultReportFileID,
								 @FileName,
								 @FileData,
								 @FileSize
								


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				SET @MachinePmResultReportFileID = NULL
				
                IF @IUD_FLAG = 'UPDATE' BEGIN
					-- 기존 데이터 존재 여부와 상관없이 신규입력 처리이기 때문에 파일은 미리 업로드한다.
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MachinePmHistory',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @MachinePmResultReportFileID OUTPUT
                	
					IF EXISTS (SELECT 1 FROM STB_MachinePmHistory WHERE MachinePmHistoryNo = @MachinePmHistoryNo) BEGIN
						
						--IF ISNULL(@IsFinishPm,0) = 0 BEGIN
							
							
							DELETE FROM STB_MachinePmHistory 
							WHERE 
								MachinePmHistoryNo = @MachinePmHistoryNo
								
							SELECT
									TOP 1
									@JobDate = JobDate
							FROM
									STB_MachinePmHistory 
							WHERE
									MachinePmItemCode = @MachinePmItemCode
							ORDER BY
									MachinePmHistoryNo DESC
									
									
							--IF @JobDate IS NULL BEGIN //2022. 08. 31 Modify SJC
							
							--	UPDATE STB_MachinePmItem 
							--	SET
							--		FinalPmDate = @CurrentDate,
							--		NextPmPlanDate = CASE WHEN PmTermType = '일' THEN DATEADD(DD,1,@CurrentDate)
							--						WHEN PmTermType = '주' THEN DATEADD(WW,1,@CurrentDate) 
							--						WHEN PmTermType = '월' THEN DATEADD(MM,1,@CurrentDate)
							--						WHEN PmTermType = '년' THEN DATEADD(YY,1,@CurrentDate)
							--					END,
							--		ChangeDateTime = GETDATE(),
							--		ChangeUserID = @ProcessUserID
							--	WHERE
							--		MachinePmItemCode = @MachinePmItemCode	
									
							--END	ELSE 
							--BEGIN
								
								
							--	UPDATE STB_MachinePmItem 
							--	SET
							--		FinalPmDate = @JobDate,
							--		NextPmPlanDate = CASE WHEN PmTermType = '일' THEN DATEADD(DD,1,@JobDate)
							--						WHEN PmTermType = '주' THEN DATEADD(WW,1,@JobDate) 
							--						WHEN PmTermType = '월' THEN DATEADD(MM,1,@JobDate)
							--						WHEN PmTermType = '년' THEN DATEADD(YY,1,@JobDate)
							--					END,
							--		ChangeDateTime = GETDATE(),
							--		ChangeUserID = @ProcessUserID
							--	WHERE
							--		MachinePmItemCode = @MachinePmItemCode	
							--END	//2022. 08. 31 Modify SJC
							
							
							IF @IsAutoKey = 1 BEGIN
								EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachinePmHistory', @MachinePmHistoryNo OUTPUT
							END
							
							INSERT INTO STB_MachinePmHistory 
							(
								MachinePmHistoryNo,
								MachinePmItemCode,
								CompanyCode,
								WorkCenterCode,
								MachineCode,
								JobDate,
								MachineRepairWorkerCode,
								PmDateTime,
								PmText,
								IsFinishPm,
								CreateDateTime,
								CreateUserID,
								MachinePmResultReportFileID
							)
							VALUES
							(
								@MachinePmHistoryNo,
								@MachinePmItemCode,
								@CompanyCode,
								@WorkCenterCode,
								@MachineCode,
								CASE WHEN @JobDate IS NULL THEN @CurrentDate
								ELSE @JobDate END,
								@MachineRepairWorkerCode,
								CASE WHEN @JobDate IS NULL THEN GETDATE()
								ELSE CONVERT(DATETIME,CONVERT(VARCHAR(10),@JobDate) + ' ' + CONVERT(VARCHAR(8),CONVERT(TIME,GETDATE()))) END,
								@PmText,
								@IsFinishPm,
								GETDATE(),
								@ProcessUserID,
								@MachinePmResultReportFileID
							)
							
						--END ELSE 
						--BEGIN
						--	UPDATE STB_MachinePmHistory
						--	SET
						--			MachineRepairWorkerCode =  @MachineRepairWorkerCode,
						--			PmText = @PmText,
						--			IsFinishPm = @IsFinishPm,
						--			ChangeDateTime = GETDATE(),
						--			ChangeUserID = @ProcessUserID,
						--			Result = @Result,
						--			InspectionValue = @InspectionValue
						--	WHERE
						--			MachinePmHistoryNo = @MachinePmHistoryNo
						--END
					END
					ELSE BEGIN
					
						IF @IsAutoKey = 1 BEGIN
							SELECT
									@MaxKeyField = MAX(MachinePmHistoryNo)
							FROM
									STB_MachinePmHistory 
							WHERE
									MachinePmHistoryNo LIKE @PrefixString + '%'
														
							IF @MaxKeyField IS NULL BEGIN
								SET @MachinePmHistoryNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
							END ELSE BEGIN
								SET @MachinePmHistoryNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
							END
						END
						
						
						INSERT INTO STB_MachinePmHistory 
						(
							MachinePmHistoryNo,
							MachinePmItemCode,
							CompanyCode,
							WorkCenterCode,
							MachineCode,
							JobDate,
							MachineRepairWorkerCode,
							PmDateTime,
							PmText,
							IsFinishPm,
							CreateDateTime,
							CreateUserID,
							MachinePmResultReportFileID
						)
						VALUES
						(
							@MachinePmHistoryNo,
							@MachinePmItemCode,
							@CompanyCode,
							@WorkCenterCode,
							@MachineCode,
							@CurrentDate,
							@MachineRepairWorkerCode,
							GETDATE(),
							@PmText,
							@IsFinishPm,
							GETDATE(),
							@ProcessUserID,
							@MachinePmResultReportFileID
						)
						
						
						--UPDATE STB_MachinePmItem	//2022. 08. 31 Modify SJC
						--SET
						--		FinalPmDate = @CurrentDate,
						--		NextPmPlanDate = CASE WHEN PmTermType = '일' THEN DATEADD(DD,1,@CurrentDate)
						--							WHEN PmTermType = '주' THEN DATEADD(WW,1,@CurrentDate) 
						--							WHEN PmTermType = '월' THEN DATEADD(MM,1,@CurrentDate)
						--							WHEN PmTermType = '년' THEN DATEADD(YY,1,@CurrentDate)
						--						END,
						--		ChangeDateTime = GETDATE(),
						--		ChangeUserID = @ProcessUserID
						--WHERE
						--		MachinePmItemCode  = @MachinePmItemCode	//2022. 08. 31 Modify SJC
						
						
						--IF ISNULL(@IsFinishPm,0) = 1 BEGIN
						
						--	UPDATE STB_MachinePmItem
						--	SET
						--			FinalPmDate = @CurrentDate,
						--			NextPmPlanDate = CASE WHEN PmTermType = '일' THEN DATEADD(DD,1,@CurrentDate)
						--								WHEN PmTermType = '주' THEN DATEADD(WW,1,@CurrentDate) 
						--								WHEN PmTermType = '월' THEN DATEADD(MM,1,@CurrentDate)
						--								WHEN PmTermType = '년' THEN DATEADD(YY,1,@CurrentDate)
						--							END,
						--			ChangeDateTime = GETDATE(),
						--			ChangeUserID = @ProcessUserID
						--	WHERE
						--			MachinePmItemCode  = @MachinePmItemCode
						--END
		
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

