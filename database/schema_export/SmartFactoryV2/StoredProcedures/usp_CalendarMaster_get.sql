-- Procedure: usp_CalendarMaster_get


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-06
-- Browsable : true
-- Group : 근무카렌더
-- Description:	근무카렌더 마스터 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalendarMaster_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCalendarCode VARCHAR(10) = NULL,
    @pShiftCode VARCHAR(1) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CalendarCode VARCHAR(10) = CASE WHEN ISNULL(@pCalendarCode,'') = '' THEN '*' ELSE @pCalendarCode END
	DECLARE @ShiftCode VARCHAR(1) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '*' ELSE @pShiftCode END
    
	SELECT
			DISTINCT
	        CM.CalendarCode AS OldCalendarCode,
	        CM.CalendarCode,
	        CM.CalendarName,
	        CM.CalendarDesc,
	        CM.IsUsed,
	        CM.CreateDateTime,
	        CM.CreateUserID,
	        CM.ChangeDateTime,
	        CM.ChangeUserID
	FROM
	        STB_CalendarMaster CM WITH(NOLOCK)
	        LEFT OUTER JOIN STB_CalendarDetail CD WITH(NOLOCK)
				ON CM.CalendarCode = CD.CalendarCode
	WHERE
	        ((@CalendarCode = '*') OR (CM.CalendarCode = @CalendarCode)) 
	        AND ((@ShiftCode = '*') OR (CD.ShiftCode = @ShiftCode)) 

END



GO

