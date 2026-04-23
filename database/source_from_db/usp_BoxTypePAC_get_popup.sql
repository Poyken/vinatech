-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_BoxTypePAC_get_popup 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		'OUTER' AS TypeBoxCode,
		N'THÙNG NGOÀI' AS TypeBoxName

	UNION ALL
	SELECT 'INNER', N'THÙNG TRONG'
END
