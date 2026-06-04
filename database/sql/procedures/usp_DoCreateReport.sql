-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2019-03-29
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified: 여러 Lot를 하나의 성적서로 발급하기 위함  (품질팀 요청사항)
-- =============================================

CREATE PROCEDURE [dbo].[usp_DoCreateReport]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),

	@pMaterialQcNo VARCHAR(200),
	@pPackageID VARCHAR(20)

AS

BEGIN

	SET NOCOUNT ON;
	

    Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	Declare @PackageID     VARCHAR(20) = @pPackageID
	Declare @InQClList       VARCHAR(MAX)



	SELECT @MaterialQcNo = MaterialQcNo FROM STB_MaterialQcInfo  WHERE MaterialQcNo = @MaterialQcNo


	IF @InQClList IS NULL 
	
	BEGIN
			UPDATE STB_HelaBarcodeOutBoxHist
			   SET InBoxLabelList = @PackageID
			 WHERE LotNo = @MaterialQcNo
	
	END ELSE BEGIN

			UPDATE STB_HelaBarcodeOutBoxHist
			      SET InBoxLabelList = @InQClList + ',' + @PackageID
			 WHERE LotNo = @MaterialQcNo
	END


END


--SELECT * FROM STB_MaterialQcInfo
--SELECT * FROM STB_HelaBarcodeOutBoxHist
