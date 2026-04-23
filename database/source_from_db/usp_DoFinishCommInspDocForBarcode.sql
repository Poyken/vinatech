-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-09
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사를 완료처리합니다
-- Modified:
--  EXEC usp_DoFinishCommInspDocForBarcode '','','','', '1'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishCommInspDocForBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspTypeCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(50) = NULL,
	@pIsCheckItem BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspTypeCode VARCHAR(20) = @pCommInspTypeCode,
			@Barcode VARCHAR(50) = @pBarcode,
			@IsCheckItem BIT = @pIsCheckItem

	DECLARE @CommInspDocNo VARCHAR(20)
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@CommInspDocNo = CIDH.CommInspDocNo
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_CommInspDocHistory CIDH WITH(NOLOCK)
				ON CIDH.CommInspTypeCode = @CommInspTypeCode AND
				CIDH.ProdNo = SI.ControlNo
	WHERE
			SI.Barcode = @Barcode
	
	EXEC usp_DoFinishCommInspDoc	@pProcessUserID = @ProcessUserID,
									@pProcessLanguage = @ProcessLanguage,
									@pCommInspDocNo = @CommInspDocNo,
									@pIsCheckItem = @IsCheckItem
END
