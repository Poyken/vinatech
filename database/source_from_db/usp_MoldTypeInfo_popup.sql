-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 팝업
-- Description:	금형구분 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldTypeInfo_popup]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			MTI.MoldTypeCode,
			MTI.MoldTypeName,
			MTI.MoldTypeDesc
	FROM
			STB_MoldTypeInfo MTI WITH(NOLOCK)
END



