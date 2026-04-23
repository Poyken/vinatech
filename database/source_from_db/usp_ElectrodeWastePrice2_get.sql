-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020.02.26
-- Description : 
-- Modified :
-- 실행 : exec usp_ElectrodeWastePrice2_get '', '', '2020-03-26', '2020-04-25', ''

-- exec usp_ElectrodeWastePrice2_get '', '', '2021-03-26', '2021-03-31', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWastePrice2_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pRouteCode VARCHAR(20) = NULL

AS

BEGIN
	Declare @FromDate DATE = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATE = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '*' ELSE @pRouteCode END

	IF @FromDate = '1900-01-01 08:30:00' OR @ToDate = '1900-01-01 08:30:00' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	SELECT EWIN.ElectrodeWasteNo
	      ,EWIN.CompanyCode
		  ,EWIN.WorkCenterCode
		  ,EWIN.LineCode
	      ,CASE WHEN CONVERT(CHAR(8), EWIN.CreateDateTime, 108) < '08:30:00' 
		        THEN DATEADD(day, -1, EWIN.JobDate) ELSE EWIN.JobDate END AS JobDate
          ,EWIN.CalendarCode
		  ,CM.CalendarName
          ,EWIN.RouteCode
		  ,RI.RouteName
          ,EWIN.MachineCode
		  ,MM.MachineName
		  ,EWIN.ElectrodeClassCode AS ElectrodeWasteCategory1
		  ,BC1.Description                        AS ElectrodeWasteCategory1Name
          ,EWIN.CurrentCollectorClassCode AS ElectrodeWasteCategory2
		  ,BC2.Description                        AS ElectrodeWasteCategory2Name
          ,EWIN.ElectrodeThickness            AS ElectrodeWasteCategory3
          ,BC3.Description                        AS ElectrodeWasteCategory3Name
          ,EWIN.DefectCode
		  ,DI.BasicDefectName
		  ,EWIN.DefectWeight
		  ,EWPN.DefectUnitPrice
		  ,isnull(EWIN.DefectWeight * EWPN.DefectUnitPrice, 0) AS DefectPrice            -- 폐기금액
		  ,EWIN.Remark
          ,EWIN.CreateDateTime
          ,EWIN.CreateUserID
          ,EWIN.ChangeDateTime
          ,EWIN.ChangeUserID

		  ,(  SELECT BaseMonth
			    FROM STB_AggregationPeriod
			   WHERE 1=1										   
				 AND  FromDate <= EWIN.JobDate
				 AND  ToDate    >= EWIN.JobDate
		   )  AS YearMonth
	  FROM STB_ElectrodeWasteInfoNew EWIN
	  LEFT OUTER JOIN STB_CalendarMaster CM	    ON EWIN.CalendarCode = CM.CalendarCode
	  LEFT OUTER JOIN STB_RouteInfo RI	    ON EWIN.RouteCode = RI.RouteCode
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON MM.MachineCode = EWIN.MachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON EWIN.ElectrodeClassCode = BC1.ItemCode	            AND BC1.CodeGroup = 'EWCategory1'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON EWIN.CurrentCollectorClassCode = BC2.ItemCode	AND BC2.CodeGroup = 'EWCategory2'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON EWIN.ElectrodeThickness = BC3.ItemCode        	    AND BC3.CodeGroup = 'EWCategory3'
	  LEFT OUTER JOIN STB_DefectInfo DI              	                    ON DI.DefectCode = EWIN.DefectCode
	  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN             ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode	   
																				   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
																				   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
																				   AND EWPN.CompanyCode = EWIN.CompanyCode
																				   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
																				   AND EWPN.RouteCode = EWIN.RouteCode
																				   AND EWPN.DefectCode = EWIN.DefectCode
	 WHERE EWIN.JobDate BETWEEN @FromDate AND @ToDate
	   AND (@RouteCode = '*' OR EWIN.RouteCode = @RouteCode)
	 ORDER BY EWIN.JobDate
END




/*

SELECT DefectWeight, * from STB_ElectrodeWasteInfoNew WHERE CompanyCode = 'VVT'

SELECT DefectUnitPrice, * FROM STB_ElectrodeWastePriceNew WHERE CompanyCode = 'VVT'


SELECT *
  FROM STB_DefectInfo
 WHERE DefectCode IN (
   'V-01_ZZ'
    ,'V-02_0A2'
    ,'V-02_ZZ'
    ,'V-02_0A1'
    ,'V-02_0A3'
    ,'V-02_0A4'
    ,'V-03_0B4'
    ,'V-02_YY'
 )


*/