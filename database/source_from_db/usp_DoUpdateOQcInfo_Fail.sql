
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-30
-- Browsable : true
-- Group : 품질관리
-- Description:	출하검사 불합격을 처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateOQcInfo_Fail]
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
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)

	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @ProcessDateTime DATETIME
	DECLARE @JobDateShift VARCHAR(20)
	DECLARE @JobDate DATE
	DECLARE @ShiftCode VARCHAR(1)
	DECLARE @BefQcStatus VARCHAR(10)

	DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
				SELECT
						CASE 
							WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo
							ELSE XMLData.OldMaterialQcNo
						END AS OldMaterialIqcNo
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			SELECT
					@BefQcStatus = MQI.DecisionResult
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	


			IF ISNULL(@BefQcStatus,'') NOT IN ('None') BEGIN
					DECLARE @AlreadyFinish NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^이미 완료처리된 문서입니다.^',
																		@pValue = @AlreadyFinish OUTPUT	
					RAISERROR(@AlreadyFinish, 16, 1)
					RETURN
			END

			-- 2016-11-03 LDS 수정 불합격 판정 1개라도 있어야 처리하게 by 대우루컴즈 송요섭 부장 요청
			IF (
					SELECT
							COUNT(*)
					FROM
							STB_MaterialQcDetail 
					WHERE 
							MaterialQcNo = @OldMaterialQcNo AND
							(DecisionResult IS NOT NULL AND DecisionResult = 'Reject')
				) <= 0
			BEGIN
				RAISERROR('불합격 판정이 1건 이상 존재해야 합니다!',16,1)
				RETURN
			END
			
            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Reject',
				    DecisionDateTime = @ProcessDateTime,
				    DecisionUserID = @pProcessUserID,
				    ChangeDateTime = @ProcessDateTime,
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @OldMaterialQcNo

			SELECT
					TOP 1
					@WorkCenterCode = POI.WorkCenterCode
			FROM
					STB_SetInfo SI
					INNER JOIN STB_ProductionOrderInfo POI
						ON POI.PONo = SI.PONo
			WHERE
					SI.LotNumber = @OldMaterialQcNo

			SET @JobDateShift = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
			SET @JobDate = SUBSTRING(@JobDateShift,1,8)
			SET @ShiftCode = SUBSTRING(@JobDateShift,9,1)

			UPDATE	STB_SetInfo
			SET
					LotDecisionResult = 'Reject',
					IsFinalInspection = 1,
					FinalInspectionDateTime = @ProcessDateTime,
					FinalInspectionJobDate = @JobDate,
					FinalInspectionShiftCode = @ShiftCode
			WHERE
					LotNumber = @OldMaterialQcNo

			-- 불량?
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

