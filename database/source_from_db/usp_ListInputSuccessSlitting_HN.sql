-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-13
-- Description:	Lấy danh sách đã cắt trong tháng
-- =============================================
CREATE PROCEDURE [dbo].[usp_ListInputSuccessSlitting_HN] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20)=NULL,
	@pWorkCenterCode VARCHAR(20)=NULL,
	@pDate Date = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  SET NOCOUNT ON;
	
	DECLARE @DateMoth VARCHAR(20) = Month(@pDate)
	DECLARE @DateYear VARCHAR(20) = Year(@pDate)
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) =CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END 
	--DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END 
	DECLARE @PackingID varchar(50) 

	DECLARE @LotID VARCHAR(50) = CASE WHEN ISNULL('*','') = '' THEN '*' ELSE '*' END 

	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
	Declare @ActualExportQuantity NUMERIC(20,5)

	;WITH Lot AS
	(
		SELECT
				MLI.MaterialLotNo,Lotid
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
		WHERE
				(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
				(@WorkCenterCode = '*' OR  MLI.WorkCenterCode = @WorkCenterCode) AND
				--(@MaterialCode = '*' OR  MLI.MaterialCode = @MaterialCode) AND
				((@MaterialWarehouseCode = '*') OR (MLI.MaterialWarehouseCode = @MaterialWarehouseCode))
				And (MLI.IsParrent ='1' or MLI.IsParrent is not null) -- lấy các lot có IsParrent là lot cha để cắt
				and MLI.IsSlitting = 1  -- chỉ lấy các lot chưa được cắt
				and (@LotID = '*' OR MLI.Lotid = @LotID)
				and Month(MLI.CreateDateSlittingTime)=@DateMoth
				and Year(MLI.CreateDateSlittingTime) = @DateYear
	)    
	SELECT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			MLI.CompanyCode,
			MLI.WorkCenterCode,
			MLI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MLI.MaterialLocationCode,
			ML.MaterialLocationName,
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.PackingID,
			MLI.GRDate,
			MLI.MaterialDeliveryNo,
			MLI.MaterialDeliveryDetailNo,
			MLI.InitialQty,
			MLI.CurrentQty,
			MLI.CurrentQty AS StockQty,
			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼
			MLI.BefMaterialLotNo,
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			MM.MaterialUnit,
			MM.MMExtText02,
			MM.MMExtText03 
			,MLI.isSlitting	
			,MWIOH.ActualExportQuantity 
			,MWIOH.CreateUserID as CreateUserIDOut	 
			,MWIOH.CreateDateTime as CreateDateTimeOut
			,MLI.CreateDateSlittingTime
	FROM
			Lot L
			LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			LEFT OUTER JOIN STB_MaterialWarehouseInOutHist MWIOH WITH(NOLOCK)				ON	MWIOH.Lotid = MLI.Lotid 
				-- DinhManh update 2025-04-10
				AND MWIOH.TargetMaterialWarehouseCode = 'SLITTING_HN_WH' 
				AND MWIOH.CreateDateTime = (SELECT MAX(MWIO2.CreateDateTime) FROM STB_MaterialWarehouseInOutHist MWIO2 where MWIO2.LotID = MWIOH.LotID)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
						
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK)				
			ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15




END

