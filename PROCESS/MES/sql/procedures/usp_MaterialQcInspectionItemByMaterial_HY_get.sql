-- =============================================
-- Author: Danh Thuc
-- Create date:2026-06-15
-- Description:	CLone Stored of "usp_MaterialQcInspectionItem_ByMaterial_get", For HUNG YEN FACTORY
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItemByMaterial_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '' ELSE @pMaterialCode END
    DECLARE @CompanyCode VARCHAR(20) = 'VNT' 

    SELECT @CompanyCode = CompanyCode
	FROM STB_UserInfo WITH(NOLOCK)
	WHERE UserID = @pProcessUserID;
    /* IF (@CompanyCode = 'VVT' AND @pProcessUserID <> 'VVT_F1')
    BEGIN
        RAISERROR('Chỉ user VVT_F5 mới có quyền truy xuất dữ liệu QC Inspection này!', 16, 1)
        RETURN
    END */
    

    -- Kiểm tra mã vật tư có tồn tại không
	IF (
		SELECT COUNT(*)
		FROM
			STB_MaterialMaster MM WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK) ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK) ON (PG.ProductGroupCode = MM.ProductGroupCode)
		WHERE	
			MM.MaterialCode = @MaterialCode
	) < 1
	BEGIN
		RAISERROR('등록되지 않은 자재코드 입니다 (Mã vật tư chưa được đăng ký)', 16, 1)
		RETURN
	END
	
    -- Lấy thông tin Hạng mục Kiểm tra QC
	SELECT
			MIII.MaterialCode AS OldMaterialCode,
			MIII.MaterialCode,
			MM.MaterialName,
			MM.ProductGroupCode,
			QIG.QcInspectionGroupCode, 
			QIG.QcInspectionGroupName,                                                                 -- 검사항목명
			QIG.QcInspectionGroupDesc,
			MIII.QcInspectionItemCode AS OldQcInspectionItemCode,
			MIII.QcInspectionItemCode,
			III.QcInspectionItemName,                                                                  --2016-08-07 LDS 추가	(검사항목명)
			III.QcInspectionItemDesc,                                                                  --2020-02-15 베트남어추가
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
			III.ItemInspectionPrior;
			

	-- Model 정보를 보여주기 위한 Table (Thông tin Model vật tư)
	SELECT 
			*
	FROM
			STB_MaterialMaster MM WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)				ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
	WHERE	
			MM.MaterialCode = @MaterialCode;

END