-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-06
-- Browsable : true
-- Group : 제품관리
-- Description:	
-- Modified:
-- 실행문 : [usp_RCV_RSLT_iud] '','','PKKP2700017' 
-- =============================================

Create PROCEDURE [dbo].[usp_RCV_RSLT_iud]
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
	
	SELECT * FROM RCV_RSLT
	WHERE 1=1
	  AND STATUS = 0
	  AND CRT_DT > '2020-08-06 09:00:00'

	-- 품목코드, 수량
	SELECT @MaterialCode = MAX(MaterialCode)
	         ,@ProdQty = SUM(StockQty)
	 FROM STB_MaterialDocLotInfo
	WHERE PackingID = @PackingID

	-- 품목명
	SELECT @MaterialName = MaterialName FROM STB_MaterialMaster WHERE MaterialCode = @MaterialCode

	-- RcvOrderNo 채번
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'RCV_ASN', @RcvOrderNo OUTPUT

	-- 동시에 처리되는 건에 대해서는 수량을 업데이트 하여 최종 수량만 반영한다.
	SELECT @CheckDupData = COUNT(*)
	  FROM RCV_ASN
	 WHERE CRT_DT > DATEADD(minute, -10, GETDATE())
	    AND PACK_ID = @PackingID

	IF @CheckDupData = 0 BEGIN
		-- INSERT
		INSERT INTO RCV_ASN (RCV_ORD_NO, PACK_ID, RCV_TYPE, ITM_CD, ITM_NM, ITM_QTY, STATUS)
			VALUES (@RcvOrderNo, @PackingID, @RcvType, @MaterialCode, @MaterialName, @ProdQty, @Status)

	END ELSE BEGIN
		UPDATE RCV_ASN
		   SET ITM_QTY = @ProdQty
		 WHERE PACK_ID = @PackingID
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
		IF @MaterialWarehouseCode NOT IN ('PROD_WH', 'PROD_VN_WH') BEGIN  -- 완제품창고가 아닌경우
			IF @CompanyCode = 'VNT' BEGIN
				SET @MaterialLocationCode = 'PROD_WH_01'
			END	ELSE BEGIN
				SET @MaterialLocationCode = 'PROD_VN_WH_01'
			END
			
			exec usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @MaterialLocationCode, @MaterialLotNo
		END
	
		FETCH NEXT FROM BoxMoveCur INTO @CompanyCode, @MaterialLotNo, @MaterialWarehouseCode, @MaterialLocationCode
	END

	CLOSE BoxMoveCur
	DEALLOCATE BoxMoveCur
END
