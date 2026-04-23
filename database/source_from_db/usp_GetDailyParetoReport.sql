-- ===========================================================================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-02-16
-- Browsable : True
-- Group : 보고서
-- Description:	공정별 불량 파래도 보고서 (Excel) & 아래화면 1번째 

--     usp_GetDailyParetoReport '','','2022-02-01','2022-02-20',  Null
-- ============================================================================================================================================

CREATE PROCEDURE [dbo].[usp_GetDailyParetoReport]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATETIME,
						@pToDate DATETIME,
						@pRouteCode VARCHAR(20) = Null
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
           ,@RouteCode VARCHAR(50) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END


		SELECT CONVERT(CHAR(5), DRI.FindDateTime, 101) AS FindDateTime
						--,DRI.FindRouteCode
						,CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END AS RouteName
						--,DRI.DefectCode
						,DI.BasicDefectName
						,CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) AS DefectQty
			INTO #STB_DefectRepairInfo_Temp
			FROM STB_DefectRepairInfo DRI
						LEFT OUTER JOIN STB_RouteInfo RI	    ON RI.RouteCode = DRI.FindRouteCode
						LEFT OUTER JOIN STB_DefectInfo DI	 ON DI.DefectCode = DRI.DefectCode
			WHERE 1=1
			AND DRI.DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12','E-24_ZZ','E-33_ZZ','E-22_QQ','E-23_QQ','E-24_QQ','E-30_04','E-29_05','E-33_5EV','E-22_ZZ')
			AND DRI.FindRouteCode IN ('E-22', 'E-24', 'E-29', 'E-33', 'E-34')
			AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate	 
			AND DRI.MaterialCode = 'LIVT38-018'
			AND DRI.FindRouteCode  LIKE @RouteCode
	   			--AND  (DRI.FindRouteCode = @RouteCode) Or ( @RouteCode like '%') 
			--AND (DRI.FindRouteCode IS NULL OR DRI.FindRouteCode LIKE  '%' + @RouteCode + '%')   

			GROUP BY CONVERT(CHAR(5), DRI.FindDateTime, 101)
					,CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END
					,DI.BasicDefectName

			ORDER BY CONVERT(CHAR(5), DRI.FindDateTime, 101)
					,CASE CASE WHEN DRI.FindRouteCode = 'E-24' THEN '조립(커링)' ELSE RI.RouteName END 
						WHEN '권취' THEN '01'
						WHEN '조립(커링)' THEN '02'
						WHEN '도핑' THEN '03' 
						WHEN '절곡' THEN '04'
						WHEN '재검' THEN '05'
									ELSE '99' END
				,CONVERT(BIGINT, SUM(DRI.DefectQty - DRI.RepairQty)) DESC


		SELECT DRI_T.FindDateTime
		      ,DRI_T.RouteName
			  ,DRI_T.BasicDefectName
			  ,DRI_T.DefectQty
		  FROM #STB_DefectRepairInfo_Temp DRI_T
		 WHERE DRI_T.BasicDefectName <> 'SLEEVING_리드꼬임불량' --2022.02.23 김창길 상무님 제외 요청
		ORDER BY DRI_T.FindDateTime DESC

		DROP TABLE #STB_DefectRepairInfo_Temp

END
