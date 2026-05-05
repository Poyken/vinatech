-- =============================================
-- Author: kilee
-- Create date: 2019-03-07
-- Browsable : true
-- Group : 생산관리
-- Description:	공정별 생산수율 상세(detail)
-- Modified:
-- =============================================
--exec usp_GetProductionYield_dept2 '','',null, null, null, null, '2019-01-15'

Create PROCEDURE [dbo].[usp_GetProductionYield_dept2_20220121]
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

	DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			@LineCode       VARCHAR(20) = @pLineCode,		-- 라인별 카렌더가 다르면 전일이 다를수 있음
			--@RouteCode VARCHAR(20) = @pRouteCode,
			@JobDate        DATE = @pJobDate


  DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
--((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
			    
	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate   DATE = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')

	--DECLARE @BefFromDate DATE = DATEADD(MONTH,-1,@FromDate)   -- 기존소스 백업 (지우지말것)
	--DECLARE @BefToDate DATE   = DATEADD(DAY,-1,@FromDate)     -- 기존소스 백업 (지우지말것)

	--[FROM_DATE검증방법] 화면의년월일기입 : 2019-03-07 이면  SELECT  SUBSTRING(CONVERT(VARCHAR,'2019-03-07',120),1,8) + '01'                                    ->  SELECT DATEADD(MONTH, 0,'2019-03-01')
	--[TO DATE검증방법]   화면의년월일기입 :                  SELECT  DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,'2019-03-07'),120),1,8) + '01')   ->  SELECT  DATEADD(DAY,-1,'2019-03-01')   -> SELECT  DATEADD(DAY, -1, (DATEADD(MONTH,1,'2019-03-01')))


	DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                  --- kilee수정 (2019.03.07)
	--DECLARE @BefToDate DATE   = DATEADD(DAY  ,-1, @FromDate)
	DECLARE @BefToDate DATE   = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))                --- kilee수정 (2019.03.07)

	


	--SELECT DATEADD(MONTH,1,'201903')

-- EXEC usp_GetProductionYield_dept '','','','','','','2018-03-05'


		 
		
	 SELECT RIGHT(CONVERT(varchar(30), PRS.JOBDATE,120),2)  + '일'   AS DDAY 
	       , PRS.RouteCode                                                                           AS RouteCode
	    -- , ''     AS RouteName
		   , RI.RouteName
		   , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DEFECTQTY) +SUM(PRS.RepairQty)  + SUM(PRS.LOSSQty) , 2)                            AS TotalQty
		   , SUM(PRS.OutputQty)                                                                      AS OutputQty
		   , SUM(PRS.DefectQty)                                                                      AS DefectQty
		   , SUM(PRS.RepairQty)                                                                      AS RepairQty
		   , SUM(PRS.LossQty)                                                                        AS LossQty		    
		 --  , ISNULL(SUM(PRS.INPUTQTY),0) * 100.0 / (ISNULL(SUM(PRS.OutputQty),0) + ISNULL(SUM(PRS.DefectQty),0) + ISNULL(SUM(PRS.RepairQty),0) + ISNULL(SUM(PRS.LossQty),0))   AS TotalRate2		   
		  
		  -- , ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0                     AS TotalRate
			   , CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    END     AS TotalRate
			,PRS.MaterialCode
			,MM.MaterialName
	    FROM STB_ProdRouteSummary PRS
		LEFT OUTER JOIN STB_RouteInfo RI
		  ON PRS.RouteCode = RI.RouteCode
		LEFT OUTER JOIN STB_MaterialMaster MM
		  ON MM.MaterialCode = PRS.MaterialCode
	   WHERE 1=1
		 AND TimeCode <> 'E'     
		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
       GROUP BY PRS.RouteCode, RI.RouteName, PRS.JOBDATE, PRS.MaterialCode, MM.MaterialName
	   ORDER BY PRS.JOBDATE, PRS.RouteCode

		
END
