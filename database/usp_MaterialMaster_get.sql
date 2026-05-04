Text
----
-- =============================================

-- Author:		Park Jong Seob(jspark@awoo.co.kr)

-- Create date: 2018-07-22

-- Group : ??

-- Description:	?????? ?????.

-- =============================================

CREATE PROCEDURE [dbo].[usp_MaterialMaster_get]

	@pProcessLanguage VARCHAR(20),

	@pProcessUserID VARCHAR(20),

	@pMaterialCode VARCHAR(50) = NULL,

	@pMaterialName NVARCHAR(100) = NULL,

	@pMaterialTypeCode VARCHAR(20) = NULL,

	--@pMaterialTypeName VARCHAR(20) = NULL,

	@pProductGroupCode VARCHAR(20) = NULL,

	@pBasicMaterialType VARCHAR(20) = NULL,

	@pExcludeBasicMaterialTypes VARCHAR(100) = 0,

	@pDangerMaterialYn NCHAR(1) = NULL

	--@pProductGroupName VARCHAR(20) = NULL

WITH RECOMPILE

AS

BEGIN

	SET NOCOUNT ON;

	

	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END,

			@MaterialName NVARCHAR(100) = CASE WHEN ISNULL(@pMaterialName,'') = '' THEN '*' ELSE @pMaterialName END,

			@MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END,

			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END,

			@BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType ,'') = '' THEN '*' ELSE @pBasicMaterialType END,

			@DangerMaterialYn NCHAR(1) = CASE WHEN ISNULL(@pDangerMaterialYn,'') = '' THEN '*' ELSE @pDangerMaterialYn END,

			@ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes



	SELECT

			MM.MaterialCode AS OldMaterialCode,

			MM.MaterialCode,

			MM.MaterialName,

			MM.MaterialNameL,

			MM.AltMaterialCode,

			MM.MaterialTypeCode,

			MT.BasicMaterialType,

			MT.MaterialTypeName,

			MT.MaterialTypeNameL,

			MM.ProductGroupCode,

			PG.ProductGroupName,

			PG.ProductGroupNameL,

			PG.ProductGroupDesc,

			PG.ProductGroupDescL,

			MM.MaterialUnit,

			MM.BasicGrQty,

			MM.MaterialSpec,

			MM.MaterialSpecL,

			MM.MaterialSource,

			MM.MaterialThickness,

			MM.AvgGrDay,

			MM.IsDelegate,

			MM.IsInternalProd,

			MM.IsProdPlan,

			MM.IsPurchase,

			MM.IsOrder,

			MM.IsUseFlush,

			MM.IsUseBackFlush,

			MM.MaterialPurchaseType,

			MM.IsClosed,

			ISNULL(MM.IsRequireOqc,0) AS IsRequireOqc,

			MM.BeforeMaterialCode,

			MM.RequestGrDay,

			MM.BasicCostPrice,

			MM.BasicCostPriceVVT,

			MM.BasicPackingQty,

			MM.MaxProdPlanQty,

			MM.BasicRoutingCode,

			BRI.BasicRoutingName,

			MM.MMExtText01,

			MM.MMExtText02,

			MM.MMExtText03,

			MM.MMExtText04,

			MM.MMExtText05,

			MM.MMExtText06,

			MM.MMExtText07,

			MM.MMExtText08,

			MM.MMExtText09,

			MM.MMExtText10,

			MM.MMExtInt01,

			MM.MMExtInt02,

			MM.MMExtInt03,

			MM.MMExtInt04,

			MM.MMExtInt05,

			MM.MMExtReal01,

			MM.MMExtReal02,

			MM.MMExtReal03,

			MM.MMExtReal04,

			MM.MMExtReal05,

			MM.MMExtLongText01,

			MM.MMExtLongText02,

			MM.MMExtLongText03,

			MM.MMExtLongText04,

			MM.MMExtLongText05,

			MM.MMExtImage01,

			MM.MMExtImage02,

			MM.MMExtImage03,

			MM.MMExtImage04,

			MM.MMExtImage05,

			MM.CreateDateTime,

			MM.CreateUserID,

			MM.ChangeDateTime,

			MM.ChangeUserID,

			MM.DangerMaterialYn,

			MM.DangerClassification,

			MM.DangerClassificationDetail,

			MM.Purpose,

			MM.Appearance,

			MM.StorageMethod,

			MM.ChemicalName,

			MM.CasNo,

			MM.Concentration,

			MM.DesignQty,

			MM.BefModelCode

	FROM

			STB_MaterialMaster MM WITH(NOLOCK)

			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode = MT.MaterialTypeCode

			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON MM.ProductGroupCode = PG.ProductGroupCode

			LEFT OUTER JOIN VW_MaterialPurchaseType MPT WITH(NOLOCK)				ON MPT.MaterialPurchaseType = MM.MaterialPurchaseType

			LEFT OUTER JOIN STB_BasicRoutingInfo BRI WITH (NOLOCK)				ON BRI.BasicRoutingCode = MM.BasicRoutingCode

	WHERE (@MaterialCode = '*' OR MM.MaterialCode = @MaterialCode) 

	  AND (@MaterialName = '*' OR MM.MaterialName = @MaterialName)

	  AND (@MaterialTypeCode = '*' OR MM.MaterialTypeCode = @MaterialTypeCode)

	  AND (@ProductGroupCode = '*' OR MM.ProductGroupCode = @ProductGroupCode) 

	  AND (@BasicMaterialType = '*' OR MT.BasicMaterialType = @BasicMaterialType)

	  AND (@DangerMaterialYn = '*' OR MM.DangerMaterialYn = @DangerMaterialYn)

	  AND (MT.BasicMaterialType IS NULL OR MT.BasicMaterialType NOT IN (

																		SELECT

																				T.Item

																		FROM

																				dbo.fnSplitToTable(',', @ExcludeBasicMaterialTypes) T

																	)

															)

END







