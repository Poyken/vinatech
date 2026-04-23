-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020.02.26
-- Description : 
-- 2021.05.28 사업장구분 (김전식요청)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWastePriceNew_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pRouteCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 추가 (2021.05.27 김전식요청)
	@pWorkCenterCode VARCHAR(20) = NULL

AS

BEGIN
	Declare @FromDate DATE = @pFromDate
			   ,@ToDate DATE = @pToDate
			   ,@RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '*' ELSE @pRouteCode END
			   ,@CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
			   ,@WorkCenterCode   VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

	SELECT EWIN.ElectrodeWasteNo
	      ,EWIN.CompanyCode
		  ,CI.CompanyName
		  ,EWIN.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,EWIN.LineCode
	      ,EWIN.JobDate
          ,EWIN.CalendarCode
		  ,CM.CalendarName
          ,EWIN.RouteCode
		  ,RI.RouteName
		  ,EWIN.Barcode
          ,EWIN.MachineCode
		  ,MM.MachineName
		  ,EWIN.ElectrodeClassCode
		  ,BC1.Description AS ElectrodeClassName
          ,EWIN.CurrentCollectorClassCode
		  ,BC2.Description AS CurrentCollectorClassName
          ,EWIN.ElectrodeThickness
          ,BC3.Description AS ElectrodeThicknessName
          ,EWIN.DefectCode
		  ,DI.BasicDefectName
		  ,EWIN.DefectWeight
		  ,EWPN.DefectUnitPrice
		  ,EWIN.DefectWeight * EWPN.DefectUnitPrice AS DefectPrice
		  ,EWIN.Remark
          ,EWIN.CreateDateTime
          ,EWIN.CreateUserID
          ,EWIN.ChangeDateTime
          ,EWIN.ChangeUserID
	  FROM STB_ElectrodeWasteInfoNew EWIN
	  LEFT OUTER JOIN STB_CalendarMaster CM	    ON EWIN.CalendarCode = CM.CalendarCode
	  LEFT OUTER JOIN STB_RouteInfo RI	    ON EWIN.RouteCode = RI.RouteCode
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON MM.MachineCode = EWIN.MachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON EWIN.ElectrodeClassCode = BC1.ItemCode	   AND BC1.CodeGroup = 'EWCategory1'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON EWIN.CurrentCollectorClassCode = BC2.ItemCode	   AND BC2.CodeGroup = 'EWCategory2'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON EWIN.ElectrodeThickness = BC3.ItemCode
	   AND BC3.CodeGroup = 'EWCategory3'
	  LEFT OUTER JOIN STB_DefectInfo DI	    ON DI.DefectCode = EWIN.DefectCode
	  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN	    ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
	   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
	   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
	   AND EWPN.CompanyCode = EWIN.CompanyCode
	   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
	   AND EWPN.RouteCode = EWIN.RouteCode
	   AND EWPN.DefectCode = EWIN.DefectCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = EWIN.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = EWIN.WorkCenterCode
	 WHERE 1=1
	   AND EWIN.JobDate BETWEEN @FromDate AND @ToDate
	   AND (@RouteCode = '*' OR EWIN.RouteCode = @RouteCode)
	   AND ((@CompanyCode = '*') OR (EWIN.CompanyCode = @CompanyCode))
	   AND ((@WorkCenterCode = '*') OR (EWIN.WorkCenterCode = @WorkCenterCode))

	 ORDER BY EWIN.JobDate
END