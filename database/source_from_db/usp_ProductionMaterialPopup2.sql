-- =============================================
-- Author : kilee
-- Group : 생산관리 > [B420] 일일생산계획수립 > 품목코드 콤보박스
-- Browsable : true
-- Create date : 2019-05-09
-- Description : 생산가능한 자재 팝업을 해당화면에 맞게 변경
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductionMaterialPopup2]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupCode VARCHAR(20) = NULL,
	@pBasicMaterialType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			    @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '%' ELSE @pBasicMaterialType END

	SELECT MM.MaterialCode,
			  MM.MaterialName,
			  MM.MMExtText08,
			  MM.MMExtText09,
			  MM.MMExtText10
	FROM STB_MaterialMaster MM                     WITH(NOLOCK)
			 LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE 1=1
	   AND MM.IsClosed = 0 
	   AND MM.IsProdPlan = 1 
	   AND MM.ProductGroupCode LIKE @ProductGroupCode 
	   AND MT.BasicMaterialType LIKE @BasicMaterialType

END


--     SELECT * FROM STB_MaterialMaster