-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-07-28
-- Browsable : true
-- Group : 제품관리 > [G660]입고대기창고 이동처리 > 입고대기상태변경처리 Button
-- Description:	입고대기창고로 이동처리전에 체크로직입니다.
-- Modified:
-- 실행문 :  usp_DaifukuWarehouse_iud 'kilee','Korean', 'VJKP072R710623', 'PKKP0800057' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DaifukuWarehouse_iud]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pLotID VARCHAR(20) = NULL,
				@pPackingID VARCHAR(20) = NULL			
AS
BEGIN
	Declare @PackingID VARCHAR(20) = @pPackingID	       
		   , @LotID  VARCHAR(20) = @pLotID   --추가		   
		   , @Check INT                                 -- 추가
		   , @ControlNo VARCHAR(20)
		   ,@MaterialCode VARCHAR(20)
		   , @MaterialCode2 VARCHAR(20)        --추가
		   ,@ProdQty NUMERIC(20,5) 
		   ,@Qty NUMERIC(20,5)                   -- 추가
		   ,@MaterialName VARCHAR(100) 
		   ,@RcvOrderNo VARCHAR(20)
		   ,@CompanyCode VARCHAR(20)
		   ,@MaterialLotNo VARCHAR(20)
		   ,@MaterialWarehouseCode VARCHAR(20)
		   ,@MaterialLocationCode VARCHAR(20)
		   , @ErrorMessage VARCHAR(500)

	--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue)  VALUES ('usp_DaifukuWarehouse_iud', '@PackingID', @PackingID)
	--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DaifukuWarehouse_iud', '@LotID', @LotID)

	-- 바코드 있는지여부 확인 
	 --select @ControlNo  = ControlNo
		--	 from STB_SetInfo
  --    WHERE Barcode = @LotID
  
  --    SELECT  @ControlNo = PackingID 
		--FROM STB_MaterialLotInfo
  --     WHERE 1=1
	 --    AND (LotID = @LotID  Or LotNo = @LotID)


  --     IF @ControlNo IS NULL
	   
	 --	BEGIN
		--        SET @ErrorMessage = @ErrorMessage + ' [%s]'
		--		 RAISERROR('없는 바코드입니다.LotID를 확인바랍니다.' ,16, 1, @LotID)           
		--		 RETURN
		--END

	
	  -- 창고확인
  --           Select @MaterialWarehouseCode  = MaterialWarehouseCode   --
		--	  From STB_MaterialLotInfo 
		--	  Where 1=1
		--	     And PackingID = @PackingID


  --     IF @MaterialWarehouseCode <> 'PROD_STBY_WH'

	 --	BEGIN
		--		 RAISERROR('창고정보가 맞지않습니다. PackingID를 확인바랍니다.' ,16, 1, @PackingID)           
		--		 RETURN
		--END


	---- [수량과 품목코드 체크]
	--	   --1. Temp Table의 정보 (스프레드시트)
	--	 SELECT @Qty = Qty
	--			 , @MaterialCode2 = MaterialCode
	--	  FROM STB_WareHouseTemp                         -- TempTable의 수량
	--	  WHERE PackingID = @PackingID  
	  
	--	  -- 2. MES 정보
	--	SELECT @MaterialCode = MAX(MaterialCode)
	--			 ,@ProdQty = SUM(StockQty)
	--	  FROM STB_MaterialDocLotInfo                      -- 제품정보의 수량
	--	 WHERE PackingID = @PackingID

	--	 --	SELECT  MAX(MaterialCode)
	--		--	 ,SUM(StockQty)
	--	 -- FROM STB_MaterialDocLotInfo                      -- 제품정보의 수량
	--	 --WHERE PackingID = 'PKKP0800057'



	-- IF @Qty <> @ProdQty AND @MaterialCode <> @MaterialCode2   -- 수량과 품목코드 체크

	-- 	BEGIN
	--			 RAISERROR('수량이 맞지않거나 품목이 동일하지 않습니다. PackingID를 확인바랍니다.' ,16, 1, @PackingID )           
	--			 RETURN
	--	END

	
  
	---- 해당 패킹ID가 완제품 창고가 아니면, 완제품 창고로 이동
	---- 여러 Lot가 한 패킹으로 묶여있을 수 있으므로 Cursor로 처리
	--DECLARE BoxMoveCur CURSOR FOR

	--SELECT CompanyCode, MaterialLotNo, MaterialWarehouseCode, MaterialLocationCode
	--  FROM STB_MaterialLotInfo
	-- WHERE PackingID = @PackingID

	--OPEN BoxMoveCur

	--FETCH NEXT FROM BoxMoveCur INTO @CompanyCode, @MaterialLotNo, @MaterialWarehouseCode, @MaterialLocationCode

	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	--	IF @MaterialWarehouseCode NOT IN ('PROD_WH', 'PROD_VN_WH') BEGIN
	--		IF @CompanyCode = 'VNT' BEGIN
	--			SET @MaterialLocationCode = 'PROD_WH_01'
	--		END	ELSE BEGIN
	--			SET @MaterialLocationCode = 'PROD_VN_WH_01'
	--		END
			
	--		exec usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @MaterialLocationCode, @MaterialLotNo
	--	END
	
	--	FETCH NEXT FROM BoxMoveCur INTO @CompanyCode, @MaterialLotNo, @MaterialWarehouseCode, @MaterialLocationCode
	--END

	--CLOSE BoxMoveCur
	--DEALLOCATE BoxMoveCur

	 --Exec usp_RCV_ASN_iud '', '', @pPackingID               -- 프로시저 호출해서 테이블(RCV_ASN)에 Insert 처리
	  Exec  usp_RCV_ASN_Total_iud '', '', @pPackingID               -- 프로시저 호출해서 테이블(RCV_ASN)에 Insert 처리  (임시처리)

END 