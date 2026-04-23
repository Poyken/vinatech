-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-05-15
-- Browsable : true
-- Group : 품질관리
-- Description:	품질부문장 반려
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoQcDefectReportRejectQc]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
	
	-- 보고서가 품질부문장 결재 상태이면 취소
	UPDATE STB_QcDefectReport
	   SET IsQcHeadConfirm = CONVERT(BIT, 0)
	 WHERE DefectReportNo = @DefectReportNo

	exec usp_DoProcessApprovalInfo @pProcessUserID, @pProcessLanguage, 'QcDefectReport', 'STB_ApprovalLineInfo', 'ApprovalStepID', 'DefectReportNo', 3, @DefectReportNo, 1
END