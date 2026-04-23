-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-11-24
-- Browsable : true
-- Group : 생산관리
-- Description:	폐기물단가조회(전극)
-- Modified:
-- =============================================

CREATE PROCEDURE usp_ElectrodeWastePriceInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END

	SELECT EWN.CompanyCode AS OldCompanyCode
          ,EWN.WorkCenterCode AS OldWorkCenterCode
		  ,EWN.RouteCode AS OldRouteCode
          ,EWN.ElectrodeClassCode AS OldElectrodeClassCode
          ,EWN.ElectrodeThickness AS OldElectrodeThickness
          ,EWN.CurrentCollectorClassCode AS OldCurrentCollectorClassCode
          ,EWN.DefectCode AS OldDefectCode
	      ,EWN.CompanyCode
	      ,CI.CompanyName
          ,EWN.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,EWN.RouteCode
		  ,RI.RouteName
          ,EWN.ElectrodeClassCode
          ,EWN.ElectrodeThickness
          ,EWN.CurrentCollectorClassCode
          ,EWN.DefectCode
		  ,DI.BasicDefectName
          ,EWN.DefectUnitPrice
          ,EWN.CreateDateTime
          ,EWN.CreateUserID
          ,EWN.ChangeDateTime
          ,EWN.ChangeUserID
	  FROM STB_ElectrodeWastePriceNew EWN
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = EWN.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = EWN.WorkCenterCode
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON RI.RouteCode = EWN.RouteCode
	  LEFT OUTER JOIN STB_DefectInfo DI
	    ON DI.DefectCode = EWN.DefectCode
     WHERE (@CompanyCode = '*' OR EWN.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR EWN.WorkCenterCode = @WorkCenterCode)
END