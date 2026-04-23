-- =========================================================================================
-- Author : Kangs (kilee@vina.co.kr)
-- Create Date : 2022-04-04
-- Browsable : True
-- Group : 생산관리 > 생산실적 수정 > 생산실적수정버튼
-- Description :	
-- Modified : 
-- 프로시저 실행 :   usp_Prod_RouteHistModify_iud   'kilee2',    'Korean',   'VJJQ302R750670',    '505',  'VNEP02120',   '19012902',  'E-22'
-- ==========================================================================================
                                        
CREATE PROCEDURE [dbo].[usp_Prod_RouteHistModify_iud]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(50) = Null,
						@pProdQty   INT = Null,
						@pMachineCode  VARCHAR(30) = Null, 
						@pWorkerCode VARCHAR(30) = Null,
						@pRouteCode VARCHAR(20) = Null,
						@pShiftCode Varchar(1) = Niull
AS

BEGIN
	SET NOCOUNT ON;

-- 변수선언
	DECLARE @Barcode     Varchar(50) = @pBarcode
	DECLARE @ControlNo  Varchar(20) 
	DECLARE @RouteCode  Varchar(20) = @pRouteCode 
	DECLARE @ProdQty       Int = @pProdQty
	DECLARE @OldProdQty   Int 
	DECLARE @MachineCode  Varchar(30)  = @pMachineCode
	DECLARE @WorkerCode   Varchar(30)  = @pWorkerCode
	DECLARE @MaterialCode   Varchar(40) 
	DECLARE @PoNo   Varchar(16) 
	DECLARE @JobDate  Date
	DECLARE @ShiftCode Varchar(1) = @pShiftCode
	DECLARE @Count Int

-- 1. SetInfo 테이블에서 검색 -> ControlNo파악
		Select @ControlNo = ControlNo
		       , @MaterialCode = MaterialCode
			   , @PoNo =PoNo
			   , @JobDate = InputJobDate
			   , @ShiftCode = InputShiftCode
		From STB_SetInfo 
		Where BARCODE = @Barcode


-- 2. 히스토리 테이블에서 공정별 검색
		Select @OldProdQty = ProdQty
		From STB_ProdRouteHist
		Where 1=1
		   And ControlNo = @ControlNo
		   And RouteCode = @RouteCode

      -- 주석부분
   --   SELECT @ControlNo  AS ControlNo	         			 
	  --SELECT  @RouteCode AS RouteCode


-- 3. 백업테이블 생성하고 
       Insert Into STB_BackData_Hist    
		    Select CompanyCode
			       , WorkCenterCode
				   , ControlNo
			       , MaterialCode
			       , JobDate
				   , ShiftCode
				   , LineCode
				   , RouteCode
				   , WorkerCode
				   , MachineCode
				   , 'STB_ProdRouteHist'
				   , ProdQty 
				   , GetDate()
				   , @WorkerCode  				
			 From STB_ProdRouteHist
			 Where 1=1
			  --And  ControlNo = '20220328000380'
			  --And RouteCode = 'E-22'
				And  ControlNo = @ControlNo
				And RouteCode = @RouteCode

 -- 4. 생산수량 업데이트 부분
		Update STB_ProdRouteHist
			 Set ProdQty = @ProdQty
			    , MachineCode = @MachineCode
				, WorkerCode = @WorkerCode
		  Where 1=1
			-- And  ControlNo = '20220328000380'
			 --And RouteCode = 'E-25'
			And  ControlNo = @ControlNo
			And RouteCode = @RouteCode

	
/*
-- 5. STB_ProdRouteHist 삭제부분!!!
		Delete From STB_ProdRouteHist
		Where 1=1
			And  ControlNo = '20220328000380'
			And RouteCode = 'E-22'
		-- And  ControlNo = @ControlNo
		-- And RouteCode = @RouteCode
*/

-- 6. Summary 테이블 
   SELECT @Count = Count(*) 
   FROM STB_ProdRouteSummary
   WHERE 1=1
      AND MaterialCode = @MaterialCode
      AND RouteCode = @RouteCode
	  AND PoNo = @PoNo
	  AND JobDate = @JobDate
	  AND ShiftCode = @ShiftCode

	  IF @Count = 1 
	       IF @ProdQty > @OldProdQty
			  Begin 
				Update STB_ProdRouteSummary
					Set OutputQty = OutputQty - @ProdQty   --마이너스
				WHERE 1=1
					AND MaterialCode = @MaterialCode
					AND RouteCode = @RouteCode
					AND PoNo = @PoNo
					AND JobDate = @JobDate
					AND ShiftCode = @ShiftCode
			   End

            IF @ProdQty < @OldProdQty
			  Begin 
				Update STB_ProdRouteSummary
					Set OutputQty = OutputQty + @ProdQty   --플러스
				WHERE 1=1
					AND MaterialCode = @MaterialCode
					AND RouteCode = @RouteCode
					AND PoNo = @PoNo
					AND JobDate = @JobDate
					AND ShiftCode = @ShiftCode
			   End 
   

	    IF @Count > 1 

		Begin
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '수정이 불가한 경우로, EA팀으로부터 지원 받으시길 바랍니다.'
			RETURN
		End

END
