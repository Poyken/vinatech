CREATE	 PROCEDURE [dbo].[usp_GetLevelSparePart_popup]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT  1 as Level
	UNION
	SELECT  2 as Level
	UNION
	SELECT  3 as Level
			
END
