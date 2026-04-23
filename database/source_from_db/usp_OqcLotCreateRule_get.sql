
-- =============================================
-- Author:	    Jeon GyeongHo(khjun@awoo.co.kr)
-- Create date: 2018-01-08
-- Browsable : true
-- Group : 품질관리
-- Description:	출하검사 생성규칙을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OqcLotCreateRule_get]
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
			OLCR.OqcCreateRuleNo AS OldOqcCreateRuleNo,
			OLCR.OqcCreateRuleNo,
			OLCR.OqcCreateRuleName,
			OLCR.CompanyCode,
			CI.CompanyName,
			OLCR.WorkCenterCode,
			WCI.WorkCenterName,
			OLCR.ProdStartTime,
			OLCR.ProdEndTime,
			OLCR.IntervalHour,
			OLCR.InspectionLevel,
			OLCR.AQL,
			OLCR.CreateDateTime,
			OLCR.CreateUserID,
			OLCR.ChangeDateTime,
			OLCR.ChangeUserID
	FROM
			STB_OqcLotCreateRule OLCR WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = OLCR.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = OLCR.WorkCenterCode
	WHERE
			((@CompanyCode = '*') OR (OLCR.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (OLCR.WorkCenterCode = @WorkCenterCode))

END
