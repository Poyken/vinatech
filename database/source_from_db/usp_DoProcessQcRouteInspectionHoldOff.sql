-- ============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-24
-- Browsable : true
-- Group : 품질관리
-- Description :
-- ============================================

CREATE PROC usp_DoProcessQcRouteInspectionHoldOff

				@pProcessUserID VARCHAR(20) 
			   ,@pProcessLanguage VARCHAR(20)
			   ,@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@ProdQtyCnt INT

	-- 실적 등록 여부 체크
	SELECT @ProdQtyCnt = COUNT(*)
	  FROM STB_ProdRouteHist
	 WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)

	IF @ProdQtyCnt > 0 BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '실적등록이 된 Lot입니다. [C320] 수리상세이력관리에서 처리하세요.'
		RETURN
	END 

	UPDATE STB_SetInfo
	   SET SIExtInt01 = 0
	 WHERE Barcode = @Barcode
END