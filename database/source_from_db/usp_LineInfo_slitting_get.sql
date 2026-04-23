
-- =============================================
-- Author:	    Lee Kang il
-- Create date: 2018-12-26
-- Browsable : true
-- Group : 생산관리공통
-- Description:	라인마스터중 슬라이팅 공정만 가져옵니다. (B430화면용)
-- Modified:
-- 전극라인 통합으로 라인코드 (ELECTRODE LINE) 추가 2020.02.11 By Jackaroe #20200211
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineInfo_slitting_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    
	SELECT
	        LI.LineCode AS OldLineCode,
	        LI.LineCode,
	        LI.CompanyCode,
			CI.CompanyName,
	        LI.WorkCenterCode,
			WCI.WorkCenterName,
	        LI.LineName,
	        LI.LineDesc,
	        LI.LineType,
			--LI.LineBarcode,
			LI.ErpCode,
			LI.MonitoringGroup,
			LI.MonitoringName,
	        LI.IsUsed,
	        LI.CreateDateTime,
	        LI.CreateUserID,
	        LI.ChangeDateTime,
	        LI.ChangeUserID
	FROM
	        STB_LineInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)     ON	CI.CompanyCode = LI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK) ON	WCI.WorkCenterCode = LI.WorkCenterCode
	WHERE 1=1
	  AND   ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) 
	  AND   ((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode)) 
	  AND   (LI.LineCode LIKE 'SLITTING%' OR LI.LineCode = 'ELECTRODE LINE' ) -- #20200211

END
