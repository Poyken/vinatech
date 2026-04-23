-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-24
-- Description:	Status equipment in H101
-- =============================================
CREATE PROCEDURE usp_getMeasurementControlListVVT_Status_popup

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT '운영중(Running)' AS [Status] UNION ALL
	SELECT '폐기(Scrap)' UNION ALL
	SELECT '보관 (Keep)'

END
