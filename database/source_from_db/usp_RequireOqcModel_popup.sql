-- =============================================
-- Author :		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-08-30
-- Description : 출하검사 모델 팝업 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_RequireOqcModel_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END

	SELECT
			MBI.ModelCode,
			MBI.ModelName
	FROM
			VW_ModelBasicInfo MBI WITH(NOLOCK)
	WHERE
			MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode AND
			(MBI.InspectionType IS NOT NULL AND MBI.InspectionType NOT IN ('NONE'))
END
