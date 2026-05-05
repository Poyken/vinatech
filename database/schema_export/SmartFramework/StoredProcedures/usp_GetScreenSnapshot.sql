-- Procedure: usp_GetScreenSnapshot






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-05-13
-- Browsable: false
-- Description:	화면 캡쳐를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreenSnapshot] 
	@pScreenName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			SLI.Snapshot
	FROM
			STB_ScreenInfo SI WITH(NOLOCK)
			INNER JOIN STB_ScreenLayoutInfo SLI WITH(NOLOCK)
				ON	SLI.Name = SI.Name AND
					SLI.Version = SI.CurrentVersion
	WHERE
			SI.Name = @pScreenName
END







GO

