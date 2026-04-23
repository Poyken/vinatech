-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-05-15
-- Browsable : true
-- Group : 품질관리
-- Description:	생산부문장 결재(결재취소)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoConfirmCancelProd]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20) = NULL,
	@pIsConfirm BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @IsConfirm BIT = @pIsConfirm
	       ,@DefectReportNo VARCHAR(20) = @pDefectReportNo
	
	UPDATE STB_QcDefectReport
	   SET IsProdHeadConfirm = @IsConfirm
	 WHERE DefectReportNo = @DefectReportNo

	IF @IsConfirm = CONVERT(BIT, 1) AND @pProcessUserID IN ('mjlee', 'yjjoo') BEGIN
		exec usp_DoProcessApprovalInfo @pProcessUserID, @pProcessLanguage, 'QcDefectReport', 'STB_QcDefectReport', 'ApprovalStepID', 'DefectReportNo', 2, @DefectReportNo, 1
	END 
	
	IF @IsConfirm = CONVERT(BIT, 0) AND @pProcessUserID IN ('mjlee', 'yjjoo') BEGIN
		exec usp_DoProcessApprovalInfo @pProcessUserID, @pProcessLanguage, 'QcDefectReport', 'STB_QcDefectReport', 'ApprovalStepID', 'DefectReportNo', 1, @DefectReportNo, 1
	END
END