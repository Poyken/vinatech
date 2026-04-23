-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-11-22
-- Browsable : true
-- Group : 생산관리
-- Description: 원자재 투입 적합성 체크
-- =============================================
CREATE PROCEDURE usp_DoCheckRawMaterialInput                               
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(20) = NULL,
						@pRawMaterialLotNo VARCHAR(100) = NULL
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@RawMaterialLotNo VARCHAR(100) = @pRawMaterialLotNo
		   ,@totCurrentQty NUMERIC(20,5)
		   ,@CurrentLineCode VARCHAR(20)
		   ,@LineCnt INT
		   ,@DuplicateInputCnt INT

	-- 투입예정라인
	SELECT @CurrentLineCode = LineCode
	  FROM STB_DayProdPlan
	 WHERE DayPlanNo = (
		SELECT DayPlanNo
		  FROM STB_SetInfo
		 WHERE Barcode = @Barcode
	 )

	-- 공정창고 재고 존재여부 체크
	SELECT @totCurrentQty = ISNULL(SUM(CurrentQty), 0)
	  FROM STB_MaterialLotInfo
	 WHERE (LotNo = @RawMaterialLotNo OR LotID = @RawMaterialLotNo)

	IF @totCurrentQty = 0 BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '불출된 자재가 존재하지 않습니다.'
		RETURN
	END

	-- BOM 체크 TO-DO

	-- 투입예정리스트 체크 TO-DO

	-- 중복투입여부 체크
	    -- 타 라인 입력 이력 체크
		SELECT @LineCnt = Count(*)
		  FROM STB_DayProdPlan
		 WHERE DayPlanNo IN (
							SELECT DayPlanNo
							  FROM STB_SetInfo 
							 WHERE Barcode IN (
												SELECT Barcode
												  FROM STB_RawMaterialInputHist
												 WHERE RawMaterialBarcode = @RawMaterialLotNo
												)
							)
		AND LineCode <> @CurrentLineCode

		IF @LineCnt > 0 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '다른 라인에 자재 투입 이력이 존재합니다.'
			RETURN
		END

		-- 동일 라인 연속공정 투입 여부 체크 (백플러시 적용 전까지는 3일 이전 이력만 체크)
		SELECT @DuplicateInputCnt = COUNT(*)
		  FROM STB_RawMaterialInputHist
		 WHERE RawMaterialBarcode = @RawMaterialLotNo
		   AND CreateDateTime < DATEADD(day, -3, GETDATE())

		IF @DuplicateInputCnt > 0 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '동일 자재가 투입된 이력이 있습니다.'
			RETURN
		END 

END