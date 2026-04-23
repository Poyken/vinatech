CREATE PROC [dbo].[usp_DoCreateAutoOutInfo]
AS
BEGIN
	Declare @OutOrderNo VARCHAR(20)
	       ,@PackingID VARCHAR(20)
	       ,@MaterialCode VARCHAR(20)
		   ,@BoxQty NUMERIC(6,0)
		   ,@LotNo VARCHAR(20)
		   ,@ProductStockNo VARCHAR(20)
		   ,@CompanyCode VARCHAR(20)
		   ,@WorkCenterCode VARCHAR(20)
		   ,@InterfaceCompanyCode VARCHAR(20)
		   ,@InterfaceWorkCenterCode VARCHAR(20)
		   ,@IDX BIGINT
		   ,@TargetIDX BIGINT

	-- 1. 처리되지 않은 출고처리결과 
	DECLARE cur CURSOR FOR

	SELECT PACK_ID, ITM_CD, ITM_QTY, OUT_ORD_NO, 'VNT', 'VNT_F1', IDX
	  FROM OUT_RSLT
	 WHERE AUTO_OUT_STATUS = 0
	-- UNION ALL
	--SELECT PACK_ID, ITM_CD, ITM_QTY, OUT_ORD_NO,'VVT', 'VVT_F1', IDX
	--  FROM SmartFactoryIncubator.dbo.OUT_RSLT
	-- WHERE AUTO_OUT_STATUS = 0

	OPEN cur

	FETCH NEXT FROM cur INTO @PackingID, @MaterialCode, @BoxQty, @OutOrderNo, @CompanyCode, @WorkCenterCode, @IDX

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 2. 패킹ID별 대표Lot정보
		--SELECT TOP 1 
		--       @CompanyCode = CompanyCode
		--	  ,@WorkCenterCode = WorkCenterCode
		--  FROM STB_MaterialLotInfo
		-- WHERE PackingID = @PackingID

		IF @CompanyCode IS NULL BEGIN
			SET @CompanyCode = @InterfaceCompanyCode
			SET @WorkCenterCode = @InterfaceWorkCenterCode
		 END

		-- 3. 제품재고정보 삭제 -- 증분에 대한 데이터를 받는 것으로 변경되었으므로
		-- 동일한 건이 있으면 삭제를 하지 않고, 수량을 마이너스로 업데이트 한다.
		--DELETE FROM STB_ProductStockInfoUpload
		-- WHERE CompanyCode = @CompanyCode
		--   AND WorkCenterCode = @WorkCenterCode
		--   AND PackingID = @PackingID
		--   AND MaterialCode = @MaterialCode
		--   AND StockQty = @BoxQty

		-- 동일한 조건의 데이터가 존재하면, 가장 최근 데이터의 IDX를 기준으로 처리한다.
		-- OUT_RSLT 테이블의 프라이머리키 변경 및 데이터 처리방식 변경으로 아래와 같은 방법이 아니면
		-- 반복 입출고된 동일 PackingID에 대한 처리를 할 수 없다.
		SELECT TOP 1 @ProductStockNo = ProductStockNo
		  FROM STB_ProductStockInfoUpload
		 WHERE CompanyCode = @CompanyCode
		   AND WorkCenterCode = @WorkCenterCode
		   AND PackingID = @PackingID
		   AND MaterialCode = @MaterialCode
		   AND StockQty = @BoxQty
		 ORDER BY ProductStockNo DESC

		UPDATE STB_ProductStockInfoUpload
		   SET StockQty = StockQty - @BoxQty
		 WHERE ProductStockNo = @ProductStockNo

		-- 4. 처리결과 업데이트
		IF @CompanyCode = 'VNT' BEGIN
			UPDATE OUT_RSLT
			   SET AUTO_OUT_STATUS = 1
			 WHERE IDX = @IDX
		END ELSE 
		
		BEGIN
			UPDATE SmartFactoryIncubator.dbo.OUT_RSLT
			   SET AUTO_OUT_STATUS = 1
			 WHERE IDX = @IDX
		END
	
		FETCH NEXT FROM cur INTO @PackingID, @MaterialCode, @BoxQty, @OutOrderNo, @CompanyCode, @WorkCenterCode, @IDX
	END

	CLOSE cur
	DEALLOCATE cur
	
END
