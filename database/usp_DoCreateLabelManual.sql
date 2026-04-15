

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date: 2019-04-15
-- Description: 분리막 기준정보를 생성합니다.
-- =============================================
Create PROCEDURE [dbo].[usp_DoCreateLabelManual]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20),
	@pLabelQty INT
AS
BEGIN
	SET NOCOUNT ON;

	Declare @MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo
	       ,@LabelQty INT = @pLabelQty
		   ,@cnt INT = 0
		   ,@MaterialBarcodeNo VARCHAR(20)

	--기존정보 삭제
	DELETE FROM STB_MaterialBarcodeHist WHERE MaterialDocDetailNo = @MaterialDocDetailNo

	WHILE @LabelQty > @cnt BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialBarcodeHist', @MaterialBarcodeNo OUTPUT

		INSERT INTO STB_MaterialBarcodeHist (MaterialBarcodeNo, MaterialDocDetailNo)
			VALUES (@MaterialBarcodeNo, @MaterialDocDetailNo)

		SET @cnt = @cnt + 1
	END
END