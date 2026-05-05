-- Function: fnGetRootScreen



-- =============================================
-- Author:		Kim Han Young
-- =============================================
CREATE FUNCTION [dbo].[fnGetRootScreen]
(	
	@pName VARCHAR(50)
)
RETURNS VARCHAR(50) 
AS
BEGIN
	DECLARE @ParentName VARCHAR(50) = NULL,
			@Name VARCHAR(50) = @pName

	WHILE 1 = 1 BEGIN
		SELECT
				@ParentName = SI.ParentName
		FROM
				STB_ScreenInfo SI WITH(NOLOCK)
		WHERE
				SI.Name = @Name
		IF ISNULL(@ParentName,'') = ''
			BREAK

		SET @Name = @ParentName
	END
	RETURN @Name
END



GO

