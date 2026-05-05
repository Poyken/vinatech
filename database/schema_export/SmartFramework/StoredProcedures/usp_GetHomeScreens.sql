-- Procedure: usp_GetHomeScreens






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-05-16
-- Browsable: false
-- Description:	Home 화면 리스트를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHomeScreens]
	
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			SI.*
	FROM
			STB_ScreenInfo SI WITH(NOLOCK)
	WHERE
			SI.IsDelete = 0 AND
			SI.ShowAfterStart = 1
END







GO

