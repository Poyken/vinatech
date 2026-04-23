-- =============================================
-- Author : Kangs (kilee@vina.co.kr)
-- Create Date : 2022-04-04
-- Browsable : True
-- Group : 생산관리 > 생산실적 수정 >  불량실적수정버튼!!!
-- Description :	
-- Modified : 

-- 프로시저 실행 :   usp_Bad_RouteHistModify_iud   'kilee2',    'Korean',   'VJJQ302R750670', 'E-22', '20', 'E-22_1WK'
-- ===============================================================================
                                        
Create PROCEDURE [dbo].[usp_Bad_RouteHistModify_iud_Backup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(50) = Null,
						@pRouteCode VARCHAR(50) = Null,				
						@pDefectQty INT = Null,
						@pDefectCode VARCHAR(20) = Null
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode    VARCHAR(50) = @pBarcode
	DECLARE @ControlNo  VARCHAR(20) 
	DECLARE @RouteCode  VARCHAR(20)  = @pRouteCode
	DECLARE @DefectQty  INT  = @pDefectQty
	DECLARE @DefectCode VARCHAR(20)  = @pDefectCode

-- 1. SetInfo 테이블에서 검색 -> ControlNo파악
		Select @ControlNo = ControlNo
		From STB_SetInfo 
		Where BARCODE = @Barcode


-- 2. 히스토리 테이블에서 공정별 검색
		Select * From STB_ProdRouteHist
		Where 1=1
		   And ControlNo = @ControlNo
		   And RouteCode = @RouteCode


    -- 주석부분
      SELECT @ControlNo  AS ControlNo	         			 
	  SELECT @RouteCode AS RouteCode
	  SELECT @DefectCode AS DefectCode


-- 3. 백업테이블 생성하고 
            Insert Into STB_BackData_Hist   -- Delete STB_BackData_Hist
			   Select CompanyCode
				       , WorkCenterCode
					   , DefectSummaryNo As ControlNo
				       , '' As MaterialCode
				       , FindJobDate
					   , '' as ShiftCode
					   , FindLineCode
					   , FindRouteCode
					   , '' as WorkerCode
					   , '' as MachineCode
					   , 'STB_DefectRepairInfo'    --불량정보 테이블
					   , DefectQty 
					   , GetDate()
					   , CreateUserID		  				
					 From STB_DefectRepairInfo
			   Where 1=1
			     --And ControlNo = '20190830000070'
			     --And DefectCode = 'E-22_1WK'
				And  ControlNo = @ControlNo
				And DefectCode = @DefectCode
				And FindRouteCode = @RouteCode

				
            -- 4. 불량수량 수정
			   Update STB_DefectRepairInfo
			        Set DefectQty = @DefectQty					  
				Where 1=1
				   And ControlNo = @ControlNo
				   And FindRouteCode = @RouteCode
				   And DefectCode = @DefectCode
				 

-- 데이터 검증
/*
select * from stb_setinfo where barcode = 'VJJQ302R750670'

select DefectQty, * from STB_DefectRepairInfo
Where 1=1
And ControlNo = '20190830000070'
And DefectCode = 'E-22_1WK'
And FindRouteCode = 'E-22'
	*/			   


END

