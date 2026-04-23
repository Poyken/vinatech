
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-02
-- Browsable : true
-- Group : 팝업
-- Description:	점검입력유형- 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCommInspInputType_popup]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT
			CIIT.CommInspInputType,
			CIIT.CommInspInputTypeName
	FROM
			VW_CommInspInputType CIIT WITH(NOLOCK)
END


