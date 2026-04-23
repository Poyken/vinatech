-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-01-13
-- Group : 공통
-- Description:	품목마스터 팝업  (품목별생산현황 품목코드 팝업 등)
--  2021.04.09  구리박 품목추가 (김전식)
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialMasterWithSize_popup]
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


if @CompanyCode='VNT' or @CompanyCode is null 

Begin    

	IF @IsRequireOqc = 1 BEGIN

			SELECT
					MM.MaterialCode,
					MM.MaterialName,
					MM.MaterialNameL,
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MM.MaterialUnit,
					CASE WHEN LEFT(MM.MaterialCode, 4) = 'LIVT' 
					     THEN 'VPC ' ELSE '' END + RIGHT('0'+CONVERT(VARCHAR(5), CONVERT(INT, MBI.MBISizeW)), 2) 
						                         + RIGHT('0'+CONVERT(VARCHAR(5), CONVERT(INT, MBI.MBISizeH)), 2) AS Size
			FROM
					STB_MaterialMaster MM WITH(NOLOCK)
					INNER JOIN STB_MaterialType MT WITH(NOLOCK)						ON MM.MaterialTypeCode = MT.MaterialTypeCode
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)						ON MM.ProductGroupCode = PG.ProductGroupCode
					LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)						ON MBI.ModelCode = MM.MaterialCode
			WHERE 1=1
			       -- and  MM.MaterialCode = 'ECVT30-220'
					AND MM.MaterialTypeCode LIKE @MaterialTypeCode 
					AND (MM.ProductGroupCode IS NULL OR MM.ProductGroupCode LIKE @ProductGroupCode) 
					AND MT.BasicMaterialType LIKE @BasicMaterialType 
					AND MM.MaterialCode LIKE @MaterialCode 
					AND (
						    MM.IsPurchase = @IsPurchase AND
						    MM.IsProdPlan = @IsProdPlan AND
						    MM.IsOrder = @IsOrder AND
						    MBI.InspectionType IN ('SAMPLE' ,'ALL')
					      ) 
					AND	ISNULL(MM.IsClosed, CONVERT(BIT, 0)) = 0

               


	END ELSE 

	 BEGIN

			SELECT
					MM.MaterialCode,
					MM.MaterialName,
					MM.MaterialNameL,
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MM.MaterialUnit,
					CASE WHEN LEFT(MM.MaterialCode, 4) = 'LIVT' 
					     THEN 'VPC ' ELSE '' END + RIGHT('0'+CONVERT(VARCHAR(5), CONVERT(INT, MBI.MBISizeW)), 2) 
						                         + RIGHT('0'+CONVERT(VARCHAR(5), CONVERT(INT, MBI.MBISizeH)), 2) AS Size
			FROM
					STB_MaterialMaster MM WITH(NOLOCK)					
					INNER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode  = MT.MaterialTypeCode					
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)		ON MM.ProductGroupCode = PG.ProductGroupCode					
					LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)		ON MBI.ModelCode          = MM.MaterialCode
			WHERE 1=1
			 --and  MM.MaterialCode = 'ECVT30-220'
			  AND		MM.MaterialTypeCode LIKE @MaterialTypeCode 
			  AND		(MM.ProductGroupCode IS NULL OR MM.ProductGroupCode LIKE @ProductGroupCode) 
			  AND		MT.BasicMaterialType LIKE @BasicMaterialType 
			  AND		MM.MaterialCode LIKE @MaterialCode 
			    AND
					(
						MM.IsPurchase = @IsPurchase AND
						MM.IsProdPlan = @IsProdPlan AND
						MM.IsOrder = @IsOrder AND
						(MBI.InspectionType IS NULL OR MBI.InspectionType = 'NONE')
					) 
				AND			ISNULL(MM.IsClosed, CONVERT(BIT, 0)) = 0

			--		--추가
			--		union all

			--		SELECT
			--		MM.MaterialCode,
			--		MM.MaterialName,
			--		MM.MaterialNameL,
			--		MM.MaterialTypeCode,
			--		MT.MaterialTypeName,
			--		MM.ProductGroupCode,
			--		PG.ProductGroupName,
			--		MM.MaterialSpec,
			--		MM.MaterialUnit
			--FROM
			--		STB_MaterialMaster MM WITH(NOLOCK)
			--		INNER JOIN STB_MaterialType MT WITH(NOLOCK)						ON MM.MaterialTypeCode = MT.MaterialTypeCode
			--		LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)						ON MM.ProductGroupCode = PG.ProductGroupCode
			--WHERE 1=1
			--        AND MM.MaterialCode = 'GASKFO-001'  
	END

end











--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode       
if @CompanyCode='VVT' begin

	IF @IsRequireOqc = 1 BEGIN

			SELECT
					MM.MaterialCode,
						case when MM.MaterialName='CS200' then 'CS 200' else MM.MaterialName end as MaterialName, --Mr.Tung avoid duplicate when Scanning 2022-30-30
					case when MM.MaterialNameL='CS200' then 'CS 200' else MM.MaterialNameL end as MaterialNameL, --Mr.Tung avoid duplicate when Scanning 2022-30-30
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
					AND (
						    MM.IsPurchase = @IsPurchase AND
						    MM.IsProdPlan = @IsProdPlan AND
						    MM.IsOrder = @IsOrder AND
						    MBI.InspectionType IN ('SAMPLE','ALL')
					      ) 

	END ELSE 

	 BEGIN

			SELECT
					MM.MaterialCode,
					case when MM.MaterialName='CS200' then 'CS 200' else MM.MaterialName end as MaterialName, --Mr.Tung avoid duplicate when Scanning 2022-30-30
					case when MM.MaterialNameL='CS200' then 'CS 200' else MM.MaterialNameL end as MaterialNameL, --Mr.Tung avoid duplicate when Scanning 2022-30-30
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MM.MaterialUnit
			FROM
					STB_MaterialMaster MM WITH(NOLOCK)					
					INNER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode  = MT.MaterialTypeCode					
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)		ON MM.ProductGroupCode = PG.ProductGroupCode					
					LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)		ON MBI.ModelCode          = MM.MaterialCode

	END

end


END

