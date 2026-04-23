
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-17
-- Description:	문서의 유효성을 체크합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoValidateMaterialDoc]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pErrorWhenStart BIT = 0,
	@pErrorWhenFinish BIT = 1,
	@pErrorWhenFix BIT = 1,
	@pErrorWhenCancel BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage
			
	DECLARE @DocStatus VARCHAR(20),
			@IsCancel BIT

	SELECT
			@DocStatus = MDI.DocStatus,
			@IsCancel = MDI.IsCancel
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

	IF @DocStatus IS NULL BEGIN
		DECLARE @NotFoundDocError NVARCHAR(500)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^문서정보를 찾을 수 없습니다.^',
										@pValue = @NotFoundDocError OUTPUT
		RAISERROR(@NotFoundDocError,16,1)
		RETURN
	END

	IF @pErrorWhenCancel = 1 AND @IsCancel = 1 BEGIN
		DECLARE @AlreadyCancelError NVARCHAR(500)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^이미 취소된 문서입니다^',
										@pValue = @AlreadyCancelError OUTPUT
		RAISERROR(@AlreadyCancelError,16,1)
		RETURN
	END	

	IF @pErrorWhenStart = 1 AND @DocStatus <> 'CREATE' BEGIN
		DECLARE @NotCreateStatusError NVARCHAR(500)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^작업이 진행되었거나 완료된 문서입니다^',
										@pValue = @NotCreateStatusError OUTPUT
		RAISERROR(@NotCreateStatusError,16,1)
		RETURN
	END	

	IF @pErrorWhenFinish = 1 AND @DocStatus = 'FINISH' BEGIN
		DECLARE @AlreadyFinishError NVARCHAR(500)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^이미 완료된 문서입니다^',
										@pValue = @AlreadyFinishError OUTPUT
		RAISERROR(@AlreadyFinishError,16,1)
		RETURN
	END	

	IF @pErrorWhenFix = 1 AND @DocStatus = 'FIX' BEGIN
		DECLARE @AlreadyFixError NVARCHAR(500)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^이미 확정된 문서입니다^',
										@pValue = @AlreadyFixError OUTPUT
		RAISERROR(@AlreadyFixError,16,1)
		RETURN
	END	
END

