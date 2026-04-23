-- =============================================
-- Author:		소병운
-- Create date: 2025-11-27
-- Group : 공통
-- Description:	품목마스터 팝업  (원자재투입(샘플) 품목 popup 조회 시 원자재, 반제품 출력) 
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialMaster_popup_sampleInput]
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL,
	@pBasicMaterialType VARCHAR(MAX) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pIsPurchase BIT = 0,	                                   -- 구매여부
	@pIsOrder BIT = 0,										   -- 발주여부
	@pIsProdPlan BIT = 0,									   -- 생산여부
	@pIsRequireOqc BIT = 0                                 -- 출하검사여부
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			@BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType ,'') = '' THEN '%' ELSE @pBasicMaterialType END,
			@MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			@IsPurchase BIT = @pIsPurchase,
			@IsProdPlan BIT = @pIsProdPlan,
			@IsOrder BIT = @pIsOrder,
			@IsRequireOqc BIT = @pIsRequireOqc,
			@CompanyCode  varchar(20) = 'VNT',
			@ProcessUserID varchar(20) = @pProcessUserID


	SELECT @CompanyCode = CompanyCode   
	FROM STB_UserInfo where UserID=@ProcessUserID;


	if @CompanyCode='VNT' or @CompanyCode is null Begin    


			SELECT
					MM.MaterialCode,
					MM.MaterialName,
					MM.MaterialNameL,
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MM.MaterialUnit
			FROM
					STB_MaterialMaster MM WITH(NOLOCK)
					INNER JOIN STB_MaterialType MT WITH(NOLOCK)						ON MM.MaterialTypeCode = MT.MaterialTypeCode
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)						ON MM.ProductGroupCode = PG.ProductGroupCode
					LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)						ON MBI.ModelCode = MM.MaterialCode
			WHERE 1=1
					AND MM.MaterialTypeCode LIKE @MaterialTypeCode 
					AND (MM.ProductGroupCode IS NULL OR MM.ProductGroupCode LIKE @ProductGroupCode) 
					AND MM.MaterialCode LIKE @MaterialCode 
					AND	ISNULL(MM.IsClosed, CONVERT(BIT, 0)) = 0
					AND (
						(MM.IsPurchase = @IsPurchase AND MM.IsOrder = @IsOrder)
						OR
						(MM.IsProdPlan = @IsProdPlan AND MM.MaterialTypeCode = @BasicMaterialType)
					) 
		
	END
END

