-- Procedure: usp_GetUnitType_popup

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 공통
-- Description:	단위유형정보를 가져옵니다(popup용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetUnitType_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT
			BC.ItemCode,
			BC.Description
	FROM
			STB_BaseCode BC WITH (NOLOCK)
	WHERE
			BC.CodeGroup = 'UnitType'
END

GO

