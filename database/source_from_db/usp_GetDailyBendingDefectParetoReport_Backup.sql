-- ===========================================================================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-02-16
-- Browsable : True
-- Group : 보고서  생산관리 > VPC일별불량현황 > 아래 3번째 화면
-- Description:	절곡공정 ESR 불량 권취 설비 파레토 (grid & Chart)

--     usp_GetDailyBendingDefectParetoReport '','','2022-02-01','2022-02-22'
-- ============================================================================================================================================

Create PROCEDURE [dbo].[usp_GetDailyBendingDefectParetoReport_Backup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATETIME,
						@pToDate DATETIME
						--@pRouteCode VARCHAR(20) = 'E-33',
						--@pMachineRouteCode VARCHAR(20) = 'E-22',
						--@pMaterialCode VARCHAR(20) = 'LIVT38-018',
						--@pDefectCode VARCHAR(20) = 'E-33_5EI'
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
     --      ,@RouteCode VARCHAR(20) = @pRouteCode
		   --,@MachineRouteCode VARCHAR(20) = @pMachineRouteCode
		   --,@MaterialCode VARCHAR(20) = @pMaterialCode
		   --,@DefectCode VARCHAR(20) = @pDefectCode



	SELECT RI.RouteName
		  ,DI.BasicDefectName
		  ,MM.MachineName
		  ,CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) AS DefectQty
	 INTO #DefectQty
	 FROM STB_DefectRepairInfo DRI
	 LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
	 LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode
	 LEFT OUTER JOIN (SELECT ControlNo, RouteCode, MAX(MachineCode) AS MachineCode 
	                    FROM STB_ProdRouteHist
					   GROUP BY ControlNo, RouteCode) PRH
	   ON DRI.ControlNo = PRH.ControlNo
	  AND PRH.RouteCode = 'E-22'
	 LEFT OUTER JOIN STB_MachineMaster MM 
	   ON MM.MachineCode = PRH.MachineCode
	WHERE 1=1
	  AND DRI.DefectCode =  'E-33_5EI'
	  AND DRI.FindRouteCode = 'E-33'
	  AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate	 
	  AND DRI.MaterialCode = 'LIVT38-018'
	  AND DRI.FindRouteCode  = 'E-33'
	 GROUP BY RI.RouteName
			 ,DI.BasicDefectName
			 ,PRH.MachineCode
			 ,MM.MachineName


SELECT KK.RouteName
						  , KK.BasicDefectName
						  , KK.MachineName
						  , KK.DefectQty
						--  , KK.TSum as TSUM
						  , CONVERT(INT, CONVERT(NUMERIC(20, 3), SUM(KK.DefectQty)) 	/ CONVERT(NUMERIC(20, 3), (SUM(KK.DefectQty) OVER ( ORDER BY KK.DefectQty DESC) )) * 1000000) AS DefectRatePPMSum

 FROM (

					SELECT RouteName
						  ,BasicDefectName
						  ,MachineName
						  ,DefectQty
						  ,SUM(DefectQty) OVER ( ORDER BY DefectQty DESC) AS CSum
						  ,TSum

							--,CONVERT(INT, CONVERT(NUMERIC(20, 3), SUM(DefectQty)) 	/ CONVERT(NUMERIC(20, 3), MAX(SUM(DefectQty) OVER ( ORDER BY DefectQty DESC) )) * 1000000) AS DefectRatePPMSum
					  FROM #DefectQty
					  --GROUP BY RouteName
					  --    , BasicDefectName
						 -- , MachineName

					 INNER JOIN (SELECT SUM(DefectQty) AS TSum FROM #DefectQty) A		   ON 1 = 1
	)  KK

GROUP BY  KK.RouteName,  BasicDefectName
						  ,MachineName
						  ,DefectQty


END