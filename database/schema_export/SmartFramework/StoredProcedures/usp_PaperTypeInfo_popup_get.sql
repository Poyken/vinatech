-- Procedure: usp_PaperTypeInfo_popup_get


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-31
-- Browsable : true
-- Group : 용지유형정보
-- Description:	용지유형정보를 가져옵니다(Popup)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PaperTypeInfo_popup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			PTI.PaperType AS OldPaperType,
			PTI.PaperType,
			PTI.PaperTypeName
	FROM
			STB_PaperTypeInfo PTI WITH(NOLOCK)
	WHERE
			PTI.IsUsed = 1

END



GO

