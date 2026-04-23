-- ===========================================================================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-02-16
-- Browsable : True
-- Group : 보고서
-- Description:	공정/설비별 불량현황 보고서 (Excel)
-- usp_GetDailyDefectReport '', '', '2022-02-01', '2022-02-02'
-- ============================================================================================================================================
CREATE PROCEDURE [dbo].[usp_GetDailyDefectReport]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATETIME,
						@pToDate DATETIME
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'

	SELECT CONVERT(CHAR(5), FIN.ProdDateTime, 101) AS ProdDateTime
	      ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
		  ,FIN.MachineName
		  ,CONVERT(NUMERIC(20,2), SUM(FIN.InputProdQty)) AS 투입수량
		  ,CONVERT(NUMERIC(20,2), SUM(FIN.ProdQty)) AS 생산수량
		  ,CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty)) AS 불량수량
		  ,CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) AS 불량률
	INTO #DefectReportInfo
	FROM (
		SELECT   TOP 100000
					  PRH.RouteCode
					, RI.RouteName
					, PRH.ProdDateTime
					, LAG(PRH.ProdDateTime) 
							OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
													THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
					, ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
					, ISNULL(MM.MachineName, MM3.MachineName) AS MachineName
					, PRH.ProdQty AS InputProdQty
					, ISNULL(DRI.DefectQty, 0) AS DefectQty 
					, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
			FROM STB_SetInfo SI WITH(NOLOCK) 
					LEFT OUTER JOIN STB_ProdRouteHist    PRH	  WITH(NOLOCK)    ON SI.ControlNo = PRH.ControlNo
					LEFT OUTER JOIN STB_RouteInfo           RI WITH(NOLOCK) 	    ON PRH.RouteCode = RI.RouteCode
					LEFT OUTER JOIN STB_MachineMaster  MM	    WITH(NOLOCK)  ON PRH.MachineCode = MM.MachineCode
					LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 WITH(NOLOCK)     ON PRH.WorkerCode = PWI.WorkerCode
					LEFT OUTER JOIN STB_MaterialMaster  MM2	  WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
					LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK) 	    ON SI.InputLineCode = LI.LineCode
					LEFT OUTER JOIN ( SELECT DRI2.ControlNo
					                        ,DRI2.FindRouteCode
											,MAX(PRH2.MachineCode) AS MachineCode
											,SUM(DRI2.DefectQty) AS DefectQty 
										FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
										LEFT OUTER JOIN STB_ProdRouteHist PRH2
										  ON DRI2.ControlNo = PRH2.ControlNo
										 AND DRI2.FindRouteCode = PRH2.RouteCode
									   WHERE RepairType = 'NONE'
									     AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')
										 AND PRH2.ProdDateTime  BETWEEN @FromDate AND @ToDate
									   GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
											) DRI
					ON PRH.ControlNo = DRI.ControlNo
				   AND PRH.RouteCode = DRI.FindRouteCode
				   AND PRH.MachineCode = DRI.MachineCode
				   LEFT OUTER JOIN (
						SELECT RouteCode, MIN(MachineCode) AS MachineCode
						  FROM STB_ProductMachine
						 GROUP BY RouteCode
				   ) PM
				   ON PM.RouteCode = PRH.RouteCode
				   LEFT OUTER JOIN STB_MachineMaster MM3
				     ON MM3.MachineCode = PM.MachineCode
			WHERE 1=1
			  AND PRH.CompanyCode = 'VNT'
			  AND PRH.WorkCenterCode = 'VNT_F1'
			  AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
			  AND PRH.MaterialCode = 'LIVT38-018'
			ORDER BY SI.Barcode
				,CASE WHEN PRH.RouteCode = 'E-28' THEN 'E-99' ELSE PRH.RouteCode END
	) FIN
	WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
	  AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
	  AND FIN.RouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
	GROUP BY CONVERT(CHAR(5), FIN.ProdDateTime, 101)
	        ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
			,FIN.MachineName 
			--WITH ROLLUP
	HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
	ORDER BY CONVERT(CHAR(5), FIN.ProdDateTime, 101)
	        ,CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
			        WHEN '권취' THEN '01'
					WHEN '조립(커링)' THEN '02'
					WHEN '도핑' THEN '03' 
					WHEN '절곡' THEN '04'
					WHEN '재검' THEN '05'
								ELSE '99' END
	        ,CASE WHEN FIN.MachineName IS NULL THEN '핳' ELSE FIN.MachineName END

	-- UNPIVOT
	SELECT ProdDateTime, RouteName, MachineName, QtyCode, Qty
	  FROM #DefectReportInfo 
	UNPIVOT (

      Qty FOR QtyCode IN (투입수량, 생산수량, 불량수량, 불량률)

   ) AS unpvt
END