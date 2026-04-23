-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 모듈관리
-- Browsable : true
-- Create date : 2026-04-18
-- Description : 
-- =============================================
CREATE PROC usp_ESDAreaWorkerInOutHist_iud
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pESDAreaCode VARCHAR(20),
	@pInOutCode VARCHAR(5),
	@pWorkerCode VARCHAR(20)
AS
BEGIN
	INSERT INTO STB_ESDAreaWorkerInOutHist (
		ESDAreaCode
       ,WorkerCode
       ,InOutCode
       ,CreateDateTime
	) VALUES (
		@pESDAreaCode
	   ,@pWorkerCode
	   ,@pInOutCode
	   ,GETDATE()
	)
END