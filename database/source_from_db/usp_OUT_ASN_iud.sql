-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-27
-- Browsable : true
-- Group : 제품관리
-- Description:	자동창고 출고 지시 정보를 입력합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OUT_ASN_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(20) = NULL,
	@pOutType CHAR(2) = 'NR', -- NR:정상출고, MV:이동출고
	@pStatus INT = 0 -- 0 : 등록, 1 : 전송, 9 : 오류
AS
BEGIN
	Declare @PackingID VARCHAR(20) = @pPackingID
	       ,@OutType CHAR(2) = @pOutType
		   ,@Status INT = @pStatus
		   ,@MaterialCode VARCHAR(20)
		   ,@ProdQty NUMERIC(20,5)
		   ,@MaterialName VARCHAR(100) 
		   ,@OutOrderNo VARCHAR(20)
		   ,@CompanyCode VARCHAR(20)
		   ,@MaterialLotNo VARCHAR(20)
		   ,@MaterialWarehouseCode VARCHAR(20)
		   ,@MaterialLocationCode VARCHAR(20)
	
	-- 품목코드, 수량
	SELECT @MaterialCode = MAX(MaterialCode)
	      ,@ProdQty = SUM(StockQty)
	  FROM STB_MaterialDocLotInfo
	 WHERE PackingID = @PackingID

	SELECT @CompanyCode = CompanyCode
	  FROM STB_MaterialLotInfo
	 WHERE PackingID = @PackingID

	-- 품목명
	SELECT @MaterialName = MaterialName FROM STB_MaterialMaster WHERE MaterialCode = @MaterialCode

	-- RcvOrderNo 채번
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'OUT_ASN', @OutOrderNo OUTPUT

	-- INSERT
	IF @CompanyCode = 'VNT' BEGIN
		INSERT INTO OUT_ASN (OUT_ORD_NO, PACK_ID, OUT_TYPE, ITM_CD, ITM_NM, ITM_QTY, STATUS)
			VALUES (@OutOrderNo, @PackingID, @OutType, @MaterialCode, @MaterialName, @ProdQty, @Status)
	END ELSE BEGIN
		INSERT INTO SmartFactoryIncubator.dbo.OUT_ASN (OUT_ORD_NO, PACK_ID, OUT_TYPE, ITM_CD, ITM_NM, ITM_QTY, STATUS)
			VALUES (@OutOrderNo, @PackingID, @OutType, @MaterialCode, @MaterialName, @ProdQty, @Status)
	END

	-- 출고의 경우 출고 확정 이후에 호출되는 것이기 때문에 WareNavi 인터페이스 테이블 입력 이후 작업이 없음.
END