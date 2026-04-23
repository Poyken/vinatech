
-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-01-13
-- Browsable : true
-- Group : 공통
-- Description:	WorkCenterCode 조회합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkCenterInfo_popup]
	@pCompanyCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	SELECT
			WCI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			WCI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CI.CompanyDesc,
			CI.CompanyDescL,
			WCI.WorkCenterDesc,
			WCI.WorkCenterDescL
	FROM
			STB_WorkCenterInfo WCI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
	WHERE
			(WCI.IsUsed = 1) AND
			((@CompanyCode = '*') OR (WCI.CompanyCode = @CompanyCode)) 
END

