-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-06-30
-- Description:	Lấy ra tên lỗi để có thêm vào bảo trì
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMainTenance_get]
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

		'' AS CellLine,
		'' AS StepName,
		'' AS TaskDescription,
		'' AS AsIs,
		'' as ToBe,
		'' as Effect


END
