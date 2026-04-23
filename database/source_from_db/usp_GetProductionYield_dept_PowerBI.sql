-- =============================================
-- Author: kilee
-- Create date: 2019-03-05
-- Browsable : true
-- Group : 생산관리
-- Description:	공정별 생산수율을 가져옵니다
-- Modified: 2019.03.05 라인정렬 (kilee)
--           2019.03.07 FromTo 일자 변경  (kilee)
--           2019.12.05 SQL수정 (Kilee)
--           2020.07.27

-- 실행 :   EXEC   usp_GetProductionYield_dept_PowerBI '2020-12-10'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionYield_dept_PowerBI]
						@pJobDate DATE = NULL
AS

BEGIN
   SET NOCOUNT ON;
     --DECLARE @CompanyCode     VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
				 -- @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
				 -- @LineCode           VARCHAR(20) = @pLineCode,		
		DECLARE		  @JobDate             Date = @pJobDate

    --DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END	    
	DECLARE @FromDate DATE              = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate DATE                 = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')
	DECLARE @BefFromDate DATE          = DATEADD(MONTH, 0, @FromDate)                                
	DECLARE @BefToDate DATE             = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))                

	SELECT Z.RouteCode                                                                                               AS RouteCode
			   , Z.RouteName
			   , Z.TotalQty
			   , Z.OutputQty
			   , Z.DefectQty
			   , Z.RepairQty
			   , Z.LossQty		   
			   , Z.TotalRate

	 FROM 
	(
	   SELECT PRS.RouteCode                                                                                               AS RouteCode
			   , RI.RouteName
			   , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
			   , SUM(PRS.OutputQty)                                                                      AS OutputQty
			   , SUM(PRS.DefectQty)                                                                      AS DefectQty
			   , SUM(PRS.RepairQty)                                                                      AS RepairQty
			   , SUM(PRS.LossQty)                                                                        AS LossQty		   
			   --, CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    END     AS TotalRate
			   , 0  AS TotalRate
	    FROM STB_ProdRouteSummary PRS
		LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
	   WHERE 1=1
	     AND TimeCode <> 'E'  
	    -- AND PRS.RouteCode = @RouteCode
		 --AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
	   --AND PRS.JobDate BETWEEN '2019-01-01' AND '2019-01-31'
       AND PRS.RouteCode LIKE 'E%'	     		
       GROUP BY PRS.RouteCode, RI.RouteName
	   ---ORDER BY PRS.RouteCode


	   Union ALL

	  SELECT ''    AS RouteCode
			   , '합계'  AS  RouteName
			   , SUM(A.TotalQty) AS TotalQty
			   , SUM(A.OutputQty)                                                                      AS OutputQty
			 --  , SUM(A.DefectQty)                                                                      AS DefectQty
			   , SUM(B.DefectQty)                                                                      AS DefectQty
			   , SUM(A.RepairQty)                                                                      AS RepairQty
			   , SUM(A.LossQty)                                                                        AS LossQty		   
		       ,  ISNULL(SUM(A.OutputQty), 0) / (SUM(A.OutputQty) + SUM(B.DefectQty) +SUM(A.RepairQty)  + SUM(A.LossQty))  *  100.0 	      AS TotalRate
		FROM
			(	
			 SELECT PRS.RouteCode                                                                                               AS RouteCode
					   , RI.RouteName                                                                                               AS RouteName
						, ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
					   , SUM(PRS.OutputQty)                                                                      AS OutputQty
					   , SUM(PRS.DefectQty)                                                                      AS DefectQty
					   , SUM(PRS.RepairQty)                                                                      AS RepairQty
					   , SUM(PRS.LossQty)                                                                        AS LossQty		   
					   , CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    END     AS TotalRate
				FROM STB_ProdRouteSummary PRS
						 LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
			   WHERE 1=1
				 AND TimeCode <> 'E'  
				 --AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
				 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
				 AND PRS.RouteCode = 'E-22'	     		
			   GROUP BY PRS.RouteCode, RI.RouteName
			   ) A
			, (
			   SELECT 
						  SUM(PRS.DefectQty)                                                                      AS DefectQty
				FROM STB_ProdRouteSummary PRS
						 LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
			   WHERE 1=1
				 AND TimeCode <> 'E'  
				 --AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
				 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
				 AND PRS.RouteCode LIKE 'E%'	     		
			   ) B

WHERE 1=1
GROUP BY A.RouteCode                                                                                         
			   , A.RouteName
    
	) Z
	ORDER BY Z.RouteCode










	   --- 이전거 백업


--SELECT A.RouteCode                                                                                               AS RouteCode
--			   , A.RouteName
--			 --  , SUM(A.TotalQty) AS TotalQty
--			   , SUM(A.OutputQty)                                                                      AS OutputQty
--			 --  , SUM(A.DefectQty)                                                                      AS DefectQty
--			   , SUM(B.DefectQty)                                                                      AS DefectQty_SUM
--			   , SUM(A.RepairQty)                                                                      AS RepairQty
--			   , SUM(A.LossQty)                                                                        AS LossQty		   
--		       ,  ISNULL(SUM(A.OutputQty), 0) / (SUM(A.OutputQty) + SUM(B.DefectQty) +SUM(A.RepairQty)  + SUM(A.LossQty))  *  100.0 	      AS TotalRate
--			    --, CASE WHEN SUM(A.OutputQty)  = 0 THEN 0 ELSE  ISNULL(SUM(A.OutputQty), 0) / (SUM(A.OutputQty) + SUM(B.DefectQty) +SUM(A.RepairQty)  + SUM(A.LossQty))  *  100.0 	    END     AS TotalRate
--FROM
--	(	
--	 SELECT PRS.RouteCode                                                                                               AS RouteCode
--			   , RI.RouteName                                                                                               AS RouteName
--			    , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
--			   , SUM(PRS.OutputQty)                                                                      AS OutputQty
--			  -- , SUM(PRS.DefectQty)                                                                      AS DefectQty
--			   , SUM(PRS.RepairQty)                                                                      AS RepairQty
--			   , SUM(PRS.LossQty)                                                                        AS LossQty		   
--		       , CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    END     AS TotalRate
--	    FROM STB_ProdRouteSummary PRS
--		         LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
--	   WHERE 1=1
--	     AND TimeCode <> 'E'  
--		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
--		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
--         AND PRS.RouteCode LIKE 'E%'	     		
--       GROUP BY PRS.RouteCode, RI.RouteName
--	   ) A
--	, (
--	   SELECT 
--			      SUM(PRS.DefectQty)                                                                      AS DefectQty
--	    FROM STB_ProdRouteSummary PRS
--		         LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
--	   WHERE 1=1
--	     AND TimeCode <> 'E'  
--		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
--		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
--         AND PRS.RouteCode LIKE 'E%'	     		
--	   ) B
--WHERE 1=1
--GROUP BY A.RouteCode                                                                                         
--			   , A.RouteName

--ORDER BY A.RouteCode         




END