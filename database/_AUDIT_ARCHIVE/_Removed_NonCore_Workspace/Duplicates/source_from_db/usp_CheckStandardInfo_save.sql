-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-07-29
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckStandardInfo_save]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	CREATE TABLE #Params
	(
		CheckStandardNo VARCHAR(20)
	   ,CheckStartDate DateTime
	   ,RepeatCycleCode VARCHAR(10)
	   ,CheckDateOption VARCHAR(10)
	   ,DayOfTheWeek INT
	)

	Declare @CheckStandardNo VARCHAR(20)
	       ,@CheckStartDate DateTime
		   ,@RepeatCycleCode VARCHAR(10)
		   ,@CheckDateOption VARCHAR(10)
		   ,@DayOfTheWeek INT

	exec usp_CheckStandardInfo_iud @pProcessUserID, @pProcessLanguage, @pProcessViewName, @pXml             -- 프로시저 usp_CheckStandardInfo_iud

	Declare curMain CURSOR FOR
		SELECT CheckStandardNo
			  ,CheckStartDate
			  ,RepeatCycleCode
			  ,CheckDateOption
			  ,DayOfTheWeek
		  FROM #Params

	OPEN curMain
	FETCH NEXT FROM curMain INTO @CheckStandardNo, @CheckStartDate, @RepeatCycleCode, @CheckDateOption, @DayOfTheWeek

	WHILE @@FETCH_STATUS = 0 BEGIN
		exec usp_DoMakeCheckItemSchedule @pProcessUserID, @pProcessLanguage, @CheckStandardNo, @CheckStartDate, @RepeatCycleCode  ,@CheckDateOption, @DayOfTheWeek   -- 프로시저 usp_DoMakeCheckItemSchedule

		FETCH NEXT FROM curMain INTO @CheckStandardNo, @CheckStartDate, @RepeatCycleCode, @CheckDateOption, @DayOfTheWeek
	END

	CLOSE curMain
	DEALLOCATE curMain
	

	DROP TABLE #Params
END