
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-02
-- Description:	근무카렌더 근무 타임코드 팝업 조회용
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalendarTimeCodeType_popup]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			TimeCode
	FROM
			VW_CalendarTimeCodeType 
	
END

