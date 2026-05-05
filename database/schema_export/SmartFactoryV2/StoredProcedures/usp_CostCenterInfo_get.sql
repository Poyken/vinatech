-- Procedure: usp_CostCenterInfo_get
-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	비용처리부서정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostCenterInfo_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20)
AS
BEGIN
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode

	SELECT
			CCI.CompanyCode AS OldCompanyCode,
			CCI.WorkCenterCode AS OldWorkCenterCode,
			CCI.CostCenterCode AS OldCostCenterCode,
			CCI.CompanyCode,
			CI.CompanyName,
			CCI.WorkCenterCode,
			WCI.WorkCenterName,
			CCI.CostCenterCode,
			CCI.CostCenterName,
			CCI.IsUsed,
			CCI.CreateDateTime,
			CCI.CreateUserID,
			CCI.ChangeDateTime,
			CCI.ChangeUserID
	FROM
			STB_CostCenterInfo CCI WITH (NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH (NOLOCK)
				ON (CI.CompanyCode = CCI.CompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH (NOLOCK)
				ON (WCI.WorkCenterCode = CCI.WorkCenterCode)
	WHERE
			CCI.CompanyCode = @CompanyCode AND
			CCI.WorkCenterCode = @WorkCenterCode

END

GO

