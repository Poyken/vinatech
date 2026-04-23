-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-30
-- Browsable : true
-- Group : 품질관리
-- Description:	비고내용을 업데이트 합니다.
-- Modified:  
-- =============================================
CREATE PROCEDURE usp_DoUpdateMaterialOQcInfoRemark
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20),
	@pDescText NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	       ,@DescText NVARCHAR(MAX) = ISNULL(@pDescText, '')

	UPDATE STB_MaterialQcInfo
	   SET DescText = @DescText
	 WHERE MaterialQcNo = @MaterialQcNo
END