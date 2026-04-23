-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 2019-07-22
-- Description : 일일업무일지 생성
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateDailyTaskInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUserID VARCHAR(20),
	@pTaskDate DateTime
AS
BEGIN
	Declare @UserID VARCHAR(20) = @pUserID
	         -- ,@TaskDate DateTime = @pTaskDate
			--, @TaskDate DateTime =  CONVERT(VARCHAR(10), DateAdd(day, 1, @pTaskDate), 121) + ' 00:00:00'                  --- ex) 다음날 2019-10-19      select CONVERT(VARCHAR(10), DATEADD(day, 1, '2019-10-08'), 121) + ' 08:30:00'    
			, @TaskDate DateTime =  CONVERT(VARCHAR(10), @pTaskDate, 121) + ' 00:00:00' 

	INSERT INTO STB_DailyTaskInfo (UserID, TaskDate, TaskIndex)
		SELECT @UserID, @TaskDate, TaskIndex
		  FROM STB_DailyTaskTimeSchedule
END