CREATE PROC usp_TaktTimeForRoute_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pUtcOffset INT
   ,@pCompanyCode VARCHAR(20) = NULL
   ,@pWorkCenterCode VARCHAR(20) = NULL
   ,@pBarcode VARCHAR(20) = NULL
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		   ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
		   ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATE = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'

	SELECT TTFR.CompanyCode
	      ,TTFR.CompanyCode AS OldCompanyCode
		  ,CI.CompanyName
          ,TTFR.WorkCenterCode
		  ,TTFR.WorkCenterCode AS OldWorkCenterCode
		  ,WI.WorkCenterName
          ,TTFR.Barcode
		  ,TTFR.Barcode AS OldBarcode
          ,TTFR.RouteCode
		  ,TTFR.RouteCode AS OldRouteCode
		  ,RI.RouteName
          ,TTFR.ProdQty
          ,dbo.fnGetLocalTime(TTFR.ProdDateTime, @pUtcOffset) AS ProdDateTime
          ,TTFR.StandardTaktTime
          ,TTFR.TotStandardTaktTime
          ,TTFR.TotActualTaktTime / TTFR.ProdQty AS ActualTaktTime
		  ,TTFR.TotActualTaktTime
		  ,CASE WHEN TTFR.RouteCode = 'StartRoute' THEN 0 ELSE ROUND(TTFR.TotStandardTaktTime / TTFR.TotActualTaktTime * 100, 2) END AS EfficiencyRate
          ,TTFR.Remark
          ,TTFR.CreateDateTime
          ,TTFR.CreateUserID
          ,TTFR.ChangeDateTime
          ,TTFR.ChangeUserID
	  FROM STB_TaktTimeForRoute TTFR
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = TTFR.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WI
	    ON WI.WorkCenterCode = TTFR.WorkCenterCode
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON RI.RouteCode = TTFR.RouteCode
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON SI.Barcode = TTFR.Barcode
	  LEFT OUTER JOIN STB_ProductionOrderRouting POR
	    ON POR.PONo = SI.PONo
	   AND POR.RouteCode = TTFR.RouteCode
	 WHERE 1 = 1 
	   AND dbo.fnGetLocalTime(TTFR.ProdDateTime, @pUtcOffset) BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR TTFR.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR TTFR.WorkCenterCode = @WorkCenterCode)
	   AND (@Barcode = '*' OR TTFR.Barcode = @Barcode)
	   AND (@CompanyCode = '*' OR TTFR.CompanyCode = @CompanyCode)

	 ORDER BY  TTFR.CompanyCode
			  ,TTFR.WorkCenterCode
			  ,TTFR.Barcode
			  ,POR.RouteIndex
END