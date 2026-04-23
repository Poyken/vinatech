-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 팝업
-- Description: 설비 점검 주기 유형 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetPmItemType]

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT
			PmItemType
	FROM
			VW_PmItemType WITH(NOLOCK)
	

END
