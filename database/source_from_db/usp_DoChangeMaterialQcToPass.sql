-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-01-06
-- Description:	Change decision from Reject to Pass VVT
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoChangeMaterialQcToPass]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pMaterialQcNo VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MaterialQcNo VARCHAR(30) = @pMaterialQcNo

	DECLARE @CheckDecisionResult VARCHAR(30) = NULL,
			@BefPassedSampleQty INT = NULL,
			@BefDefectSampleQty INT = NULL,
			@CheckWorkCenterCode VARCHAR(10) = NULL

	SELECT	@CheckDecisionResult = DecisionResult,
			@BefPassedSampleQty = PassedSampleQty,
			@BefDefectSampleQty = DefectSampleQty,
			@CheckWorkCenterCode = WorkCenterCode
			FROM STB_MaterialQcInfo
			WHERE MaterialQcNo = @MaterialQcNo

	IF @CheckWorkCenterCode NOT IN ('VVT_F1')
		BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Chỉ được thay đổi các Lot của nhà máy Bắc Ninh'
			RETURN
		END

	ELSE IF @pProcessUserID NOT IN ( 'DoThu') -- ds những người có quyền chỉnh sửa
		BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Bạn không có quyền dùng chức năng này, liên hệ chị Thu IQC'
			RETURN
		END
	ELSE 
		BEGIN
			IF @CheckDecisionResult IN ('None', 'Pass')
				BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Lot này chưa được đánh giá hoặc đã Pass. Vui lòng kiểm tra lại!'
					RETURN
				END
			ELSE IF @CheckDecisionResult IN ('Reject')		-- Chỉ cho chuyển những lot từ Reject sang Pass
				BEGIN
					UPDATE STB_MaterialQcInfo
						SET
							DecisionResult = 'Pass',
							PassedSampleQty = @BefPassedSampleQty + @BefDefectSampleQty,
							DefectSampleQty = 0
							,ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID
						WHERE
							MaterialQcNo = @MaterialQcNo

					INSERT INTO STB_IQCInfoChangeHist (MaterialQcNo, BefPassedSampleQty, BefDefectSampleQty, ChangeDateTime, ChangeUserID) 
						values (@MaterialQcNo, @BefPassedSampleQty, @BefDefectSampleQty, GETDATE(), @pProcessUserID)
						
				END

			ELSE 
				BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Chỉ được chuyển những lot đã Reject!'
					RETURN
				END
		END
		
END
