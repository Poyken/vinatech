-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-08-13
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_ImageUpload_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(100),
	@pImageClassCode VARCHAR(10) = NULL
AS

BEGIN
	Declare @Barcode VARCHAR(100) = @pBarcode
	       ,@ImageClassCode VARCHAR(10) = CASE WHEN @pImageClassCode IS NULL THEN '%' ELSE @pImageClassCode END

	SELECT ImageUploadNo
		  ,ImageClassCode
		  ,Barcode
		  ,ImageFile1
		  ,ImageFile2
		  ,ImageFile3
		  ,ImageFile4
		  ,ImageFile5
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_ImageUpload
	 WHERE Barcode = @Barcode
	   AND ImageClassCode LIKE @ImageClassCode
	 ORDER BY ImageUploadNo
END