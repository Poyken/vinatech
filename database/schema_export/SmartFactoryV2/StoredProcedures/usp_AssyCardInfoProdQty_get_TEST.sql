-- Procedure: usp_AssyCardInfoProdQty_get_TEST
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019.02.11
-- Browsable : true
-- Group : 생산관리
-- Description: 조립공정Lot등록정보 > 조립공정실적정보 화면 -	Lot 생산현황 조회(실적)
-- Modified:
--              2022-02-14 공정순서대로 정렬 및 Case문 활용

-- [프로시저실행문]  	usp_AssyCardInfoProdQty_get_TEST  '','','VVOP113R015601', ''
-- [프로시저실행문]  	usp_AssyCardInfoProdQty_get_TEST '','','VVOM173R010705', ''
-- ==============================================================================
CREATE PROCEDURE [dbo].[usp_AssyCardInfoProdQty_get_TEST]
						@pProcessUserID [varchar](20),
						@pProcessLanguage [varchar](20),
						@pBarcode [varchar](20) = NULL,
						@pUtcOffset INT
WITH EXECUTE AS CALLER
AS

BEGIN
	SET NOCOUNT ON;

	Declare @Barcode    VARCHAR(20) = @pBarcode, @utc varchar(50)=@pUtcOffset


	        , @TotalCount INT 
	--RAISERROR(@utc,16,1)
    SELECT @TotalCount = COUNT(*) FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)

	-- 실적등록정보
	 SELECT PRH.MaterialCode
	       , MM.MaterialName
		   , PRH.LineCode
		   , PRH.RouteCode
		   , RI.RouteName
		   , PRH.WorkerCode
		   , PWI.WorkerName AS WorkerName
		   , PRH. MachineCode 
		   , MM2.MachineName
		   , PRH.ProdQty AS InputProdQty
		   , ISNULL(DRI.DefectQty, 0) AS DefectQty
		   , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		-- , PRH.pono, PRH.ProdRouteHistNo
		-- , PRH.ProdDateTime AS ProdDate          --원본백업
		--   , Case When PRH.RouteCode = 'E-29' Then PRH.CreateDateTime  Else PRH.ProdDateTime End As ProdDate          --2022.02.14 변경
		 
		 , dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset) AS ProdDate,
		 --PRH.ProdDateTime as test
		  ROW_NUMBER () OVER ( ORDER BY PRH.RouteCode ASC)
		   --, CONVERT(BIT, CASE WHEN ROW_NUMBER () OVER ( ORDER BY PRH.RouteCode ASC) = @TotalCount THEN 0 ELSE 1 END) AS ProdQtyFinishYn
	   FROM STB_ProdRouteHist PRH
			   LEFT OUTER JOIN STB_MaterialMaster MM	  ON PRH.MaterialCode = MM.MaterialCode
			   LEFT OUTER JOIN STB_ProdWorkerInfo PWI  ON PRH.WorkerCode = PWI.EmpNo
			   LEFT OUTER JOIN STB_MachineMaster MM2 ON PRH.MachineCode = MM2.MachineCode
			   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
										  FROM STB_DefectRepairInfo 
										 --WHERE RepairType NOT IN ('MISSING', 'FINISH')
										 GROUP BY ControlNo, FindRouteCode
									  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode

	  WHERE PRH.ControlNo = ( SELECT ControlNo
									     FROM STB_SetInfo SI
									    WHERE Barcode = @Barcode
									   )
      Order by  Case when PRH.RouteCode = 'E-28' Then 99 Else ROW_NUMBER() OVER (ORDER BY PRH.RouteCode) End ASC     -- 2022.02.14 Kangs 정렬추가 (공정 히스토리 순서로, 포장 예외처리)


END


	--select * from  STB_ProdRouteHist  
		
	--	 where ControlNo = ( SELECT ControlNo
	--								     FROM STB_SetInfo SI
	--								    WHERE Barcode = 'VVOM163R010708'
	--								   )

	--	update STB_ProdRouteHist set MaterialCode ='ECVT30-115' 
		
	--	 where ControlNo = ( SELECT ControlNo
	--								     FROM STB_SetInfo SI
	--								    WHERE Barcode = 'VVOM193R010701'
	--								   )


GO

