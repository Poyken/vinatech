-- Procedure: usp_CommInspTypeInfo_popup
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 팝업
-- Description:	공용검사유형 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspTypeInfo_popup]
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
			CITI.CommInspTypeCode,
			CITI.CommInspTypeName,
			CITI.CommInspTypeDesc
	FROM
			STB_CommInspTypeInfo CITI WITH(NOLOCK)
	WHERE
			((@CompanyCode = '*') OR (CITI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (CITI.WorkCenterCode = @WorkCenterCode)) 

END




GO

