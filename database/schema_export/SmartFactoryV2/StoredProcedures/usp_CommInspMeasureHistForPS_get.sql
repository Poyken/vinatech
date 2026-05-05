-- Procedure: usp_CommInspMeasureHistForPS_get
-- ===================================================================================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사이력을 추가 합니다.
-- =========================================================================================================================================================
CREATE PROCEDURE usp_CommInspMeasureHistForPS_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pCommInspDocItemNo VARCHAR(20)
AS
BEGIN
	Declare @CommInspDocItemNo VARCHAR(20) = @pCommInspDocItemNo
	       ,@CommInspMeasureNo VARCHAR(20)
		   ,@CurrCnt INT = 1
		   ,@CommInspItemCode VARCHAR(20)
		   ,@ErrorMessage NVARCHAR(MAX)

	SELECT @CommInspItemCode = CommInspItemCode
	  FROM STB_CommInspDocItem
	 WHERE CommInspDocItemNo = @CommInspDocItemNo

	IF @CommInspItemCode <> 'RQP101' BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
															'^셀전압 항목을 선택하셔야 합니다.^',
															@ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1,@CommInspItemCode)
		RETURN
	END

	SELECT @CurrCnt = COUNT(*)
	  FROM STB_CommInspMeasureHist 
	 WHERE CommInspDocItemNo = @CommInspDocItemNo

	IF @CurrCnt <> 20 
	BEGIN
		SELECT @CurrCnt = COUNT(*) + 1
		  FROM STB_CommInspMeasureHist 
		 WHERE CommInspDocItemNo = @CommInspDocItemNo
		-- 입력된 값이 없으면 입력된 값을 제외하고 n개의 빈 값을 생성함.
		WHILE @CurrCnt <= 20 BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode				
			) VALUES (
				@CommInspMeasureNo
			   ,@CommInspDocItemNo
			   ,@CurrCnt
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			)

			SET @CurrCnt = @CurrCnt + 1
		END
	END

	SELECT CommInspMeasureNo
	      ,CommInspDocItemNo
		  ,MeasureSeq
		  ,NumericMeasure
	  FROM STB_CommInspMeasureHist
	 WHERE CommInspDocItemNo = @CommInspDocItemNo
END
GO

