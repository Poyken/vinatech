
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-30
-- Browsable : true
-- Group : 품질관리
-- Description:	출하검사 합격을 처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateOQcInfo_Success]
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
	DECLARE @DefectQty NUMERIC(20,5)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @ProcessQty NUMERIC(20,5)
	DECLARE @RemainQty NUMERIC(20,5)
	DECLARE @TotalCount INT
	DECLARE @LoopCount INT
	DECLARE @BefQcStatus VARCHAR(10)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @Barcode VARCHAR(50)
	DECLARE @RouteCode VARCHAR(20)
	DECLARE @DefectCode VARCHAR(20)
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @JobDateShift VARCHAR(20)
	DECLARE @JobDate DATE
	DECLARE @ShiftCode VARCHAR(1)
	DECLARE @WorkCenterCode VARCHAR(20)
	
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
					@BefQcStatus = MQI.DecisionResult,
					@ProcessQty = MQI.ProcessQty
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	

			IF ISNULL(@BefQcStatus,'None') NOT IN ('None') BEGIN
					DECLARE @AlreadyFinish NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^이미 완료처리된 문서입니다.^',
																		@pValue = @AlreadyFinish OUTPUT	
					RAISERROR(@AlreadyFinish, 16, 1)
					RETURN
			END

            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Pass',
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @OldMaterialQcNo

			UPDATE STB_MaterialQcDetail
			SET
					DecisionResult = 'Pass'
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					(DecisionResult IS NULL OR DecisionResult = '')

			SELECT
					TOP 1
					@LineCode = SI.InputLineCode,
					@Barcode = SI.Barcode,
					@ProdQty = SI.ProdQty,
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
					LotDecisionResult = 'Pass',
					IsFinalInspection = 1,
					FinalInspectionDateTime = GETDATE(),
					FinalInspectionJobDate = @JobDate,
					FinalInspectionShiftCode = @ShiftCode
			WHERE
					LotNumber = @OldMaterialQcNo AND
					LotDecisionResult = 'None'

			SET @DefectQty = @ProdQty - @ProcessQty

			--IF @ProdQty > 1 AND @DefectQty > 0 BEGIN
					-- 불량처리 폐기 될때 SetInfo에서 ProdQty 감소
					--EXEC usp_DoProcessDefectRepairInfoByBarcode	@pProcessUserID = @ProcessUserID,
					--											@pProcessLanguage = @ProcessLanguage,
					--											@pLineCode = @LineCode,
					--											@pRouteCode = @RouteCode,
					--											@pBarcode = @Barcode,
					--											@pDefectCode = @DefectCode,
					--											@pDefectQty = @DefectQty,
					--											@pProcessDateTime = @ProcessDateTime
			--END
			
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

