

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-06
-- Browsable : true
-- Group : 팝업
-- Description:	근무카렌더 코드 조회-팝업용
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalendarMaster_popup]
AS
BEGIN
	SET NOCOUNT ON;
	
 
	SELECT
	        CM.CalendarCode,
	        CM.CalendarName,
	        CM.CalendarDesc
	       
	FROM
	        STB_CalendarMaster CM WITH(NOLOCK)

END


