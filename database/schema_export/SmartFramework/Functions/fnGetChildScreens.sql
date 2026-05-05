-- Function: fnGetChildScreens



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetChildScreens]
(	
	@pName VARCHAR(50)
)
RETURNS TABLE 
AS
RETURN 
(
	WITH Screen AS
	(
		SELECT
				SI.Name
		FROM
				STB_ScreenInfo SI WITH(NOLOCK)
		WHERE
				SI.ParentName = @pName
		UNION ALL
		SELECT
				SI.Name
		FROM
				Screen P
				INNER JOIN STB_ScreenInfo SI WITH(NOLOCK)
					ON	SI.ParentName = P.Name
	)
	SELECT
			S.Name
	FROM
			Screen S
)




GO

