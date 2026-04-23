-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-14
-- Browsable : true
-- Group : 현장용
-- Description:	생산시 사용원자재 Lot 이력을 저장합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddMainAssemblePartInfo_SmartApp]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pAsmLotNo VARCHAR(50),
	@pPartCode VARCHAR(50) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @AsmLotNo VARCHAR(50) = @pAsmLotNo
	
	SELECT
			@ControlNo = SI.ControlNo
	FROM
			STB_SetInfo SI
	WHERE
			SI.Barcode = @Barcode

	IF 	LEFT(@AsmLotNo, 1) <> 'M' BEGIN
		SELECT TOP 1 @AsmLotNo = LotID
		  FROM STB_MaterialDocLotInfo
		 WHERE LotNo = @AsmLotNo
		 ORDER BY LotID ASC
	END

	EXEC usp_DoAddMainAssemblePartInfo	@pProcessLanguage = @pProcessLanguage,
										@pProcessUserID = @pProcessUserID,
										@pControlNo = @ControlNo,
										@pAsmLotNo = @pAsmLotNo,
										@pPartCode = @pPartCode
END
