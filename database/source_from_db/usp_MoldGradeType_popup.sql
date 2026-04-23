
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 팝업
-- Description:	금형등급유형 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldGradeType_popup]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			MGT.MoldGradeTypeCode,
			MGT.MoldGradeTypeName,
			MGT.Level1Qty,
			MGT.Level2Qty,
			MGT.Level3Qty
	FROM
			STB_MoldGradeType MGT WITH(NOLOCK)
END



