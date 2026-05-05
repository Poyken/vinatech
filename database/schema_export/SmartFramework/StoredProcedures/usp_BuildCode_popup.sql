-- Procedure: usp_BuildCode_popup

-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-04
-- Description:	시설물 코드 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_BuildCode_popup]
AS
BEGIN
	SET NOCOUNT ON;

    	SELECT						
			IsNull(BC.ItemCode,'') AS BuildCode,
			IsNull(BC.Description,'') AS BuildName
	FROM
			STB_BaseCode BC WITH(NOLOCK)			
	WHERE 	1=1
		AND BC.CodeGroup like '%Build%'
END
GO

