CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItem_ByMaterial_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '' ELSE @pMaterialCode END

	IF (SELECT COUNT(*) FROM STB_MaterialMaster MM WITH (NOLOCK)
		LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK) ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
		LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK) ON (PG.ProductGroupCode = MM.ProductGroupCode)
		WHERE MM.MaterialCode = @MaterialCode) < 1
	BEGIN
		RAISERROR('등록되지 않은 자재코드 입니다', 16, 1)
		RETURN
	END
	
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
			III.QcInspectionItemName,
			III.QcInspectionItemDesc,
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
	        MIII.ChangeUserID,
			MIII.SampleQty
	FROM
			STB_MaterialQcInspectionItem_HY MIII WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)			ON (MM.MaterialCode = MIII.MaterialCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)			ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_QcInspectionItem_HY III WITH (NOLOCK)		ON (III.QcInspectionItemCode = MIII.QcInspectionItemCode)
			LEFT OUTER JOIN STB_QcInspectionGroup_HY QIG WITH (NOLOCK)	ON (QIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
			LEFT OUTER JOIN VW_InspectionType IT							ON (IT.InspectionType = MIII.InspectionType)
	WHERE
			((@MaterialCode = '*') OR (MIII.MaterialCode = @MaterialCode))
	ORDER BY 
			III.ItemReportPrior,
			III.ItemInspectionPrior

	SELECT *
	FROM
			STB_MaterialMaster MM WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)			ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)			ON (PG.ProductGroupCode = MM.ProductGroupCode)
	WHERE	
			MM.MaterialCode = @MaterialCode
END