-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019.02.11
-- Browsable : true
-- Group : 생산관리
-- Description: 조립공정Lot등록정보 > 조립공정실적정보 화면 -	Lot 생산현황 조회(실적)
-- Modified:


-- [프로시저실행문]     EXEC 	usp_AssyCardInfoProdQty_get  '','','VJKJ273R036710'
--  EXEC 	usp_AssyCardInfoProdQty_get_20200211  '','','VVKK063R033520'                       --> 문제있는것
--  EXEC 	usp_AssyCardInfoProdQty_get_20200211  '','','VVKK093R010601'                       --> 정상

-- =============================================
CREATE PROCEDURE [dbo].[usp_AssyCardInfoProdQty_get_20200211]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pBarcode [varchar](20) = NULL
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;


	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@TotalCount INT 

    SELECT @TotalCount = COUNT(*) FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)

--   ECVT30-229


	-- 실적등록정보
	 SELECT PRH.MaterialCode
	       ,MM.MaterialName
		   ,PRH.LineCode
		   ,PRH.RouteCode
		 , RI.RouteName
		   ,MAX(PRH.WorkerCode)  AS WorkerCode
		  ,MAX(PWI.WorkerName) AS WorkerName
		 -- , SELECT 
		   ,PRH. MachineCode 
		   ,MM2.MachineName
		   ,PRH.ProdQty AS InputProdQty
		   ,ISNULL(DRI.DefectQty, 0) AS DefectQty
		   ,(PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		   , PRH.pono, PRH.ProdRouteHistNo
		  , PRH.ProdDateTime AS ProdDate
		  , CONVERT(BIT, CASE WHEN ROW_NUMBER () OVER ( ORDER BY PRH.RouteCode ASC) = @TotalCount THEN 0 ELSE 1 END) AS ProdQtyFinishYn
	   FROM STB_ProdRouteHist PRH
			   LEFT OUTER JOIN STB_MaterialMaster MM	     ON PRH.MaterialCode = MM.MaterialCode
			   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	     ON PRH.WorkerCode = PWI.EmpNo
			   LEFT OUTER JOIN STB_MachineMaster MM2	     ON PRH.MachineCode = MM2.MachineCode
			   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
										  FROM STB_DefectRepairInfo 
										 WHERE RepairType NOT IN ('MISSING', 'FINISH')
										 GROUP BY ControlNo, FindRouteCode
									  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode

	  WHERE PRH.ControlNo = ( SELECT ControlNo
									   FROM STB_SetInfo SI
									  WHERE Barcode = @Barcode
									  )
     GROUP BY PRH.MaterialCode
	       ,MM.MaterialName
		   ,PRH.LineCode
		   ,PRH.RouteCode
		 , RI.RouteName
		   
		   ,PRH. MachineCode 
		   ,MM2.MachineName
		   ,PRH.ProdQty 
		   ,ISNULL(DRI.DefectQty, 0) 
		   ,(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))
		   , PRH.pono
		   , PRH.ProdRouteHistNo
		  , PRH.ProdDateTime 
		   , PRH.RouteCode 



END
