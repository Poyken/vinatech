-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-09
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사를 폐기처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoLossCommInspDoc_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocNo VARCHAR(20),
	@pIsCheckItem BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@IsCheckItem BIT = ISNULL(@pIsCheckItem,0)
			
	DECLARE @IsLoss BIT
	DECLARE @IsFinished BIT
	DECLARE @Barcode VARCHAR(50)
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode,
			@IsLoss = SI.IsLoss
	FROM
			STB_CommInspDocHistory CIDH WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo
	
	IF @IsFinished = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 완료처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END

	IF @IsLoss = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 폐기처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END


	UPDATE	STB_SetInfo
	SET
			IsLoss = 1
	WHERE
			Barcode = @Barcode

	EXEC usp_DoFinishCommInspDoc	@pProcessUserID = @ProcessUserID,
									@pProcessLanguage = @ProcessLanguage,
									@pCommInspDocNo = @CommInspDocNo,
									@pIsCheckItem = @IsCheckItem
END
