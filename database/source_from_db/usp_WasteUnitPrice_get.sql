-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-10-21
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_WasteUnitPrice_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT WUP.LineCode
		  ,WUP.Volt
		  ,WUP.Farad
		  ,WUP.Size
		  ,WUP.RouteCode
		  ,RI.RouteName
		  ,WUP.ProcessUnitPriceKG
		  ,WUP.ProcessUnitPriceEA
		  ,WUP.CreateDateTime
		  ,WUP.CreateUserID
		  ,WUP.ChangeDateTime
		  ,WUP.ChangeUserID
	  FROM STB_WasteUnitPrice WUP
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON WUP.RouteCode = RI.RouteCode
	 ORDER BY LineCode, Volt, Farad, Size, RouteCode
END