
-- =============================================
-- Author:	    Jackaroe
-- Create date: 2018-12-10
-- Browsable : true
-- Group : 개발테스트
-- Description:	자격증관리 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SetInfoTest_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaterialCode VARCHAR(20) = @pMaterialCode,
			@Barcode VARCHAR(20) = @pBarcode

	SELECT MaterialCode
	      ,Barcode
		  ,LotNumber
		  ,LotCreateDateTime
	  FROM STB_SetInfo
	 WHERE MaterialCode LIKE '%' + @MaterialCode + '%'
	   AND Barcode LIKE '%' + @Barcode + '%'

END