-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020.02.26
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWastePriceNewByBarcode_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = ''
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

	SELECT EWIN.ElectrodeWasteNo
	      ,EWIN.CompanyCode
		  ,EWIN.WorkCenterCode
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
		  ,'Report' AS CommandType
	  FROM STB_ElectrodeWasteInfoNew EWIN
	  LEFT OUTER JOIN STB_CalendarMaster CM
	    ON EWIN.CalendarCode = CM.CalendarCode
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON EWIN.RouteCode = RI.RouteCode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = EWIN.MachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON EWIN.ElectrodeClassCode = BC1.ItemCode
	   AND BC1.CodeGroup = 'EWCategory1'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON EWIN.CurrentCollectorClassCode = BC2.ItemCode
	   AND BC2.CodeGroup = 'EWCategory2'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON EWIN.ElectrodeThickness = BC3.ItemCode
	   AND BC3.CodeGroup = 'EWCategory3'
	  LEFT OUTER JOIN STB_DefectInfo DI
	    ON DI.DefectCode = EWIN.DefectCode
	  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN
	    ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
	   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
	   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
	   AND EWPN.CompanyCode = EWIN.CompanyCode
	   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
	   AND EWPN.RouteCode = EWIN.RouteCode
	   AND EWPN.DefectCode = EWIN.DefectCode
	 WHERE EWIN.Barcode = @Barcode
	 ORDER BY EWIN.JobDate
END