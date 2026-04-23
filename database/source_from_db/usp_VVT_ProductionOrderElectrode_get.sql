-- =============================================
-- Author : Mr.Tung

-- Browsable : true
-- Create date : 2023-08-21

-- ======================================================================================

create PROCEDURE [dbo].[usp_VVT_ProductionOrderElectrode_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromYearMonth DATE  = NULL,
	@pToYearMonth DATE = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pIsFix BIT = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage  VARCHAR(20) = @pProcessLanguage,
			    @FromYearMonth    VARCHAR(7) = CONVERT(VARCHAR,@pFromYearMonth,120),                                                                              -- select CONVERT(VARCHAR,'2019-09-26 00:00:00',120)
			    @ToYearMonth        VARCHAR(7) = CONVERT(VARCHAR,ISNULL(@pToYearMonth,'9999-12-31'),120),
			    @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			    @MaterialCode         VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			    @IsFix BIT = @pIsFix

  DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
  DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	SELECT
			POI.PONo,
			POI.CompanyCode,
			POI.WorkCenterCode,
			POI.PlanYearMonth,
			POI.POType,
			POI.IsReworkPO,
			POI.MaterialCode,
			MM.MaterialName,
			POI.BomVersion,
			POI.PlanQty,
			POI.ProdOrderQty,
			POI.ProdFinishQty,
			(POI.PlanQty - POI.ProdFinishQty) AS  DiffQty,
			POI.ProdOrderQty / POI.PlanQty * 100.0 AS ProdOrderRate,
			POI.ProdFinishQty / POI.PlanQty * 100.0 AS ProdRate,
			POI.IsFix,
			POI.FixUserID,
			POI.FixDateTime,
			POI.IsCancel,
			POI.CancelDateTime,
			POI.CancelUserID,
			POI.POExtText01,
			POI.POExtText02,
			POI.POExtText03,
			POI.POExtText04,
			POI.POExtText05,
			POI.BasicRoutingCode,
			BRI.BasicRoutingName,
			POI.CreateDateTime,
			POI.CreateUserID,
			POI.ChangeDateTime,
			POI.ChangeUserID,
			MM.ProductGroupCode,
			MM.MaterialUnit
	FROM
			                       STB_ProductionOrderInfo POI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM        WITH(NOLOCK)	 ON MM.MaterialCode = POI.MaterialCode
			LEFT OUTER JOIN STB_BasicRoutingInfo BRI       WITH(NOLOCK)  ON BRI.BasicRoutingCode = POI.BasicRoutingCode
	WHERE 1=1
			AND @FromYearMonth <= POI.PlanYearMonth 
			AND POI.PlanYearMonth <= @ToYearMonth 
			AND MM.ProductGroupCode LIKE @ProductGroupCode + '%'
			AND POI.MaterialCode LIKE @MaterialCode 
			AND POI.IsCancel = 0 
			AND (@IsFix IS NULL OR POI.IsFix = @IsFix)                                     -- 확정여부
			AND POI.CompanyCode LIKE @CompanyCode 
			AND POI.WorkCenterCode LIKE @WorkCenterCode                            -- 2021.12.02 추가
			--AND  POI.IsFix ='1'
			and mm.ProductGroupCode in ('JELLY-ROLL','SLITTING-ROLL','COATING-ROLL')
	ORDER BY
			POI.PONo

END