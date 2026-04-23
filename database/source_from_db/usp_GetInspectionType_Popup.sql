

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016/02/16
-- Description:	납품 자재 검사 유형
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetInspectionType_Popup]

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT
			IT.InspectionType
	FROM
			VW_InspectionType IT WITH(NOLOCK)

END


