-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-07-08
-- Browsable : true
-- Group : 생산관리
-- Description:	라인정지일시 업데이트
-- Modified:
-- =============================================
CREATE PROC usp_DoUpdateLineStopInfo
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pLineNonOperationHistNo VARCHAR(20)
   ,@pLineStopRemark NVARCHAR(MAX)
AS
BEGIN
	Declare @LineNonOperationHistNo VARCHAR(20) = @pLineNonOperationHistNo
           ,@LineStopRemark NVARCHAR(MAX) = @pLineStopRemark

	UPDATE STB_LineNonOperationHist
	   SET LineStopDateTime = GETDATE()
	      ,LineStopRemark = @LineStopRemark
	WHERE LineNonOperationHistNo = @LineNonOperationHistNo
END