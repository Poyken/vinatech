
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-02-17
-- Browsable : True
-- Group : 생산관리 > 생산현황
-- Description: [B657] 일별공정별설비별_생산실적
-- Modified:  Grid 조회용 프로시저
-- 전체 PO가 아니라 현재를 기준으로 2개월 전부터 미래일자의 PO가 조회되도록 개선 (2019.05.13 kilee 수정, 2019.08.30 By Jackaroe)
-- 계획수량 입력 컬럼의 날짜 포멧을 년월일에서 월일로 변경. 2019.09.27 주영진 요청 , By Jackaroe 롤백

--   usp_DefectiveQuantityCounting  'kilee2','Korean', '2022-02-01' ,'2022-02-10'
-- ======================================================================================================
CREATE PROCEDURE [dbo].[usp_DefectiveQuantityCounting]
									@pProcessUserID VARCHAR(20),
									@pProcessLanguage VARCHAR(20),
									@pFromDate DATE = NULL,
									@pToDate DATE = NULL
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	DECLARE @DiffDate INT = DATEDIFF(DAY,@FromDate,@ToDate)
	DECLARE @PlanQtyName NVARCHAR(100)
	DECLARE @ProdPriorName NVARCHAR(100)
	DECLARE @PlanCTName NVARCHAR(100)
	


-- [첫번째] 화면에서 틀 고정된 부분
SELECT CONVERT(CHAR(10), FIN.ProdDateTime, 120) AS ProdDateTime
         ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
        -- , FIN.MachineName
        -- , CONVERT(NUMERIC(20,2), SUM(FIN.InputProdQty)) AS 투입수량
        --, CONVERT(NUMERIC(20,2), SUM(FIN.ProdQty)) AS 생산수량
        , CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty)) AS 불량수량
        --, CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) AS 불량률
		, DefectName As DefectName
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
								   , DRI.DefectName AS DefectName
							 FROM STB_SetInfo SI WITH(NOLOCK) 
								   LEFT OUTER JOIN STB_ProdRouteHist    PRH     WITH(NOLOCK)    ON SI.ControlNo = PRH.ControlNo
								   LEFT OUTER JOIN STB_RouteInfo           RI WITH(NOLOCK)        ON PRH.RouteCode = RI.RouteCode
								   LEFT OUTER JOIN STB_MachineMaster  MM       WITH(NOLOCK)  ON PRH.MachineCode = MM.MachineCode
								   LEFT OUTER JOIN STB_ProdWorkerInfo PWI    WITH(NOLOCK)     ON PRH.WorkerCode = PWI.WorkerCode
								   LEFT OUTER JOIN STB_MaterialMaster  MM2     WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
								   LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)        ON SI.InputLineCode = LI.LineCode
								   LEFT OUTER JOIN ( SELECT DRI2.ControlNo
																					   , DRI2.FindRouteCode
																				 , MAX(PRH2.MachineCode) AS MachineCode
																				 , SUM(DRI2.DefectQty) AS DefectQty
																				 , SD.BasicDefectName AS DefectName 
																			  FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
																			  LEFT OUTER JOIN STB_ProdRouteHist PRH2															ON DRI2.ControlNo = PRH2.ControlNo														   AND DRI2.FindRouteCode = PRH2.RouteCode
																			  LEFT OUTER JOIN STB_DefectInfo SD    ON SD.DefectCode = DRI2.DefectCode
																			  WHERE RepairType = 'NONE'
																				AND DRI2.DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')
																			   AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
																			  GROUP BY DRI2.ControlNo, DRI2.FindRouteCode, SD.BasicDefectName
																	 ) DRI
								   ON PRH.ControlNo = DRI.ControlNo               AND PRH.RouteCode = DRI.FindRouteCode               AND PRH.MachineCode = DRI.MachineCode

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
	 AND CONVERT(CHAR(10), FIN.ProdDateTime, 120) ='2022-02-02'
   GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
           , CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
       --  ,FIN.MachineName 
		 , DefectName
         --WITH ROLLUP
   HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
   ORDER BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
					   ,CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
							 WHEN '권취' THEN '01'
						   WHEN '조립(커링)' THEN '02'
						   WHEN '도핑' THEN '03' 
						   WHEN '절곡' THEN '04'
						   WHEN '재검' THEN '05'
									ELSE '99' END
					  -- ,CASE WHEN FIN.MachineName IS NULL THEN '핳' ELSE FIN.MachineName END


  /* SELECT CONVERT(CHAR(10), FIN.ProdDateTime, 120) AS ProdDateTime
         ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
         , FIN.MachineName
         , CONVERT(NUMERIC(20,2), SUM(FIN.InputProdQty)) AS 투입수량
        , CONVERT(NUMERIC(20,2), SUM(FIN.ProdQty)) AS 생산수량
        , CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty)) AS 불량수량
        , CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) AS 불량률
   INTO #DefectReportInfo_Test
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
			   , DRI.DefectName AS DefectName
         FROM STB_SetInfo SI WITH(NOLOCK) 
               LEFT OUTER JOIN STB_ProdRouteHist    PRH     WITH(NOLOCK)    ON SI.ControlNo = PRH.ControlNo
               LEFT OUTER JOIN STB_RouteInfo           RI WITH(NOLOCK)        ON PRH.RouteCode = RI.RouteCode
               LEFT OUTER JOIN STB_MachineMaster  MM       WITH(NOLOCK)  ON PRH.MachineCode = MM.MachineCode
               LEFT OUTER JOIN STB_ProdWorkerInfo PWI    WITH(NOLOCK)     ON PRH.WorkerCode = PWI.WorkerCode
               LEFT OUTER JOIN STB_MaterialMaster  MM2     WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
               LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)        ON SI.InputLineCode = LI.LineCode
               LEFT OUTER JOIN ( SELECT DRI2.ControlNo
																   , DRI2.FindRouteCode
															 , MAX(PRH2.MachineCode) AS MachineCode
															 , SUM(DRI2.DefectQty) AS DefectQty
															 , SD.BasicDefectName AS DefectName 
														  FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
														  LEFT OUTER JOIN STB_ProdRouteHist PRH2															ON DRI2.ControlNo = PRH2.ControlNo														   AND DRI2.FindRouteCode = PRH2.RouteCode
														  LEFT OUTER JOIN STB_DefectInfo SD    ON SD.DefectCode = DRI2.DefectCode
														  WHERE RepairType = 'NONE'
															AND DRI2.DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')
														   AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
														  GROUP BY DRI2.ControlNo, DRI2.FindRouteCode, SD.BasicDefectName
												 ) DRI
               ON PRH.ControlNo = DRI.ControlNo               AND PRH.RouteCode = DRI.FindRouteCode               AND PRH.MachineCode = DRI.MachineCode

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
   GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
           ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
         ,FIN.MachineName 
         --WITH ROLLUP
   HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
   ORDER BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
					   ,CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
							 WHEN '권취' THEN '01'
						   WHEN '조립(커링)' THEN '02'
						   WHEN '도핑' THEN '03' 
						   WHEN '절곡' THEN '04'
						   WHEN '재검' THEN '05'
									ELSE '99' END
					   ,CASE WHEN FIN.MachineName IS NULL THEN '핳' ELSE FIN.MachineName END

		   -- 첫번째 메인
		   select * from #DefectReportInfo_Test 


			--SELECT  ProdDateTime As PlanDate
			--			, RouteName
			--			--, DefectName As DefectName
			--			, ISNULL(MachineName, '') MachineName
			--			, QtyCode					
			-- FROM #DefectReportInfo_Test 
		 --  UNPIVOT (
			--					  Qty FOR QtyCode IN (투입수량, 생산수량, 불량수량, 불량률)
			--				   ) AS unpvt
   --        WHERE 1=1


Drop Table #DefectReportInfo_Test
*/

END