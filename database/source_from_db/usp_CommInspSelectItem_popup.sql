
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 팝업
-- Description:	공용검사선택항목정보 - 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspSelectItem_popup]
	@pCommInspSelectGroupCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CommInspSelectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pCommInspSelectGroupCode,'') = '' THEN '%' ELSE @pCommInspSelectGroupCode END
	
	SELECT
			CISI.CommInspSelectItemCode,
			CISI.CommInspSelectItemValue,
			CISI.CommInspSelectResult
	FROM
			STB_CommInspSelectItem CISI WITH(NOLOCK)
	WHERE
			CISI.CommInspSelectGroupCode LIKE @CommInspSelectGroupCode

END


