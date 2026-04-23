
-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2022-02-21
-- Browsable : True
-- Group : 생산현황 > 일별 공정별 생산실적 > 3번째 화면
-- Description:	 공정별 불량 파래토 

--    usp_ParetoDiagrambyDefectiveQty  'kilee2','Korean', '', '2022-02-01' ,'2022-02-20'
-- ======================================================================================================
Create PROCEDURE [dbo].[usp_ParetoDiagrambyDefectiveQty_Back]
									@pProcessUserID VARCHAR(20),
									@pProcessLanguage VARCHAR(20),							
									@pRouteCode VARCHAR(20) = NULL,
									@pFromDate DATE = NULL,
									@pToDate DATE = NULL
AS

BEGIN
	 Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	              , @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
				 ,@RouteCode VARCHAR(50) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END

	SELECT  DI.BasicDefectName
	, DRI.DefectCode 
				   , Max(DRI.FindRouteCode) As RouteCode
				  ,CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END AS RouteName
				  , ISnull(CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)), 0) AS DefectQty


	  FROM STB_DefectRepairInfo DRI
	  LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
	  LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode

	 WHERE 1=1
	   AND DRI.DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12','E-22_QQ')    --파괴검사,샘플진행, 장비셋업는 제외해야 함
	   AND DRI.FindRouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
	   AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate
	--    AND (DRI.FindRouteCode = @RouteCode) Or ( @RouteCode = '*')
		   AND DRI.FindRouteCode  LIKE @RouteCode
	   AND DRI.MaterialCode = 'LIVT38-018'

	 GROUP BY  
			 DI.BasicDefectName
			 , CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName End
			 ,  DRI.DefectCode 
	 ORDER BY
	         CASE CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END 
			        WHEN '권취' THEN '01'
					WHEN '조립(커링)' THEN '02'
					WHEN '도핑' THEN '03' 
					WHEN '절곡' THEN '04'
					WHEN '재검' THEN '05'
								ELSE '99' END
			,CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) DESC

END