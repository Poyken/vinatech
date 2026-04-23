-- =============================================
-- Author: Kevin Nguyễn
-- Create date: 2020-07-27
-- Browsable : true
-- Group : EA team
-- Description:	Development for Mr. Hung production, check Input, Output, defectqty
--    EXEC   usp_GetProductionYield_dept '','','VNT','','','','2019-12-05'
-- =============================================
CREATE PROCEDURE [dbo].[VN_PERFORMANCE_PRODUCTION_STAGE_GRAPHICH]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL
AS

BEGIN
   SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END,
				@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
				@LineCode VARCHAR(20) = @pLineCode,		-- 라인별 카렌더가 다르면 전일이 다를수 있음
				--@RouteCode VARCHAR(20) = @pRouteCode,
				@JobDate DATE = @pJobDate


  DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
--((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
			    
	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate DATE    = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')

	 
	
	--DECLARE @BefFromDate DATE = DATEADD(MONTH,-1,@FromDate)   -- 기존소스 백업 (지우지말것)
	--DECLARE @BefToDate DATE   = DATEADD(DAY,-1,@FromDate)     -- 기존소스 백업 (지우지말것)

	--[FROM_DATE검증방법] 화면의년월일기입 : 2019-03-07 이면  SELECT  SUBSTRING(CONVERT(VARCHAR,'2019-03-07',120),1,8) + '01'                                    ->  SELECT DATEADD(MONTH, 0,'2019-03-01')
	--[TO DATE검증방법]   화면의년월일기입 :                  SELECT  DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,'2019-03-07'),120),1,8) + '01')   ->  SELECT  DATEADD(DAY,-1,'2019-03-01')   -> SELECT  DATEADD(DAY, -1, (DATEADD(MONTH,1,'2019-03-01')))


	DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                  --- kilee수정 (2019.03.07)
	--DECLARE @BefToDate DATE   = DATEADD(DAY  ,-1, @FromDate)
	DECLARE @BefToDate DATE   = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))                --- kilee수정 (2019.03.07)

	



-- EXEC usp_GetProductionYield_dept '','','','','','','2018-03-05'



	
	  --SELECT PRS.ROUTECODE     AS RouteCode
	  --     , CASE WHEN PRS.ROUTECODE = 'E-22' THEN '권취' 
		 --         WHEN PRS.ROUTECODE = 'E-24' THEN '커링' 
			--	  WHEN PRS.ROUTECODE = 'E-25' THEN '슬리빙' 
			--	  WHEN PRS.ROUTECODE = 'E-26' THEN '에이징' 
			--	  WHEN PRS.ROUTECODE = 'E-27' THEN '외관' 
			--	  WHEN PRS.ROUTECODE = 'E-28' THEN '포장' 
			--	  WHEN PRS.ROUTECODE = 'E-33' THEN '절곡'    ELSE '기타' END          AS RouteName
		 --  , ROUND(SUM(PRS.INPUTQTY),2)     AS TotalQty
		 --  , SUM(PRS.OUTPUTQTY)    AS OutputQty
		 --  , SUM(PRS.DEFECTQTY)    AS DefectQty
		 --  , SUM(PRS.RepairQty)     AS RepairQty		   
		 --  , ISNULL(SUM(PRS.INPUTQTY),0) * 100.0 / (ISNULL(SUM(PRS.OutputQty),0) + ISNULL(SUM(PRS.DefectQty),0) + ISNULL(SUM(PRS.RepairQty),0) + ISNULL(SUM(PRS.LossQty),0))  AS TotalRate
	  --  FROM STB_ProdRouteSummary PRS
	  -- WHERE 1=1
	  --   --AND PRS.RouteCode = @RouteCode
		 ----AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
		 --AND PRS.JobDate BETWEEN '2016-01-01' AND '2018-12-31'
	  --   AND PRS.SHIFTCODE = '3'    --과거 ERP DATA
   --    GROUP BY PRS.RouteCode
	  -- ORDER BY PRS.RouteCode
		 
		
	 SELECT PRS.RouteCode  AS RouteCode  ,RI.RouteName                                                                                            
	    -- , ''     AS RouteName  )
		  
		   --, ROUND(SUM(PRS.INPUTQTY),2)                                                             AS TotalQty
		    , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
		   , SUM(PRS.OutputQty)                                                                      AS OutputQty
		   , SUM(PRS.DefectQty)                                                                      AS DefectQty
		   , SUM(PRS.RepairQty)                                                                      AS RepairQty
		   , SUM(PRS.LossQty)                                                                        AS LossQty		   
		 --  , ISNULL(SUM(PRS.INPUTQTY),0) * 100.0 / (ISNULL(SUM(PRS.OutputQty),0) + ISNULL(SUM(PRS.DefectQty),0) + ISNULL(SUM(PRS.RepairQty),0) + ISNULL(SUM(PRS.LossQty),0))   AS TotalRate2		   
		   --, ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0                     AS TotalRate
		   --, CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  / ISNULL(SUM(PRS.OutputQty), 0) *  100.0 	    END     AS TotalRate
		     , CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    END     AS TotalRate
	  INTO #Tbl
	  FROM STB_ProdRouteSummary PRS
			LEFT OUTER JOIN STB_RouteInfo RI
		  ON PRS.RouteCode = RI.RouteCode
	   WHERE 1=1
	     AND TimeCode <> 'V'  
	    -- AND PRS.RouteCode = @RouteCode

		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate

	   --AND PRS.JobDate BETWEEN '2019-01-01' AND '2019-01-31'
         AND PRS.RouteCode LIKE 'V%'	     		
       GROUP BY PRS.RouteCode, RI.RouteName
	   ORDER BY PRS.RouteCode


	   SELECT
				  RouteName,
				  SUM(TotalQty) OVER (PARTITION BY RouteName ORDER BY RouteName) AS TotalQty,
				  SUM(OutputQty) OVER (PARTITION BY RouteName ORDER BY RouteName) AS OutputQty,
				  SUM(DefectQty) OVER (PARTITION BY RouteName ORDER BY RouteName) AS DefectQty
	   FROM
				#Tbl



	   -- [변수제외 테스트 SQL]
	  -- SELECT PRS.ROUTECODE                                                                            AS RouteCode	    
		 --  ,  (SELECT X.공정명 FROM ERPSVR.ERPDB.DBO.공정코드 X WHERE X.공정코드 = PRS.ROUTECODE)      AS RouteName
		 --  , ROUND(SUM(PRS.INPUTQTY),2)     AS TotalQty
		 --  , SUM(PRS.OUTPUTQTY)                                                                      AS OutputQty
		 --  , SUM(PRS.DEFECTQTY)                                                                      AS DefectQty
		 --  , SUM(PRS.RepairQty)                                                                      AS RepairQty
		 --  , SUM(PRS.LOSSQty)                                                                        AS LOSSQty		   
		 ----  , ISNULL(SUM(PRS.INPUTQTY),0) * 100.0 / (ISNULL(SUM(PRS.OutputQty),0) + ISNULL(SUM(PRS.DefectQty),0) + ISNULL(SUM(PRS.RepairQty),0) + ISNULL(SUM(PRS.LossQty),0))   AS TotalRate2		   
		 --  , ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0                     AS TotalRate
	  --  FROM STB_ProdRouteSummary PRS
	  -- WHERE 1=1
	  --   AND PRS.SHIFTCODE = '3'                                         -- 과거 ERP DATA	    
		 ----AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 		 
	  --   AND PRS.JobDate BETWEEN '2019-03-01' AND '2019-03-31'	     		
   --    GROUP BY PRS.RouteCode
	   --ORDER BY PRS.RouteCode

		
END


--SELECT * FROM STB_LineRouteMapping

 --   SELECT * FROM STB_ProdRouteSummary WHERE SHIFTCODE = '3'

 -- SELECT 공정명 FROM ERPSVR.ERPDB.DBO.공정코드