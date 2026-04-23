-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-07-16
-- Browsable : true
-- Group : 품질관리 > [수입검사]용 부적합등록 결재 Action
-- Description: 품질부문장 결재 및 취소
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoConfirmCancelQc2]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20) = NULL,
	@pIsConfirm BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @IsConfirm BIT = @pIsConfirm
	         ,@DefectReportNo VARCHAR(20) = @pDefectReportNo
	
	UPDATE STB_IQcDefectReport
	   SET IsQcHeadConfirm = @IsConfirm
	 WHERE DefectReportNo = @DefectReportNo

	IF @IsConfirm = CONVERT(BIT, 1) --AND @pProcessUserID IN ('mjlee', 'yjjoo') 
	BEGIN
		exec usp_DoProcessApprovalInfo2 @pProcessUserID, @pProcessLanguage, 'IQcDefectReport', 'STB_IQcDefectReport', 'ApprovalStepID', 'DefectReportNo', 4, @DefectReportNo, 4
	END 


	IF @IsConfirm = CONVERT(BIT, 0) --AND @pProcessUserID IN ('mjlee', 'yjjoo') 
	BEGIN
		exec usp_DoProcessApprovalInfo2 @pProcessUserID, @pProcessLanguage, 'IQcDefectReport', 'STB_IQcDefectReport', 'ApprovalStepID', 'DefectReportNo', 3, @DefectReportNo, 3
	END


END