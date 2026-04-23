-- =============================================
-- Author: kilee
-- Create date: 2019-03-05
-- Browsable : true
-- Group : 생산관리
-- Description:	일자별 라인별 공정별 생산수율을 가져옵니다


-- usp_GetProductionYield_Total_VVT '', '', 'VVT', NULL, NULL, NULL, '2020-02-01'
-- =============================================

Create PROCEDURE [dbo].[usp_GetProductionYield_Total_VVT]
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
	      -- ,PRS.RouteCode
		   ,Replace(PRS.RouteCode, 'V', 'E') AS RouteCode
	       --,RI.RouteName

		   	, CASE WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-22' THEN '권취'
			       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-24' THEN '커링'
				   WHEN Replace(PRS.RouteCode,  'V', 'E') = 'E-25' THEN '슬리빙'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-26' THEN '에이징'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-27' THEN '외관'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-28' THEN '포장'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-33' THEN '절곡'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-40' THEN '내전압'  ELSE '기타' END FindRouteName


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
		--LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
		LEFT OUTER JOIN (SELECT Replace(RouteCode, 'V', 'E') AS RouteCode, IsUsed FROM STB_RouteInfo )         RI  ON RI.RouteCode = PRS.RouteCode

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
			 --  ,RI.RouteName
	   ORDER BY PRS.JobDate
			   ,PRS.LineCode
			   ,PRS.RouteCode
END