-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-02-04
-- Browsable : true
-- Group : 생산관리
-- Description:	라인별 폐기물 등록 이력
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_WasteRegHistByLine_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20)
AS
BEGIN
	Declare @LineCode VARCHAR(20) = @pLineCode
	       ,@RouteCode VARCHAR(20) = @pRouteCode

	SELECT *
	  FROM STB_ProdRouteHist PRH
	 WHERE PRH.LineCode = @LineCode
	   AND PRH.RouteCode = @RouteCode
	   AND ProdDateTime >= DATEADD(day, -1, GETDATE())
END