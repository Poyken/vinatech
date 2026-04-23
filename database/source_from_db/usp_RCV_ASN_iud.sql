-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-27
-- Browsable : true
-- Group : 제품관리
-- Description:	자동창고 입고 지시 정보를 입력합니다. 단독출고(입고이후 다시처리)는 태우게되면 에러!!
-- Modified:
-- 실행문 : [usp_RCV_ASN_iud] '','','MVVKQ004950' 
-- =============================================

CREATE PROCEDURE [dbo].[usp_RCV_ASN_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(20) = NULL,
	@pRcvType INT = 1,                             -- 1:입고, 2:직배출
	@pStatus INT   = 0                              -- 0 : 등록, 1 : 전송, 9 : 오류
AS
BEGIN
	Declare  @PackingID VARCHAR(20) = @pPackingID
			   ,@RcvType INT = @pRcvType
			   ,@Status INT = @pStatus
			   ,@MaterialCode VARCHAR(20)
			   ,@ProdQty NUMERIC(20,5)
			   ,@MaterialName VARCHAR(100) 
			   ,@RcvOrderNo VARCHAR(20)
			   ,@CompanyCode VARCHAR(20)
			   ,@MaterialLotNo VARCHAR(20)
			   ,@MaterialWarehouseCode VARCHAR(20)
			   ,@MaterialLocationCode VARCHAR(20)
			   ,@CheckDupData INT
	
	-- 품목코드, 수량
	SELECT @MaterialCode = MAX(MaterialCode)
	         ,@ProdQty        = SUM(StockQty)
	  FROM STB_MaterialDocLotInfo
	 WHERE PackingID = @PackingID

	-- 품목명
	SELECT @MaterialName = REPLACE(MaterialName, ',', '_') FROM STB_MaterialMaster WHERE MaterialCode = @MaterialCode

	-- RcvOrderNo 채번
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'RCV_ASN', @RcvOrderNo OUTPUT

	-- 동시에 처리되는 건에 대해서는 수량을 업데이트 하여 최종 수량만 반영한다.
	SELECT @CheckDupData = COUNT(*)
	  FROM RCV_ASN
	 WHERE CRT_DT > DATEADD(minute, -10, GETDATE())
	   AND PACK_ID = @PackingID

	SELECT @CompanyCode = CompanyCode
	  FROM STB_MaterialLotInfo
	 WHERE PackingID = @PackingID

	IF @CheckDupData = 0 
	
	BEGIN
		-- INSERT
		IF @CompanyCode = 'VNT' 
		
		BEGIN
			INSERT INTO RCV_ASN (RCV_ORD_NO, PACK_ID, RCV_TYPE, ITM_CD, ITM_NM, ITM_QTY, STATUS)
				VALUES (@RcvOrderNo, @PackingID, @RcvType, @MaterialCode, @MaterialName, @ProdQty, @Status)
		END ELSE BEGIN
			INSERT INTO SmartFactoryIncubator.dbo.RCV_ASN (RCV_ORD_NO, PACK_ID, RCV_TYPE, ITM_CD, ITM_NM, ITM_QTY, STATUS)
				VALUES (@RcvOrderNo, @PackingID, @RcvType, @MaterialCode, @MaterialName, @ProdQty, @Status)
		END

	END ELSE BEGIN

		IF @CompanyCode = 'VNT' 
		
		BEGIN
			UPDATE RCV_ASN
			   SET ITM_QTY = @ProdQty
			 WHERE PACK_ID = @PackingID
		END ELSE BEGIN
			UPDATE SmartFactoryIncubator.dbo.RCV_ASN
			   SET ITM_QTY = @ProdQty
			 WHERE PACK_ID = @PackingID
		END
	END

     Update STB_WarehouseTemp
	      Set IsCheck = 1
	  where PackingID =  @PackingID

	-- 해당 패킹ID가 완제품 창고가 아니면, 완제품 창고로 이동
	-- 여러 Lot가 한 패킹으로 묶여있을 수 있으므로 Cursor로 처리
	DECLARE BoxMoveCur CURSOR FOR

	SELECT CompanyCode, MaterialLotNo, MaterialWarehouseCode, MaterialLocationCode
	  FROM STB_MaterialLotInfo
	 WHERE PackingID = @PackingID

	OPEN BoxMoveCur

	FETCH NEXT FROM BoxMoveCur INTO @CompanyCode, @MaterialLotNo, @MaterialWarehouseCode, @MaterialLocationCode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @MaterialWarehouseCode IN ('PROD_STBY_VN_WH', 'PROD_STBY_WH') BEGIN  -- 법인 구분없이 완제품 대기창고에 있으면 완제품 창고로 이동한다.
			IF @CompanyCode = 'VNT' 
			
			BEGIN
				SET @MaterialLocationCode = 'PROD_WH_01'
			END	ELSE BEGIN
				SET @MaterialLocationCode = 'PROD_VN_WH_01'
			END

			--본사의 경우에만 창고 이동을 실행한다.
			--베트남 자동창고 적용으로 조건을 주석처리함. 2020.11.17
			--IF @CompanyCode = 'VNT' BEGIN
				Exec usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @MaterialLocationCode, @MaterialLotNo
			--END
		END
	
		FETCH NEXT FROM BoxMoveCur INTO @CompanyCode, @MaterialLotNo, @MaterialWarehouseCode, @MaterialLocationCode
	END

	CLOSE BoxMoveCur
	DEALLOCATE BoxMoveCur

END
