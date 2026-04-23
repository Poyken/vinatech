-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 팝업
-- Description: 설비별 스페어파트 교체유형 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetChangePlanType]

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT
			ChangePlanType
	FROM
			VW_ChangePlanType WITH(NOLOCK)
	

END
