-- =============================================
-- Author:		Kangs (kilee@awoo.co.kr)
-- Create date: 2020-11-24
-- Group : 공통 > PowerBI
-- Description:	자재마스터를 조회합니다.
-- usp_MaterialMaster_PowerBI
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialMaster_PowerBI]
	--@pProcessLanguage VARCHAR(20),
	--@pProcessUserID VARCHAR(20),
	--@pMaterialCode VARCHAR(50) = NULL,
	--@pMaterialName NVARCHAR(100) = NULL,
	--@pMaterialTypeCode VARCHAR(20) = NULL,
	----@pMaterialTypeName VARCHAR(20) = NULL,
	--@pProductGroupCode VARCHAR(20) = NULL,
	--@pBasicMaterialType VARCHAR(20) = NULL,
	--@pExcludeBasicMaterialTypes VARCHAR(100) = 0
	----@pProductGroupName VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
	--		@MaterialName NVARCHAR(100) = CASE WHEN ISNULL(@pMaterialName,'') = '' THEN '%' ELSE @pMaterialName END,
	--		@MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END,
	--		@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
	--		@BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType ,'') = '' THEN '%' ELSE @pBasicMaterialType END,
	--		@ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes

	SELECT
			--MM.MaterialCode AS OldMaterialCode,
			MM.MaterialCode as 품목코드,
			MM.MaterialName as 품목명,
			--MM.MaterialNameL,
			--MM.AltMaterialCode,
			--MM.MaterialTypeCode,
			--MT.BasicMaterialType,
			--MT.MaterialTypeName,
			--MT.MaterialTypeNameL,
			--MM.ProductGroupCode,
			--PG.ProductGroupName,
			--PG.ProductGroupNameL,
			--PG.ProductGroupDesc,
			--PG.ProductGroupDescL,
			--MM.MaterialUnit,
			--MM.BasicGrQty as 납품단위수량,
			--MM.MaterialSpec,
			--MM.MaterialSpecL,
			--MM.MaterialSource,
			--MM.MaterialThickness,
			--MM.AvgGrDay,
			--MM.IsDelegate,
			--MM.IsInternalProd,
			--MM.IsProdPlan,
			--MM.IsPurchase,
			--MM.IsOrder,
			--MM.IsUseFlush,
			--MM.IsUseBackFlush,
			--MM.MaterialPurchaseType,
			--MM.IsClosed,
			--ISNULL(MM.IsRequireOqc,0) AS IsRequireOqc,
			--MM.BeforeMaterialCode,
			--MM.RequestGrDay,
			MM.BasicCostPrice as 표준원가
			--MM.BasicPackingQty,
			--MM.MaxProdPlanQty,
			--MM.BasicRoutingCode,
			--BRI.BasicRoutingName,
			--MM.MMExtText01,
			--MM.MMExtText02,
			--MM.MMExtText03,
			--MM.MMExtText04,
			--MM.MMExtText05,
			--MM.MMExtText06,
			--MM.MMExtText07,
			--MM.MMExtText08,
			--MM.MMExtText09,
			--MM.MMExtText10,
			--MM.MMExtInt01,
			--MM.MMExtInt02,
			--MM.MMExtInt03,
			--MM.MMExtInt04,
			--MM.MMExtInt05,
			--MM.MMExtReal01,
			--MM.MMExtReal02,
			--MM.MMExtReal03,
			--MM.MMExtReal04,
			--MM.MMExtReal05,
			--MM.MMExtLongText01,
			--MM.MMExtLongText02,
			--MM.MMExtLongText03,
			--MM.MMExtLongText04,
			--MM.MMExtLongText05,
			--MM.MMExtImage01,
			--MM.MMExtImage02,
			--MM.MMExtImage03,
			--MM.MMExtImage04,
			--MM.MMExtImage05,
			--MM.CreateDateTime,
			--MM.CreateUserID,
			--MM.ChangeDateTime,
			--MM.ChangeUserID
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_MaterialPurchaseType MPT WITH(NOLOCK)				ON MPT.MaterialPurchaseType = MM.MaterialPurchaseType
			LEFT OUTER JOIN STB_BasicRoutingInfo BRI WITH (NOLOCK)				ON BRI.BasicRoutingCode = MM.BasicRoutingCode
	WHERE 1=1
			--MM.MaterialCode LIKE @MaterialCode AND
			--MM.MaterialName LIKE @MaterialName + '%' AND
			--MM.MaterialTypeCode LIKE @MaterialTypeCode AND
			--((MM.ProductGroupCode IS NULL) OR (MM.ProductGroupCode LIKE @ProductGroupCode)) AND
			--MT.BasicMaterialType LIKE @BasicMaterialType AND
			--MT.BasicMaterialType NOT IN (
			--								SELECT
			--										T.Item
			--								FROM
			--										dbo.fnSplitToTable(',', @ExcludeBasicMaterialTypes) T
			--							)
END
