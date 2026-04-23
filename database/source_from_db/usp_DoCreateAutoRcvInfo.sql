CREATE PROC [dbo].[usp_DoCreateAutoRcvInfo]
AS
BEGIN
	Declare @RcvOrderNo VARCHAR(20)
	       ,@PackingID VARCHAR(20)
	       ,@MaterialCode VARCHAR(20)
		   ,@BoxQty NUMERIC(6,0)
		   ,@LotNo VARCHAR(20)
		   ,@ProductStockNo VARCHAR(20)
		   ,@CompanyCode VARCHAR(20)
		   ,@WorkCenterCode VARCHAR(20)
		   ,@MaterialWarehouseCode VARCHAR(20)
		   ,@MaterialLocationCode VARCHAR(20)
		   ,@InterfaceCompanyCode VARCHAR(20)
		   ,@InterfaceWorkCenterCode VARCHAR(20)
		   ,@InterfaceMaterialWarehouseCode VARCHAR(20)
		   ,@InterfaceMaterialLocationCode VARCHAR(20)
		   ,@IDX BIGINT

	-- 1. 처리되지 않은 입고처리결과 
	DECLARE cur CURSOR FOR

	SELECT PACK_ID, ITM_CD, ITM_QTY, RCV_ORD_NO, 'VNT', 'VNT_F1', 'PROD_WH', 'PROD_WH_04', IDX
	  FROM RCV_RSLT
	 WHERE AUTO_RCV_STATUS = 0
	-- UNION ALL
	--SELECT PACK_ID, ITM_CD, ITM_QTY, RCV_ORD_NO, 'VVT', 'VVT_F1', 'PROD_VN_WH', 'PROD_VN_WH_01', IDX
	--  FROM SmartFactoryIncubator.dbo.RCV_RSLT
	-- WHERE AUTO_RCV_STATUS = 0

	OPEN cur

	FETCH NEXT FROM cur INTO @PackingID, @MaterialCode, @BoxQty, @RcvOrderNo
	                       , @InterfaceCompanyCode, @InterfaceWorkCenterCode, @InterfaceMaterialWarehouseCode, @InterfaceMaterialLocationCode
						   , @IDX

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 2. 패킹ID별 대표Lot정보
		-- 인터페이스 소스 기준으로 사업장을 처리
		SELECT TOP 1 
		       @LotNo = MAX(CASE WHEN ISNULL(LotNo, '') = '' THEN LotID ELSE LotNo END)
		      --,@CompanyCode = CompanyCode
			  --,@WorkCenterCode = WorkCenterCode
			  ,@MaterialWarehouseCode = MaterialWarehouseCode
			  ,@MaterialLocationCode = MaterialLocationCode
		  FROM STB_MaterialLotInfo
		 WHERE PackingID = @PackingID
		 GROUP BY CompanyCode, WorkCenterCode, MaterialWarehouseCode, MaterialLocationCode

		 IF @CompanyCode IS NULL BEGIN
			SET @CompanyCode = @InterfaceCompanyCode
			SET @WorkCenterCode = @InterfaceWorkCenterCode
			SET @MaterialWarehouseCode = @InterfaceMaterialWarehouseCode
			SET @MaterialLocationCode = @InterfaceMaterialLocationCode
		 END

		-- 3. 제품재고정보 입력
		EXEC usp_DoCreateSerial 'STB_ProductStockInfoUpload',@ProductStockNo OUTPUT

		INSERT INTO STB_ProductStockInfoUpload (ProductStockNo
                                               ,CompanyCode
                                               ,WorkCenterCode
                                               ,MaterialCode
                                               ,Barcode
                                               ,PackingID
                                               ,MaterialWarehouseCode
                                               ,MaterialLocationCode
                                               ,StockQty
                                               )
			VALUES (
				@ProductStockNo
			   ,@CompanyCode
			   ,@WorkCenterCode
			   ,@MaterialCode
			   ,@LotNo
			   ,@PackingID
			   ,@MaterialWarehouseCode
			   ,@MaterialLocationCode
			   ,@BoxQty
			)

		-- 4. 처리결과 업데이트
		IF @CompanyCode = 'VNT' BEGIN
			UPDATE RCV_RSLT
			   SET AUTO_RCV_STATUS = 1
			 WHERE IDX = @IDX
		END ELSE BEGIN
			UPDATE SmartFactoryIncubator.dbo.RCV_RSLT
			   SET AUTO_RCV_STATUS = 1
			 WHERE IDX = @IDX
		END
	
		FETCH NEXT FROM cur INTO @PackingID, @MaterialCode, @BoxQty, @RcvOrderNo
		                       , @InterfaceCompanyCode, @InterfaceWorkCenterCode, @InterfaceMaterialWarehouseCode, @InterfaceMaterialLocationCode
							   , @IDX
	END

	CLOSE cur
	DEALLOCATE cur
	
END
