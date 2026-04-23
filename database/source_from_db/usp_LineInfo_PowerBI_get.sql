
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-03-19
-- Browsable : true
-- Group : 생산관리공통
-- Description:	라인마스터를 가져옵니다.
-- Modified:
--                usp_LineInfo_PowerBI_get '', 'Korean', '', '', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineInfo_PowerBI_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    
	SELECT
	        --LI.LineCode AS OldLineCode,
	        LI.LineCode,
	        LI.CompanyCode,
			CI.CompanyName,
	        LI.WorkCenterCode,
			WCI.WorkCenterName,
	        LI.LineName                              -- 소스원복
	        --LI.LineDesc AS LineName
	        --LI.LineType,
			----LI.LineBarcode,
			--LI.ErpCode,
			--LI.MonitoringGroup,
			--LI.MonitoringName,
	  --      LI.IsUsed,
	  --      LI.CreateDateTime,
	  --      LI.CreateUserID,
	  --      LI.ChangeDateTime,
	  --      LI.ChangeUserID,
			--LI.IsCheckScheduleMonitoring
	FROM
	        STB_LineInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON	CI.CompanyCode = LI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON	WCI.WorkCenterCode = LI.WorkCenterCode
	WHERE
	        ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode)) 

END
