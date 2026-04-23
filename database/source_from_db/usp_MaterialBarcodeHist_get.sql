

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date: 2019-04-15
-- Description: 분리막 정보를 읽어옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialBarcodeHist_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo

	SELECT MaterialBarcodeNo
		  ,MaterialDocDetailNo
		  ,BarcodeText
		  ,LotNo
		  ,LotQty
		  ,LotAttr01
		  ,LotAttr02
		  ,LotAttr03
		  ,LotAttr04
		  ,LotAttr05
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_MaterialBarcodeHist
	 WHERE MaterialDocDetailNo = @MaterialDocDetailNo
	 ORDER BY MaterialBarcodeNo
END