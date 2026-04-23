-- =============================================
-- Author: Kevin Nguy?n
-- Create date: 2020-07-27
-- Browsable : true
-- Group : EA team
-- Description:	Development for Mr. Hung production, check Input, Output, defectqty
--    EXEC   usp_GetProductionYield_dept '','','VNT','','','','2019-12-05'
-- =============================================
CREATE PROCEDURE [dbo].[VN_PERFORMANCE_PRODUCTION_CELLLINE]
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
				@LineCode VARCHAR(20) = @pLineCode,		-- ??? ???? ??? ??? ??? ??
				--@RouteCode VARCHAR(20) = @pRouteCode,
				@JobDate DATE = @pJobDate


  DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
--((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
			    
	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate DATE    = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')

	 
	
	--DECLARE @BefFromDate DATE = DATEADD(MONTH,-1,@FromDate)   -- ???? ?? (?????)
	--DECLARE @BefToDate DATE   = DATEADD(DAY,-1,@FromDate)     -- ???? ?? (?????)

	--[FROM_DATE????] ???????? : 2019-03-07 ??  SELECT  SUBSTRING(CONVERT(VARCHAR,'2019-03-07',120),1,8) + '01'                                    ->  SELECT DATEADD(MONTH, 0,'2019-03-01')
	--[TO DATE????]   ???????? :                  SELECT  DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,'2019-03-07'),120),1,8) + '01')   ->  SELECT  DATEADD(DAY,-1,'2019-03-01')   -> SELECT  DATEADD(DAY, -1, (DATEADD(MONTH,1,'2019-03-01')))


	DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                  --- kilee?? (2019.03.07)
	--DECLARE @BefToDate DATE   = DATEADD(DAY  ,-1, @FromDate)
	DECLARE @BefToDate DATE   = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))                --- kilee?? (2019.03.07)

	



-- EXEC VN_PERFORMANCE_PRODUCTION_CELLLINE '','','','','','','2020-07-31'



	
	  --SELECT PRS.ROUTECODE     AS RouteCode
	  --     , CASE WHEN PRS.ROUTECODE = 'E-22' THEN '??' 
		 --         WHEN PRS.ROUTECODE = 'E-24' THEN '??' 
			--	  WHEN PRS.ROUTECODE = 'E-25' THEN '???' 
			--	  WHEN PRS.ROUTECODE = 'E-26' THEN '???' 
			--	  WHEN PRS.ROUTECODE = 'E-27' THEN '??' 
			--	  WHEN PRS.ROUTECODE = 'E-28' THEN '??' 
			--	  WHEN PRS.ROUTECODE = 'E-33' THEN '??'    ELSE '??' END          AS RouteName
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
	  --   AND PRS.SHIFTCODE = '3'    --?? ERP DATA
   --    GROUP BY PRS.RouteCode
	  -- ORDER BY PRS.RouteCode
		 
		
	 SELECT PRS.RouteCode  AS RouteCode  ,RI.RouteName, LI.LineName                                                                                         
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
	    FROM STB_ProdRouteSummary PRS
			LEFT OUTER JOIN STB_RouteInfo RI
			 ON PRS.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_LineInfo LI
		  ON PRS.LineCode=LI.LineCode
	   WHERE 1=1
	     AND TimeCode <> 'V'  
		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
         AND PRS.RouteCode LIKE 'V%'	     		
       GROUP BY PRS.RouteCode, RI.RouteName, LI.LineName   
	   ORDER BY PRS.RouteCode

END


--SELECT * FROM STB_LineRouteMapping

 --   SELECT * FROM STB_ProdRouteSummary WHERE SHIFTCODE = '3'

 -- SELECT ??? FROM ERPSVR.ERPDB.DBO.????