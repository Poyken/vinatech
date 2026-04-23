-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-23
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_LevelC685_popup
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT N'Major (Trung Bình)' AS [Level] UNION ALL
	SELECT N'Critical (Nghiêm trọng)'  UNION ALL
	SELECT N'Nhẹ (Minior)' 
END
