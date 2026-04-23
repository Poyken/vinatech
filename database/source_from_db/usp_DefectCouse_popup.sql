-- =============================================
-- Author:		Nguyen Hai Trieu
-- Create date: 2025-05-26
-- Description:	Danh sách các hiện tượng lỗi
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCouse_popup]
WITH RECOMPILE, EXECUTE AS CALLER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET NOCOUNT ON;
	
	
	SELECT
			DG.DefectCode,
			DG.DefectCause
	FROM
			STB_DefectInfo DG WITH(NOLOCK)

END
