-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-05-13
-- Browsable : True
-- Group : 자재관리
-- Description: 안전재고 체크 및 알림
-- ==================================================
CREATE PROCEDURE [dbo].[usp_DoCheckSafeStockQty]
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pCompanyCode VARCHAR(20) = NULL,
			@pWorkCenterCode VARCHAR(20) = NULL,
			@pMaterialWarehouseCode VARCHAR(20) = NULL,
			@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
		   ,@MaterialCode VARCHAR(20) = @pMaterialCode
		   ,@SaftyStock NUMERIC(20,5) 
		   ,@StockQty NUMERIC(20,5) 
		   ,@MaterialWarehouseCode VARCHAR(20) = @pMaterialWarehouseCode

	SELECT @SaftyStock = SaftyStock
	  FROM STB_MaterialStockAttributeInfo
	 WHERE MaterialCode = @MaterialCode

	IF @SaftyStock > 0 BEGIN
		SELECT @StockQty = StockQty
		  FROM STB_MaterialStock
		 WHERE CompanyCode = @CompanyCode
		   AND WorkCenterCode = @WorkCenterCode
		   AND MaterialWarehouseCode = @MaterialWarehouseCode
		   AND MaterialCode = @MaterialCode

		IF @MaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH') 
		           AND @StockQty <= @SaftyStock 
				   AND @CompanyCode = 'VNT' BEGIN -- 본사만 우선 적용 
			exec usp_DoSendSMS @pProcessUserID, @pProcessLanguage, '01032226697', '{#1}의 현재고가 안전재고보다 작습니다. 확인 바랍니다.', @MaterialCode
		END
	END
END