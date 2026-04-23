-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 공통
-- Description:	BOM Detail 조회 프로시저
-- Modified: usp_BomDetail_5123_get '','','CRCEK0-266'
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomDetail_5123_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
    --@pBomVersion VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
      --DECLARE @BomVersion VARCHAR(20) = CASE WHEN ISNULL(@pBomVersion,'') = '' THEN '' ELSE @pBomVersion END

    --RAISERROR(@MaterialCode,16,1)
	SELECT
	        --BD.MaterialCode AS OldMaterialCode,
	        --BD.BomVersion AS OldBomVersion,
	        --BD.ChildMaterialCode AS OldChildMaterialCode,
	        --BD.ChildBomVersion AS OldChildBomVersion,
	        
	        BD.MaterialCode,
	        BD.BomVersion,
	        
	        BD.ChildMaterialCode,
	        BD.ChildBomVersion,
	        
	        MM.MaterialName,
			--MM.MaterialNameL,
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
			--MM.BasicGrQty,
			--MM.MaterialSpec,
			--MM.MaterialSpecL,
			--MM.MaterialSource,
			--MM.AvgGrDay,
			--MM.IsPurchase,
			--MM.IsOrder,
			--MM.IsClosed,
			--MM.BeforeMaterialCode,
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
	        
	        
			--BD.BomUnit,
	        BD.UsedQty
	        
	  --      BD.RouteCode,
	  --      RI.CompanyCode,
			--CI.CompanyName,
			--CI.CompanyNameL,
			--CI.CompanyDesc,
			--CI.CompanyDescL,
	  --      RI.WorkCenterCode,
			--WCI.WorkCenterName,
			--WCI.WorkCenterNameL,
			--WCI.WorkCenterDesc,
			--WCI.WorkCenterDescL,
	  --      RI.RouteName,
	  --      RI.IsExternalRoute,
	  --      RI.IsUsed,
	        
	  --      BD.IsOptionItem,
	  --      BD.BomDetailDesc,
	        
	  --      BD.CreateDateTime,
	  --      BD.CreateUserID,
	  --      BD.ChangeDateTime,
	  --      BD.ChangeUserID
	FROM
	        STB_BomDetail BD WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON BD.ChildMaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)		ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = BD.RouteCode
	        LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)			ON CI.CompanyCode = RI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)	ON (WCi.WorkCenterCode = RI.WorkCenterCode)
	WHERE
	        ((BD.MaterialCode = @MaterialCode))  
	        --((BD.BomVersion = @BomVersion)) 

END
