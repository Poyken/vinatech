-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_DoUpdateMaterialOQcInfoRemark_BendingCutting
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20),
	@pDescText NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	       ,@DescText NVARCHAR(MAX) = ISNULL(@pDescText, '')

	UPDATE STB_MaterialQcInfo_BendingCutting
	   SET DescText = @DescText
	 WHERE MaterialQcNo = @MaterialQcNo
END
