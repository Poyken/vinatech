-- Procedure: usp_CalendarDetail_get

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-06
-- Browsable : true
-- Group : 근무카렌더 관리
-- Description:	근무카렌더 디테일 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalendarDetail_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCalendarCode VARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CalendarCode VARCHAR(10) = CASE WHEN ISNULL(@pCalendarCode,'') = '' THEN '*' ELSE @pCalendarCode END
    
	SELECT
	        CD.CalendarCode AS OldCalendarCode,
	        CD.SeqNo AS OldSeqNo,
	        CD.CalendarCode,
	        CD.SeqNo,
	        --CONVERT(VARCHAR(20),CD.StartTime) AS StartTime,
	        --CONVERT(VARCHAR(20),CD.EndTime) AS EndTime,
	        CD.StartTime,
	        CD.EndTime,
	        CD.IsWork,
	        CD.RestType,
	        CD.ShiftCode,
	        CD.TimeCode,
	        CD.CreateDateTime,
	        CD.CreateUserID,
	        CD.ChangeDateTime,
	        CD.ChangeUserID 
	FROM
	        STB_CalendarDetail CD WITH(NOLOCK)
	WHERE
	        ((@CalendarCode = '*') OR (CD.CalendarCode = @CalendarCode))

END

GO

