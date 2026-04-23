
CREATE PROCEDURE [dbo].[VN_GraphichWareHouse] -- exec [VN_GraphichWareHouse] '','ROH_VN_WH','','','','','','','','','','','','','',''
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pMaterialWarehouseCode VARCHAR(20) = NULL,
						@pMaterialLocationCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pMaterialStockAttribute VARCHAR(20) = NULL,
						@pStockAttrib1 VARCHAR(20) = NULL,
						@pStockAttrib2 VARCHAR(20) = NULL,
						@pStockAttrib3 VARCHAR(20) = NULL,
						@pBasicMaterialType VARCHAR(20) = NULL,
						@pExcludeBasicMaterialTypes VARCHAR(100) = NULL,
						@pMaterialTypeCode VARCHAR(20) = NULL,
						@pProductGroupCode VARCHAR(20) = NULL,
						@pCanPickingOnly BIT = NULL,	                                      
						@pLotID varchar(50) = Null,                                               
						@pTargetMaterialLocationCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '*' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END

	DECLARE @MaterialStockAttribute VARCHAR(20) = CASE WHEN ISNULL(@pMaterialStockAttribute,'') = '' THEN '*' ELSE @pMaterialStockAttribute END
	DECLARE @StockAttrib1 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib1,'') = '' THEN '*' ELSE @pStockAttrib1 END
	DECLARE @StockAttrib2 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib2,'') = '' THEN '*' ELSE @pStockAttrib2 END
	DECLARE @StockAttrib3 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib3,'') = '' THEN '*' ELSE @pStockAttrib3 END
	DECLARE @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '*' ELSE @pBasicMaterialType END
	DECLARE @ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes
	DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
	DECLARE @CanPickingOnly BIT = ISNULL(@pCanPickingOnly, 0)
	DECLARE @LotID varchar(50) =CASE WHEN ISNULL(@pLotID,'') = '' THEN '*' ELSE @pLotID END -->M.SH
	
	CREATE TABLE #Tbl
	(
		ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
		MaterialWarehouseCode NVARCHAR(50) NULL,
		MaterialWarehouseName NVARCHAR(50) NULL,
		CurrentQty INT NULL,
		Stock INT NULL
	)

	;WITH LABELINFO AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= CONVERT(DATE,GETDATE())
	)


	SELECT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
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
			MM.MaterialUnit,
			MLI.MaterialStockAttribute,
			MLI.PackingID,
			MLI.GRDate,
			MLI.MaterialDeliveryNo,
			MLI.MaterialDeliveryDetailNo,
			MLI.InitialQty,
			MLI.CurrentQty,
			MLI.CurrentQty AS StockQty,
			MLI.PickingQty,
			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	
			MLI.BefMaterialLotNo,
			'PartLabel' AS LabelType,			      
			 '자재라벨'  AS LabelFormatName,      
			'Report' AS CommandType,    
			MLI.LotAttr01,
			MLI.LotAttr02,
			MLI.LotAttr03,
			MLI.LotAttr04,
			MLI.LotAttr05,
			MLI.LotAttr06,
			MLI.LotAttr07,
			MLI.LotAttr08,
			MLI.LotAttr09,
			MDLI.LotAttr10    AS LotAttr10 ,
			MM.MMExtText02,
			MM.MMExtText03,
			ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,
			MMExtInt01 AS Effectivemonths,
			1              AS LabelQty                                                                                                                                                      -- 바코드출력라벨 고정인듯 (2020.06.16 추가)
	INTO #MLITemp
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			jOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MLI.MaterialCode = MM.MaterialCode
			JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode
			JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			JOIN STB_MaterialLocation ML WITH(NOLOCK)			ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)		ON MM.MaterialCode = MSAI.MaterialCode                                             -- 추가부분
			JOIN STB_ModelLabelInfo SML WITH(NOLOCK)	 ON SML.ModelCode = MLI.MaterialCode    
			JOIN STB_MaterialDocLotInfo MDLI ON MDLI.LotID = MLI.LotID  AND	 MDLI.LotNo = MLI.LotNo                                                                                          -- 2020.06.16

	WHERE
			(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
			(@WorkCenterCode = '*' OR MLI.WorkCenterCode = @WorkCenterCode) AND
			(@MaterialWarehouseCode = '*' OR MLI.MaterialWarehouseCode LIKE @MaterialWarehouseCode) AND
			(@MaterialLocationCode = '*' OR MLI.MaterialLocationCode LIKE @MaterialLocationCode) AND
			(@MaterialCode = '*' OR MLI.MaterialCode LIKE @MaterialCode) AND
			(@MaterialStockAttribute = '*' OR MLI.MaterialStockAttribute LIKE @MaterialStockAttribute) AND
			--(@StockAttrib1 = '*' OR MLI.StockAttrib1 LIKE @StockAttrib1) AND
			--(@StockAttrib2 = '*' OR MLI.StockAttrib2 LIKE @StockAttrib2) AND
			--(@StockAttrib3 = '*' OR MLI.StockAttrib3 LIKE @StockAttrib3) AND
			(@MaterialTypeCode = '*' OR MT.MaterialTypeCode LIKE @MaterialTypeCode) AND
			(@BasicMaterialType = '*' OR MT.BasicMaterialType LIKE @BasicMaterialType) AND
			 MT.BasicMaterialType NOT IN (
													SELECT
															Item
													FROM
															dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)
										         ) AND 
			(@ProductGroupCode = '*' OR MM.ProductGroupCode LIKE @ProductGroupCode) AND
			MLI.CurrentQty - MLI.PickingQty > 0 AND
			(@LotID = '*' OR MLI.LotID = @LotID)

	
	IF @MaterialCode = '*' Or @MaterialCode = ''
	
		BEGIN


INSERT INTO #Tbl (MaterialWarehouseCode,MaterialWarehouseName,CurrentQty)

SELECT 
						MaterialWarehouseCode,
						MaterialWarehouseName,
						SUM(StockQty) AS Stock
FROM 
						#MLITemp AS a
WHERE 
						MaterialWarehouseCode='ROH_VN_WH'
						GROUP BY MaterialWarehouseCode,MaterialWarehouseName
UNION

SELECT 	
						MaterialWarehouseCode,
						MaterialWarehouseName,
						MaterialName,
						SUM(CurrentQty) AS Currents
FROM   
						#MLITemp  AS a
			
WHERE  
						MaterialWarehouseCode='ROUTE_VN_WH' 
						GROUP BY MaterialWarehouseCode,MaterialWarehouseName

END

SELECT * FROM #Tbl
GROUP BY MaterialWarehouseCode,MaterialWarehouseName
END

	--SUM(StockQty) OVER (PARTITION BY MaterialWarehouseName ORDER BY MaterialWarehouseName) AS ROH_VN_WH