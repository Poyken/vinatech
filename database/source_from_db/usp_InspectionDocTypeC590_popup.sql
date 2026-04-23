-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-06
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InspectionDocTypeC590_popup]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 'OQC' AS InspectionDocType UNION ALL
	SELECT 'IQC'
END
