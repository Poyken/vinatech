-- ===========================================================================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-02-16
-- Browsable : True
-- Group : 보고서  생산관리 > 4번째 화면
-- Description:	절곡공정 ESR 불량 권취 설비 파레토 (grid & Chart)

-- usp_GetDailyBendingDefectParetoReport '','','2022-02-01','2022-02-23', 'E-33'
-- ============================================================================================================================================

CREATE PROCEDURE [dbo].[usp_GetDailyBendingDefectParetoReport]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATETIME,
						@pToDate DATETIME,
						@pRouteCode VARCHAR(20) = NULL,
						@pMachineRouteCode VARCHAR(20) = 'E-22',
						@pMaterialCode VARCHAR(20) = 'LIVT38-018'
						--@pDefectCode VARCHAR(20) = 'E-33_5EI'
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
           ,@RouteCode VARCHAR(20) = @pRouteCode
		   ,@MachineRouteCode VARCHAR(20) = @pMachineRouteCode
		   ,@MaterialCode VARCHAR(20) = @pMaterialCode
		   ,@DefectCode VARCHAR(20) = NULL -- @pDefectCode



	SELECT RI.RouteName
		  ,DI.BasicDefectName
		  --,MM.MachineName
		  ,CASE WHEN MM.MachineName IS NULL OR MM.MachineName = '셀#1 커링&슬리브기' OR MM.MachineName ='셀7 권취기' THEN '셀#1 권취기' ELSE MM.MachineName END AS MachineName
		  ,CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) AS DefectQty
	 INTO #DefectQty
	 FROM STB_DefectRepairInfo DRI
	 LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
	 LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode
	 LEFT OUTER JOIN (SELECT ControlNo, RouteCode, MAX(MachineCode) AS MachineCode 
	                    FROM STB_ProdRouteHist
					   GROUP BY ControlNo, RouteCode) PRH
	   ON DRI.ControlNo = PRH.ControlNo
	  AND PRH.RouteCode = @MachineRouteCode
	 LEFT OUTER JOIN STB_MachineMaster MM 
	   ON MM.MachineCode = PRH.MachineCode
	WHERE 1=1
	  AND DRI.DefectCode IN ('E-33_5EI', 'E-29_03', 'E-34_ESR')-- @DefectCode
	  AND DRI.FindRouteCode Like @RouteCode
	  AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate	 
	  AND DRI.MaterialCode = @MaterialCode
	  AND DRI.FindRouteCode  = @RouteCode
	GROUP BY RI.RouteName
		 ,DI.BasicDefectName
		 ,PRH.MachineCode
		 ,MM.MachineName

	SELECT RouteName
			,BasicDefectName
			,MachineName
			,DefectQty
			,SUM(DefectQty) OVER ( ORDER BY DefectQty DESC) AS CSum
			,TSum
			,CONVERT(NUMERIC(20,2), SUM(DefectQty) OVER ( ORDER BY DefectQty DESC)) / TSum * 100  AS PPM
		INTO #DefectQty2
		FROM #DefectQty
		INNER JOIN (SELECT SUM(DefectQty) AS TSum FROM #DefectQty) A
		ON 1 = 1

	SELECT MachineName
		    ,SUM(DefectQty) DefectQty
		    ,AVG(PPM) PPM
	  FROM #DefectQty2
	 GROUP BY MachineName
	 ORDER BY DefectQty DESC

END