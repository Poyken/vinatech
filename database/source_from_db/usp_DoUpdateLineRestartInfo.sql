-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-07-08
-- Browsable : true
-- Group : 생산관리
-- Description:	라인재시작일시 업데이트
-- Modified:
-- =============================================
CREATE PROC usp_DoUpdateLineRestartInfo
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pLineNonOperationHistNo VARCHAR(20)
   ,@pLineRestartRemark NVARCHAR(MAX)
AS
BEGIN
	Declare @LineNonOperationHistNo VARCHAR(20) = @pLineNonOperationHistNo
           ,@LineRestartRemark NVARCHAR(MAX) = @pLineRestartRemark

	UPDATE STB_LineNonOperationHist
	   SET LineRestartDateTime = GETDATE()
	      ,LineRestartRemark = @LineRestartRemark
	WHERE LineNonOperationHistNo = @LineNonOperationHistNo


END