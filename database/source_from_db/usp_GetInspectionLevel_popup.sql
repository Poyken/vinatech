
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 품질관리
-- Description:	검사수준 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetInspectionLevel_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			DISTINCT IL.InspectionLevel
	FROM
			STB_InspectionLevel IL
	ORDER BY 
			IL.InspectionLevel
END

