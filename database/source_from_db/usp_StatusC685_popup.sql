-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-04-02
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_StatusC685_popup
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 'Completed' AS [Status] UNION ALL
	SELECT	'On Process'			UNION ALL
	SELECT	'Pending'
END
