CREATE PROC [dbo].[usp_ViewUnit] --EXEC usp_ViewTypenames 'NVL'
@Codename NVARCHAR(50)
AS
BEGIN
		SELECT DISTINCT UNITS FROM TYPESCRAP WITH(NOLOCK) WHERE codename = @Codename
END

