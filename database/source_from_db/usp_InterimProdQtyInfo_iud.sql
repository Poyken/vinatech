-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-03-03
-- Browsable : true
-- Group : 생산관리
-- Description: 실적처리 화면에서 중간실적을 입력 받아 등록한다.
-- =============================================

CREATE PROCEDURE usp_InterimProdQtyInfo_iud
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pRouteCode VARCHAR(20),
	@pProdQty NUMERIC(20,2)
AS

BEGIN
	Declare @ControlNo VARCHAR(20)
	       ,@Barcode VARCHAR(20) = @pBarcode
		   ,@RouteCode VARCHAR(20) = @pRouteCode
		   ,@ProdQty NUMERIC(20,2) = @pProdQty
		   ,@PlanQty NUMERIC(20,2)
		   ,@TotInterimProdQty NUMERIC(20,2)


	-- Barcode로 ControlNo를 구한다
	SELECT @ControlNo = ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode

	IF @ControlNo IS NULL BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Lot번호가 존재하지 않습니다.'
		RETURN
	END

	--수량이 0보다 작으면 입력할 수 없다.
	IF @ProdQty < 0 BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '0보다 작거나 같은 수량은 입력할 수 없습니다.'
		RETURN
	END

	SELECT @TotInterimProdQty = SUM(ProdQty)
	  FROM STB_InterimProdQtyInfo
	 WHERE ControlNo = @ControlNo
	   AND RouteCode = @RouteCode

	SELECT @PlanQty = ProdQty
	  FROM STB_SetInfo
	 WHERE ControlNo = @ControlNo

	IF ISNULL(@TotInterimProdQty, 0) + @ProdQty > @PlanQty BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '투입수량보다 많은 중간실적은 처리할 수 없습니다.'
		RETURN
	END

	INSERT INTO STB_InterimProdQtyInfo (ControlNo, RouteCode, ProdQty, CreateUserID)
		SELECT @ControlNo, @RouteCode, @ProdQty, @pProcessUserID
END