
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-02-22
-- Browsable : True
-- Group : 생산관리 > 생산현황
-- Description: [B658]  Chart부분
-- Modified:  Grid 조회용 프로시저
-- 

--    usp_ProdPerformanceByFacility_Chart  'kilee2','Korean', '', '2022-02-01' ,'2022-02-10'
-- ======================================================================================================
CREATE PROCEDURE [dbo].[usp_ProdPerformanceByFacility_Chart]
									@pProcessUserID VARCHAR(20),
									@pProcessLanguage VARCHAR(20),
									@pRouteCode VARCHAR(20) = Null,
									@pFromDate DATE = NULL,
									@pToDate DATE = NULL
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @RouteCode VARCHAR(50) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END

	DECLARE @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	DECLARE @DiffDate INT = DATEDIFF(DAY,@FromDate,@ToDate)
	DECLARE @PlanQtyName NVARCHAR(100)
	DECLARE @ProdPriorName NVARCHAR(100)
	DECLARE @PlanCTName NVARCHAR(100)
	Declare @First_Table TABLE (
		RouteName VARCHAR(20)
	   ,MachineNAme VARCHAR(20)
	   ,QtyCode VARCHAR(20)
	   ,NumericField INT
	   ,Qty NUMERIC(20,2)
	);
	

 SELECT   TOP 100000
                 PRH.RouteCode
               , RI.RouteName
               , PRH.ProdDateTime
               , LAG(PRH.ProdDateTime) 
                     OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
                                       THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
               , ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
               --, ISNULL(MM.MachineName, MM3.MachineName) AS MachineName
			     , CASE WHEN RI.RouteCode = 'E-22' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '권취1호기' OR MM.MachineName = '셀#5 권취기' OR MM.MachineName = '셀#1 커링&슬리브기') THEN '셀#1 권취기'
			          WHEN RI.RouteCode = 'E-24' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '셀#1 커링&슬리브기' OR MM.MachineName = '셀2 조립기' OR MM.MachineName = '소형고무전삽입 1호기') THEN '셀#1 조립기'
					  WHEN RI.RouteCode = 'E-29' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '자동절곡#1' OR MM.MachineName = '자동절곡#2') THEN '소형VPC도핑&선별1호'
					  WHEN RI.RouteCode = 'E-33' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '소형VPC도핑&선별1호' OR MM.MachineName = '소형VPC도핑&선별2호') THEN '자동절곡#1'
					  ELSE ISNULL(MM.MachineName, MM3.MachineName) END AS MachineName
               , PRH.ProdQty AS InputProdQty
               , ISNULL(DRI.DefectQty, 0) AS DefectQty 
               , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		 INTO #DefectReportInfo_Test
         FROM STB_SetInfo SI WITH(NOLOCK) 
               LEFT OUTER JOIN STB_ProdRouteHist    PRH     WITH(NOLOCK)    ON SI.ControlNo = PRH.ControlNo
               LEFT OUTER JOIN STB_RouteInfo           RI WITH(NOLOCK)        ON PRH.RouteCode = RI.RouteCode
               LEFT OUTER JOIN STB_MachineMaster  MM       WITH(NOLOCK)  ON PRH.MachineCode = MM.MachineCode
               LEFT OUTER JOIN STB_ProdWorkerInfo PWI    WITH(NOLOCK)     ON PRH.WorkerCode = PWI.WorkerCode
               LEFT OUTER JOIN STB_MaterialMaster  MM2     WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
               LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)        ON SI.InputLineCode = LI.LineCode
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
                               --AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
							   AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
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
           --AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
		   AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
           AND PRH.MaterialCode = 'LIVT38-018'
         ORDER BY SI.Barcode
            ,CASE WHEN PRH.RouteCode = 'E-28' THEN 'E-99' ELSE PRH.RouteCode END


	   SELECT CONVERT(DATE, FIN.ProdDateTime, 121) AS ProdDateTime
			 ,RouteCode 
			 ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
			 ,FIN.MachineName AS MachineName
			 ,CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) AS 불량률
	   FROM #DefectReportInfo_Test FIN
	   WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
		 AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
		 AND FIN.RouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
		  AND FIN.RouteCode  LIKE @RouteCode
	   GROUP BY CONVERT(DATE, FIN.ProdDateTime, 121)
			, RouteCode 
			   ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
			 ,FIN.MachineName 
			 --WITH ROLLUP
	   HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL

	   UNION ALL

	   SELECT CONVERT(DATE, FIN.ProdDateTime, 121) AS ProdDateTime
			 ,RouteCode 
			 ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
			 ,'Total' AS MachineName
			 ,CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) AS 불량률
	   FROM #DefectReportInfo_Test FIN
	   WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
		 AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
		 AND FIN.RouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
		  AND FIN.RouteCode LIKE @RouteCode
	   GROUP BY CONVERT(DATE, FIN.ProdDateTime, 121)
			, RouteCode 
			   ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
			 --,FIN.MachineName 
			 --WITH ROLLUP
	   HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
	   ORDER BY CONVERT(DATE, FIN.ProdDateTime, 121)


	DROP TABLE #DefectReportInfo_Test


   --SELECT CONVERT(CHAR(10), FIN.ProdDateTime, 120) AS ProdDateTime
   --      , RouteCode 
   --      ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
   --     ,FIN.MachineName
   --     ,CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) AS 불량률

   --FROM (
   --   SELECT   TOP 100000
   --              PRH.RouteCode
   --            , RI.RouteName
   --            , PRH.ProdDateTime
   --            , LAG(PRH.ProdDateTime) 
   --                  OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
   --                                    THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
   --            , ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
   --            --, ISNULL(MM.MachineName, MM3.MachineName) AS MachineName
			--     , CASE WHEN RI.RouteCode = 'E-22' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '권취1호기' OR MM.MachineName = '셀#5 권취기' OR MM.MachineName = '셀#1 커링&슬리브기') THEN '셀#1 권취기'
			--          WHEN RI.RouteCode = 'E-24' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '셀#1 커링&슬리브기' OR MM.MachineName = '셀2 조립기' OR MM.MachineName = '소형고무전삽입 1호기') THEN '셀#1 조립기'
			--		  WHEN RI.RouteCode = 'E-29' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '자동절곡#1' OR MM.MachineName = '자동절곡#2') THEN '소형VPC도핑&선별1호'
			--		  WHEN RI.RouteCode = 'E-33' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '소형VPC도핑&선별1호' OR MM.MachineName = '소형VPC도핑&선별2호') THEN '자동절곡#1'
			--		  ELSE ISNULL(MM.MachineName, MM3.MachineName) END AS MachineName
   --            , PRH.ProdQty AS InputProdQty
   --            , ISNULL(DRI.DefectQty, 0) AS DefectQty 
   --            , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
   --      FROM STB_SetInfo SI WITH(NOLOCK) 
   --            LEFT OUTER JOIN STB_ProdRouteHist    PRH     WITH(NOLOCK)    ON SI.ControlNo = PRH.ControlNo
   --            LEFT OUTER JOIN STB_RouteInfo           RI WITH(NOLOCK)        ON PRH.RouteCode = RI.RouteCode
   --            LEFT OUTER JOIN STB_MachineMaster  MM       WITH(NOLOCK)  ON PRH.MachineCode = MM.MachineCode
   --            LEFT OUTER JOIN STB_ProdWorkerInfo PWI    WITH(NOLOCK)     ON PRH.WorkerCode = PWI.WorkerCode
   --            LEFT OUTER JOIN STB_MaterialMaster  MM2     WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
   --            LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)        ON SI.InputLineCode = LI.LineCode
   --            LEFT OUTER JOIN ( SELECT DRI2.ControlNo
   --                                    ,DRI2.FindRouteCode
   --                              ,MAX(PRH2.MachineCode) AS MachineCode
   --                              ,SUM(DRI2.DefectQty) AS DefectQty 
   --                           FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
   --                           LEFT OUTER JOIN STB_ProdRouteHist PRH2
   --                             ON DRI2.ControlNo = PRH2.ControlNo
   --                            AND DRI2.FindRouteCode = PRH2.RouteCode
   --                           WHERE RepairType = 'NONE'
   --                             AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')
   --                            AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
   --                           GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
   --                              ) DRI
   --            ON PRH.ControlNo = DRI.ControlNo
   --            AND PRH.RouteCode = DRI.FindRouteCode
   --            AND PRH.MachineCode = DRI.MachineCode
   --            LEFT OUTER JOIN (
   --               SELECT RouteCode, MIN(MachineCode) AS MachineCode
   --                 FROM STB_ProductMachine
   --                GROUP BY RouteCode
   --            ) PM
   --            ON PM.RouteCode = PRH.RouteCode
   --            LEFT OUTER JOIN STB_MachineMaster MM3
   --              ON MM3.MachineCode = PM.MachineCode
   --      WHERE 1=1
   --        AND PRH.CompanyCode = 'VNT'
   --        AND PRH.WorkCenterCode = 'VNT_F1'
   --        AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
   --        AND PRH.MaterialCode = 'LIVT38-018'
   --      ORDER BY SI.Barcode
   --         ,CASE WHEN PRH.RouteCode = 'E-28' THEN 'E-99' ELSE PRH.RouteCode END
   --) FIN
   --WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
   --  AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
   --  AND FIN.RouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
	  --AND FIN.RouteCode  LIKE @RouteCode

   --GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
   --     , RouteCode 
   --        ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
   --      ,FIN.MachineName 
   --      --WITH ROLLUP
   --HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
   --ORDER BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
   --        ,CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
   --              WHEN '권취' THEN '01'
   --            WHEN '조립(커링)' THEN '02'
   --            WHEN '도핑' THEN '03' 
   --            WHEN '절곡' THEN '04'
   --            WHEN '재검' THEN '05'
   --                     ELSE '99' END
   --        ,CASE WHEN FIN.MachineName IS NULL THEN '핳' ELSE FIN.MachineName END



END