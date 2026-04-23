-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-23
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_VN_esrAgingSD_import_get
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20) =NULL,
			@pProcessLanguage VARCHAR(20) =NULL,
			@pLotNo VARCHAR(100) = NULL,
			@pFileName VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select 
		@pLotNo AS LotNo,
		@pFileName AS [FileName],
		'' AS CH,
		'' AS OCV,
		'' AS OCV등급,
		'' AS 충전V,
		'' AS 충전I,
		'' AS 방전V,
		'' AS 방전I,
		'' AS 방전용량,
		'' AS 방전용량등급,
		'' AS DCR,
		'' AS DCR등급


END
