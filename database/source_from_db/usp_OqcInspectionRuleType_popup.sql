-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2017-01-08
-- Group : 팝업
-- Browsable : true
-- Description:	OqcInspectionRuleType
-- =============================================
CREATE PROCEDURE [dbo].[usp_OqcInspectionRuleType_popup]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			'BY_MODEL' AS OqcInspectionRuleType
	UNION ALL
	SELECT
			'BY_PRODGROUP'
	
END




