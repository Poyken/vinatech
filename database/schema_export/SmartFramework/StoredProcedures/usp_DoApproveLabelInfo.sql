-- Procedure: usp_DoApproveLabelInfo


-- =============================================
-- Author :	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group :	System
-- Browsable : true
-- Create date : 2018-04-12
-- Description : 라벨유형을 승인합니다
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoApproveLabelInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL,
	@pFormatName NVARCHAR(30) = NULL,
	@pFormatVersion INT = NULL,
	@pApplyDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@LabelType NVARCHAR(30) = @pLabelType,
			@FormatName NVARCHAR(30) = @pFormatName,
			@FormatVersion INT = @pFormatVersion,
			@IsApproval BIT,
			@ApplyDate DATE = @pApplyDate

	SELECT
			@IsApproval = LI.IsApproval
	FROM
			STB_LabelInfo LI
	WHERE
			LI.LabelType = @LabelType AND
			LI.FormatName = @FormatName AND
			LI.FormatVersion = @FormatVersion

	IF ISNULL(@IsApproval,0) = 1 BEGIN
			DECLARE @ErrorMsg NVARCHAR(500)
			EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
											@pName = '^labeltype was Approval!^',
											@pValue = @ErrorMsg OUTPUT

			RAISERROR(@ErrorMsg,16,1)
			RETURN
	END

	UPDATE	STB_LabelInfo
	SET
			IsApproval = 1,
			ApplyDate = ISNULL(@ApplyDate,ApplyDate),
			ApprovalUserID = @ProcessUserID,
			ApprovalDateTime = GETDATE(),
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			LabelType = @LabelType AND
			FormatName = @FormatName AND
			FormatVersion = @FormatVersion
END


GO

