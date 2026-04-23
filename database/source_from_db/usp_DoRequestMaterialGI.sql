-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-02
-- Description : 자재출고요청
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRequestMaterialGI]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@DocStatus VARCHAR(20),
			@IsCancel BIT

	SELECT
			@DocStatus = MDI.DocStatus,
			@IsCancel = MDI.IsCancel
	FROM
			STB_MaterialDocInfo MDI
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

	IF @DocStatus IS NULL BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage,
										'출고정보를 찾을 수 없습니다'
		RETURN
	END

	IF @IsCancel = 1 BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage,
										'이미 취소된 출고입니다'
		RETURN
	END

	IF @DocStatus <> 'CREATE' BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage,
										'요청가능 상태가 아닙니다'
		RETURN
	END

	SET @DocStatus = 'REQUEST'
	IF dbo.fnGetProcessRule('RequireProductionGIApprove','N') <> 'Y' BEGIN
		SET @DocStatus = 'APPROVED'
	END

	UPDATE	STB_MaterialDocInfo
	SET
			DocStatus = @DocStatus,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			MaterialDocNo = @MaterialDocNo
END
