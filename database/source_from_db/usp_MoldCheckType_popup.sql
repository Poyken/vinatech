
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 팝업
-- Description:	금형점검유형 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckType_popup]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			MCT.MoldCheckTypeCode,
			MCT.MoldCheckTypeName,
			MCT.MoldCheckTypeDesc
	FROM
			STB_MoldCheckType MCT WITH(NOLOCK)
END



