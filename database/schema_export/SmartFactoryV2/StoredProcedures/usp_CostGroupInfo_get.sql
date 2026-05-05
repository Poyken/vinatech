-- Procedure: usp_CostGroupInfo_get
-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2019-06-21
-- Browsable : true
-- Group : 생산관리
-- Description:	인원 근태현황 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL

AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN @pCompanyCode IS NULL THEN '%' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN @pWorkCenterCode IS NULL THEN '%' ELSE @pWorkCenterCode END

	SELECT CGI.CostGroupCode
		  ,CGI.CostGroupName
		  ,CGI.CompanyCode
		  ,CI.CompanyName
		  ,CGI.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,CGI.LineCode
		  ,LI.LineName
		  ,CGI.RouteCode
		  ,RI.RouteName
		  ,CGI.IsUsed
		  ,CGI.CreateDateTime
		  ,CGI.CreateUserID
		  ,CGI.ChangeDateTime
		  ,CGI.ChangeUserID
	  FROM STB_CostGroupInfo CGI
			  LEFT OUTER JOIN STB_CompanyInfo CI	      ON CGI.CompanyCode = CI.CompanyCode
			  LEFT OUTER JOIN STB_WorkCenterInfo WCI	  ON CGI.WorkCenterCode = WCI.WorkCenterCode
			  LEFT OUTER JOIN STB_RouteInfo RI     	      ON CGI.RouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_LineInfo LI ON CGI.LineCode = LI.LineCode
	 WHERE 1=1
	    AND CGI.CompanyCode LIKE @CompanyCode
	    AND CGI.WorkCenterCode LIKE @WorkCenterCode

END
GO

