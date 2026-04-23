-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-07-09
-- Description:	Export Slitting Knife
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ExportSlittingKnife_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT

		'' AS SlittingKnifeCode,
		'' AS SlittingKnifeName,
		--1 AS IOQty,
		'' AS MachineCode,
		'' AS MachineName


END
