-- =============================================
-- Author: kilee
-- Create date: 2019-03-05
-- Browsable : true
-- Group : 생산관리
-- Description:	일자별 라인별 공정별 생산수율을 가져옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionYield_Total]
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

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END,
				@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END,
				@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END,
				@JobDate DATE = @pJobDate,
				@FromDate DATE,
				@ToDate DATE

	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
			    
	SELECT @FromDate = FromDate
	      ,@ToDate = ToDate
	  FROM SmartFactoryV2.dbo.STB_AggregationPeriod
	 WHERE BaseMonth = CONVERT(CHAR(7), @JobDate, 121)
		
	 SELECT PRS.JobDate
	       ,PRS.LineCode
		   ,LI.LineName
		  -- ,LI.LineDesc As LineName
	       ,PRS.RouteCode
	       ,RI.RouteName
		   ,ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2) AS TotalQty
		   ,SUM(PRS.OutputQty) AS OutputQty
		   ,SUM(PRS.DefectQty) AS DefectQty
		   ,SUM(PRS.RepairQty) AS RepairQty
		   ,SUM(PRS.LossQty) AS LossQty		   
		   ,CASE  WHEN (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) + SUM(PRS.RepairQty)  + SUM(PRS.LossQty))   = 0 
		          THEN 0 
				  ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) 
				             + SUM(PRS.DefectQty) + SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    
				  END AS TotalRate
	    FROM STB_ProdRouteSummary PRS
				LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
				LEFT OUTER JOIN STB_LineInfo LI		  ON LI.LineCode = PRS.LineCode
	   WHERE 1=1
	     AND PRS.JobDate BETWEEN @FromDate AND @ToDate
		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
		 AND (@CompanyCode = '*' OR PRS.CompanyCode = @CompanyCode)
		 AND (@WorkCenterCode = '*' OR PRS.WorkCenterCode = @WorkCenterCode)
		 AND (@LineCode = '*' OR PRS.LineCode = @LineCode)
         AND RI.IsUsed = 1
       GROUP BY PRS.JobDate
			   ,PRS.LineCode
			   ,LI.LineName
			   ,PRS.RouteCode
			   ,RI.RouteName
			  -- , LI.LineDesc
	   ORDER BY PRS.JobDate
			   ,PRS.LineCode
			   ,PRS.RouteCode
END