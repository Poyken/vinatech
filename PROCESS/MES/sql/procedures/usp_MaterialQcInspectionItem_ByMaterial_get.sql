-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	자재별수입검사항목/스펙을 조회합니다(자재별항목관리시)
-- Modified: Material Master Table 도 Select(정보 조회용)

-- usp_MaterialQcInspectionItem_ByMaterial_get '','','ECVT25-070'
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItem_ByMaterial_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '' ELSE @pMaterialCode END

	IF
		(
			SELECT 
					COUNT(*)
			FROM
					STB_MaterialMaster MM WITH (NOLOCK)
					LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)						ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
					LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)						ON (PG.ProductGroupCode = MM.ProductGroupCode)
			WHERE	
					MM.MaterialCode = @MaterialCode
		) < 1
	BEGIN
			RAISERROR('등록되지 않은 자재코드 입니다', 16, 1)
			RETURN
	END

    /*
	SELECT
	        MIII.MaterialCode AS OldMaterialCode,
	        MIII.QcInspectionGroupCode AS OldQcInspectionGroupCode,
	        MIII.QcInspectionItemCode AS OldQcInspectionItemCode,
	        MIII.MaterialCode,
	        MIII.QcInspectionGroupCode,
	        MIII.QcInspectionItemCode,
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
	WHERE
	        ((@MaterialCode = '*') OR (MIII.MaterialCode = @MaterialCode)) 
	*/
	
	SELECT
			MIII.MaterialCode AS OldMaterialCode,
			MIII.MaterialCode,
			MM.MaterialName,
			MM.ProductGroupCode,
			QIG.QcInspectionGroupCode, 
			QIG.QcInspectionGroupName,                                                         -- 검사항목명
			QIG.QcInspectionGroupDesc,
			MIII.QcInspectionItemCode AS OldQcInspectionItemCode,
			MIII.QcInspectionItemCode,
			III.QcInspectionItemName,                                                           --2016-08-07 LDS 추가	(검사항목명)
			III.QcInspectionItemDesc,                                                             --2020-02-15 베트남어추가
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
			QIG.QcInspectionGroupDesc,
			MIII.SampleQty
	
	FROM
								  STB_MaterialQcInspectionItem MIII WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)				ON (MM.MaterialCode = MIII.MaterialCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_QcInspectionItem III WITH (NOLOCK)			ON (III.QcInspectionItemCode = MIII.QcInspectionItemCode)
			LEFT OUTER JOIN STB_QcInspectionGroup QIG WITH (NOLOCK)		ON (QIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
			LEFT OUTER JOIN VW_InspectionType IT									ON (IT.InspectionType = MIII.InspectionType)
	WHERE
			((@MaterialCode = '*') OR (MIII.MaterialCode = @MaterialCode))
	ORDER BY 
			III.ItemReportPrior,
			III.ItemInspectionPrior
			


	-- Model 정보를 보여주기 위한 Table
	SELECT 
			*
	FROM
			STB_MaterialMaster MM WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)				ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
	WHERE	
			MM.MaterialCode = @MaterialCode

END



--- SELECT * FROM STB_MaterialQcInspectionItem WHERE MaterialCode = 'ECVT30-276'