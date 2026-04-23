-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 2019-07-22
-- Description : 일일업무일지 조회
-- Modified :
-- TEST :    usp_DailyTaskInfo_get '','','kilee','2019-10-30 00:00:00'

-- =============================================
CREATE PROCEDURE [dbo].[usp_DailyTaskInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUserID VARCHAR(20),
	@pTaskDate DateTime
AS
BEGIN
	Declare @UserID VARCHAR(20) = @pUserID
	       ,@TaskDate DateTime = @pTaskDate

	SELECT DTI.TaskIndex
	      ,CONVERT(CHAR(8), DTTS.StartTime, 108) AS StartTime
		  ,CONVERT(CHAR(8), DTTS.EndTime, 108) AS EndTime
		  ,DTI.TaskContent
		  ,DTI.CompletionDate
		  ,DTI.FinishedDate
		  ,DTI.UserID
		  --,DTI.TaskDate
		  , CONVERT(VARCHAR(10), DTI.TaskDate, 121) AS TaskDate
	  FROM STB_DailyTaskInfo DTI
			INNER JOIN STB_DailyTaskTimeSchedule DTTS	     ON DTI.TaskIndex = DTTS.TaskIndex
	 WHERE 1=1
	    AND UserID = @UserID
	    AND TaskDate = @TaskDate
	 ORDER BY TaskIndex, TaskDate DESC
END