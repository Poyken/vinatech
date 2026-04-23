-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-10
-- Browsable : true
-- Group : 품질관리 > [C125] 자재별검사항목(Import)
-- Description:	자재별수입검사항목/스펙을 조회합니다(자재별항목관리시)
-- Modified: Material Master Table 도 Select(정보 조회용)
-- 프로시저 실행
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItemByMaterialForImport]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pBasicMaterialType VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pExcludeBasicMaterialTypes VARCHAR(100) = 0
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			@MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			@BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType ,'') = '' THEN '%' ELSE @pBasicMaterialType END,
			@ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes
	
	SELECT
			MIII.MaterialCode AS OldMaterialCode,
			MIII.MaterialCode,
			MM.MaterialName,
			MM.ProductGroupCode,
			QIG.QcInspectionGroupCode,
			QIG.QcInspectionGroupName,
			QIG.QcInspectionGroupDesc,
			MIII.QcInspectionItemCode AS OldQcInspectionItemCode,
			MIII.QcInspectionItemCode,
			III.QcInspectionItemName,  --2016-08-07 LDS 추가	
			MIII.ItemInspectionPrior,
			MIII.ItemReportPrior,
			III.IsCanSkip,
			MIII.InspectionType,
			IT.InspectionTypeName,
			MIII.QcSpecDesc,
	        MIII.InspectionLevel,
	        MIII.AQL,
	        MIII.SpecValue,
	        MIII.USL,
	        MIII.LSL,
	        MIII.UCL,
	        MIII.LCL,
	        MIII.TextSpecValue,
	        MIII.CreateDateTime,
	        MIII.CreateUserID,
	        MIII.ChangeDateTime,
	        MIII.ChangeUserID
	FROM
			STB_MaterialQcInspectionItem MIII WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
				ON (MM.MaterialCode = MIII.MaterialCode)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)
				ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_QcInspectionItem III WITH (NOLOCK)
				ON (III.QcInspectionItemCode = MIII.QcInspectionItemCode)
			LEFT OUTER JOIN STB_QcInspectionGroup QIG WITH (NOLOCK)
				ON (QIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
			LEFT OUTER JOIN VW_InspectionType IT
				ON (IT.InspectionType = MIII.InspectionType)
	WHERE
			MM.MaterialTypeCode LIKE @MaterialTypeCode AND
			MT.BasicMaterialType LIKE @BasicMaterialType AND
			MM.ProductGroupCode LIKE @ProductGroupCode AND
			MIII.MaterialCode LIKE @MaterialCode AND
			MT.BasicMaterialType NOT IN (
											SELECT
													Item
											FROM
													dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)
										)
	ORDER BY 
			III.ItemReportPrior,
			III.ItemInspectionPrior
END
