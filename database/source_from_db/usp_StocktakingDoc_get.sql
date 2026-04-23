
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-16
-- Browsable : true
-- Group : 재고실사 > [G650] 제품재고실사 & 자재관리 > 자재재고실사
-- Description:	재고실사문저정보를 조회합니다.
-- Modified:
-- [프로시저 실행] :  usp_StocktakingDoc_get '','','VNT','VNT_F1', '', '', 'PROD_STBY_WH', '2020-07-10','2020-07-15',''
--                        usp_StocktakingDoc_get 'kilee','Korean','VNT','', 'VNT_F1', '', '', '2020-07-10' ,'2020-09-15', ''

--                        usp_StocktakingDoc_get 'kilee','Korean','VNT','', 'VNT_F1', '', '', '2020-08-01' ,'2020-09-15', '', 'ROH_WH,PROD_STBY_WH'
--                           usp_StocktakingDoc_get 'kilee','Korean','VNT','', 'VNT_F1', '', '', '2020-08-01' ,'2020-09-15', '', 'PROD_STBY_WH'
--                           usp_StocktakingDoc_get 'kilee', 'Korean', 'VNT', '', 'VNT_F1', '', 'ROH_WH', '2020-08-01' ,'2020-09-15', ''
-- ==============================================================================

CREATE PROCEDURE [dbo].[usp_StocktakingDoc_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL,

	@pMaterialWarehouseCode VARCHAR(20) = NULL,	     --2020.07.14 추가

	@pFromBasicDate DATE = NULL,
	@pToBasicDate DATE = NULL,
	@pExcludeBasicMaterialTypes VARCHAR(100) = NULL

	--, @pCostGroupString VARCHAR(MAX) = NULL     --추가

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '%' ELSE @pMaterialWarehouseCode END    --2020.07.14 추가

	DECLARE @FromBasicDate DATE = CASE WHEN ISNULL(@pFromBasicDate,'') = '' THEN  GETDATE() ELSE @pFromBasicDate END
	DECLARE @ToBasicDate DATE = CASE WHEN ISNULL(@pToBasicDate,'') = '' THEN GETDATE() ELSE @pToBasicDate END
	--DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')
    
	SELECT
			SD.StocktakingDocNo AS OldStocktakingDocNo,
			SD.StocktakingDocNo,
			SD.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			SD.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			SD.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MW.MaterialWarehouseNameL,
			MW.MaterialWarehouseDesc,
			MW.MaterialWarehouseDescL,
			MW.DefaultLocationCode,
			SD.MLExtText01,
			SD.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			MM.ProductGroupCode,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			SD.BasicDate,
			SD.StocktakingDesc,
			CASE WHEN ISNULL(SD.IsFinish,0) = 0 THEN CONVERT(BIT,0)
			ELSE CONVERT(BIT,1) END AS IsFinish,
			SD.CreateDateTime,
			SD.CreateUserID,
			SD.ChangeDateTime,
			SD.ChangeUserID,
			@pExcludeBasicMaterialTypes AS ExcludeBasicMaterialTypes
	FROM
			STB_StocktakingDoc SD WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)				ON MW.MaterialWarehouseCode = SD.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MM.MaterialCode = SD.MaterialCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON WCI.WorkCenterCode = SD.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = SD.CompanyCode
	WHERE 1=1
	AND	((SD.BasicDate >= @FromBasicDate) AND (@ToBasicDate >= SD.BasicDate)) 
	AND 	SD.CompanyCode LIKE @CompanyCode 
	AND	SD.WorkCenterCode LIKE @WorkCenterCode
	--AND SD.MaterialWarehouseCode LIKE @MaterialWarehouseCode


	 --AND SD.MaterialWarehouseCode  IN (
		--												SELECT MaterialWarehouseCode 
		--												FROM STB_MaterialWarehouse 
		--												WHERE 1=1 
		--													AND MaterialWarehouseCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString) )															
		--												)

--	 AND SD.MaterialWarehouseCode  IN ('ROH_VN_WH', 'ROH_WH')

END

-- SELECT Item FROM dbo.fnSplitToTable(',',  'ROH_VN_WH, ROH_WH')

