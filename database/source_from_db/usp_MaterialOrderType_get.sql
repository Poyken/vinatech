
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-18
-- Browsable : true
-- Group : 공통
-- Description:	발주유형정보를 가져옵니다(Popup용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialOrderType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			MOT.MaterialOrderType,
			MOT.MaterialOrderTypeName
	FROM
			VW_MaterialOrderType MOT WITH(NOLOCK)
	ORDER BY
			MOT.DisplayIndex


END


