
-- =============================================
-- Author:	    Jeon GyeongHo(khjun@awoo.co.kr)
-- Create date: 2018-01-08
-- Browsable : true
-- Group : 팝업
-- Description:	출하검사 생성규칙 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OqcLotCreateRule_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    
	SELECT
			OLCR.OqcCreateRuleNo,
			OLCR.OqcCreateRuleName,
			OLCR.ProdStartTime,
			OLCR.ProdEndTime,
			OLCR.IntervalHour,
			OLCR.InspectionLevel,
			OLCR.AQL
	FROM
			STB_OqcLotCreateRule OLCR WITH(NOLOCK)
	WHERE
			(OLCR.CompanyCode LIKE @CompanyCode) AND
			(OLCR.WorkCenterCode LIKE @WorkCenterCode)

END
