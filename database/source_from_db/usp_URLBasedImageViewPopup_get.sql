-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-12-12
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_URLBasedImageViewPopup_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

	SELECT 'http://work.hycap.co.kr/imagePopup/imagePopup?imageUrl=http://work.hycap.co.kr' + ISNULL(MAX(SERVER_URL), '/_images/common/noimg.png') AS ImageUrl
	  FROM ERPSVR.VINATech.dbo.VECS_STORAGE
	 WHERE SEND_LOCATION = 'X-ray'
	   AND LOT = @Barcode
END