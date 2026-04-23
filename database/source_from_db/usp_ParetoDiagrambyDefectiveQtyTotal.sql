
-- =====================================================================================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2022-02-21
-- Browsable : True
-- Group : 생산현황 > VPC 일별공정별불량현황 > 아래 2번째화면 (중간화면) - Grid와 Chart부분
-- Description : 공정별 불량 파래토 

-- 프로시저 실행 :   usp_ParetoDiagrambyDefectiveQtyTotal  'kilee2','Korean', 'E-22', '2022-02-01' ,'2022-02-23'
-- ======================================================================================================

CREATE PROCEDURE [dbo].[usp_ParetoDiagrambyDefectiveQtyTotal]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),							
	@pRouteCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL

AS

BEGIN

	 Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 08:30:00'
	         , @ToDate     DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 08:29:59'
			 , @RouteCode VARCHAR(50) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END

		 SELECT A.RouteName
				, A.BasicDefectName
				, A.DefectQty Qty
				, SUM(B.DefectQty) Qty_Sum
				, CONVERT(NUMERIC(20,2), SUM(B.DefectQty) / C.SUM_Qty  * 100) AS DefectRatePPMSum
		  FROM (
						SELECT ROW_NUMBER() OVER (ORDER BY SUM(DRI.DefectQty - DRI.RepairQty) DESC) AS NUM
								, CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END AS RouteName
   								, DI.BasicDefectName
  								, CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) AS DefectQty
						  FROM STB_DefectRepairInfo DRI
						  LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
						  LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode
						 WHERE 1=1
						   AND DRI.DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12','E-24_ZZ','E-33_ZZ','E-22_QQ','E-23_QQ','E-24_QQ','E-30_04','E-29_05','E-33_5EV','E-22_ZZ')
						   AND DRI.FindRouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
						   AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate
						   AND DRI.MaterialCode = 'LIVT38-018'
						   AND DRI.FindRouteCode = @RouteCode
						 GROUP BY CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END
								     , DI.BasicDefectName
					  ) A
		  INNER JOIN (
							  SELECT ROW_NUMBER() OVER (ORDER BY SUM(DRI.DefectQty - DRI.RepairQty) DESC) AS NUM
									   , CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END AS RouteName
   									   , DI.BasicDefectName
  									   , CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) AS DefectQty
							  FROM STB_DefectRepairInfo DRI
							  LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
							  LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode
							 WHERE 1=1
							   AND DRI.DefectCode NOT IN ('E-22_X03','E-22_X12','E-22_QQ','E-22_ZZ', 'E-23_QQ', 'E-24_QQ','E-24_X03','E-24_X12','E-24_ZZ', 'E-29_05', 'E-33_ZZ', 'E-30_04', 'E-33_5EV' )
							   AND DRI.FindRouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
							   AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate
							   AND DRI.MaterialCode = 'LIVT38-018'
							   AND DRI.FindRouteCode = @RouteCode					
							 GROUP BY CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END
									  ,DI.BasicDefectName
					     ) B ON A.NUM >= B.NUM
	 	 INNER JOIN	(
							SELECT CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) AS DefectQty
									, SUM(DRI.DefectQty) SUM_Qty
							FROM STB_DefectRepairInfo DRI
							LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
							LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode
							WHERE 1=1
							AND DRI.DefectCode NOT IN ('E-22_X03','E-22_X12','E-22_QQ','E-22_ZZ', 'E-23_QQ', 'E-24_QQ','E-24_X03','E-24_X12','E-24_ZZ', 'E-29_05', 'E-33_ZZ', 'E-30_04', 'E-33_5EV' )
							AND DRI.FindRouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
							AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate
							AND DRI.MaterialCode = 'LIVT38-018'
							AND DRI.FindRouteCode = @RouteCode
					    ) C
				 ON 1 = 1
			WHERE 1=1
			  AND A.BasicDefectName NOT IN ('SLEEVING_리드꼬임불량')   -- 예외처리 (2022.02.23 김창길님 요청)
			GROUP BY A.RouteName
						, A.BasicDefectName
						, A.DefectQty
						, C.SUM_Qty
			ORDER BY SUM(B.DefectQty)
	
END