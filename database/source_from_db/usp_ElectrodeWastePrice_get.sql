-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020.02.26
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWastePrice_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pRouteCode VARCHAR(20) = NULL

AS

BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '*' ELSE @pRouteCode END

	SELECT EWI.ElectrodeWasteNo
	      ,EWI.CompanyCode
		  ,EWI.WorkCenterCode
		  ,EWI.LineCode
	      ,EWI.JobDate
          ,EWI.CalendarCode
		  ,CM.CalendarName
          ,EWI.RouteCode
		  ,RI.RouteName
          ,EWI.MachineCode
		  ,MM.MachineName
		  ,EWI.ElectrodeWasteCategory1
		  ,BC1.Description AS ElectrodeWasteCategory1Name
          ,EWI.ElectrodeWasteCategory2
		  ,BC2.Description AS ElectrodeWasteCategory2Name
          ,EWI.ElectrodeWasteCategory3
          ,BC3.Description AS ElectrodeWasteCategory3Name
          ,EWI.DefectCode
		  ,DI.BasicDefectName
		  ,EWI.DefectWeight
		  ,CASE WHEN EWI.DefectCode = 'ELECTRODE_W1' THEN EWP.DefectUnitPrice * 0.2 ELSE EWP.DefectUnitPrice END AS DefectUnitPrice
		  ,EWI.DefectWeight * (CASE WHEN EWI.DefectCode = 'ELECTRODE_W1' THEN EWP.DefectUnitPrice * 0.2 ELSE EWP.DefectUnitPrice END) AS DefectPrice
		  ,EWI.Remark
          ,EWI.CreateDateTime
          ,EWI.CreateUserID
          ,EWI.ChangeDateTime
          ,EWI.ChangeUserID
	  FROM STB_ElectrodeWasteInfo EWI
	  LEFT OUTER JOIN STB_CalendarMaster CM
	    ON EWI.CalendarCode = CM.CalendarCode
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON EWI.RouteCode = RI.RouteCode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = EWI.MachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON EWI.ElectrodeWasteCategory1 = BC1.ItemCode
	   AND BC1.CodeGroup = 'EWCategory1'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON EWI.ElectrodeWasteCategory2 = BC2.ItemCode
	   AND BC2.CodeGroup = 'EWCategory2'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON EWI.ElectrodeWasteCategory3 = BC3.ItemCode
	   AND BC3.CodeGroup = 'EWCategory3'
	  LEFT OUTER JOIN STB_DefectInfo DI
	    ON DI.DefectCode = EWI.DefectCode
	  LEFT OUTER JOIN STB_ElectrodeWastePrice EWP
	    ON EWP.ElectrodeWasteCategory1 = EWI.ElectrodeWasteCategory1
	   AND EWP.ElectrodeWasteCategory2 = EWI.ElectrodeWasteCategory2
	   AND EWP.ElectrodeWasteCategory3 = EWI.ElectrodeWasteCategory3
	 WHERE EWI.JobDate BETWEEN @FromDate AND @ToDate
	   AND (@RouteCode = '*' OR EWI.RouteCode = @RouteCode)
	 ORDER BY EWI.JobDate
END