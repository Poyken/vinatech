-- Procedure: usp_GetHomeScreenForMobile






-- =============================================
-- Author:		Kim Han Young
-- Browsable : false
-- Create date: 2015-04-16
-- Description:	홈화면을 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHomeScreenForMobile]
	@pProcessUserID VARCHAR(20)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			TOP 1 SI.Name
    FROM
			STB_ScreenInfo SI WITH(NOLOCK)
	WHERE
			SI.ShowAfterStart = 1
END







GO

