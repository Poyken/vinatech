
-- =========================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-20
-- Browsable : true
-- Group : 지지체
-- Description:	재고 자재리스트를 조회합니다.
-- Modified:
-- =========================================================================
CREATE PROCEDURE usp_MaterialLotInfoForSPT_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
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
						@pLotNo varchar(80) = Null,
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
	DECLARE @LotNo varchar(50) =CASE WHEN ISNULL(@pLotNo,'') = '' THEN '*' ELSE @pLotNo END 
    
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
			MM.ProductGroupCode AS productGroupCode,
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
			MLI.LotAttr10                                                                                                                                                         AS LotAttr10 ,
			Case When MM.MMExtInt01 is null                          Then MLI.LotAttr10
			       When @MaterialWarehouseCode = 'ROUTE_WH' Then MLI.LotAttr10
			         Else 	CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.LotAttr10), 121)), 121) end AS PackDate,
			MM.MMExtText02,
			MM.MMExtText03,
			ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,
			MMExtInt01 AS Effectivemonths,
			1               AS LabelQty ,
			MM.BasicCostPrice AS BasicCostPrice,                                   -- 표준원가
			(MM.BasicCostPrice * MLI.CurrentQty)  AS CurrentAmount,        -- 금액
			CONVERT(CHAR(10), DATEADD(month, 1, GETDATE()), 121) AS ChkMonth,
			CONVERT(CHAR(10), DATEADD(day, 1, GETDATE()), 121) AS ChkDay,
			ISNULL(MQD1.DecisionResult, MQI1.DecisionResult) AS IcpResult,
			ISNULL(MQD2.DecisionResult, MQI2.DecisionResult) AS WeightResult
	FROM  STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			        ON MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				    ON MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				    ON PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		        ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)			    ON ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)	ON MM.MaterialCode = MSAI.MaterialCode
			LEFT OUTER JOIN STB_MaterialQcDetail MQD1
			  ON MQD1.MaterialQcNo = MLI.LotNo
			 AND MQD1.QcInspectionItemCode = 'PQC_SPT_001'
			LEFT OUTER JOIN STB_MaterialQcDetail MQD2
			  ON MQD1.MaterialQcNo = MLI.LotNo
			 AND MQD1.QcInspectionItemCode = 'PQC_SPT_002'
			LEFT OUTER JOIN STB_MaterialQcInfo MQI1
			  ON MQI1.MaterialQcNo = MQD1.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialQcInfo MQI2
			  ON MQI2.MaterialQcNo = MQD2.MaterialQcNo
	WHERE
			(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
			(@WorkCenterCode = '*' OR MLI.WorkCenterCode = @WorkCenterCode) AND
			(@MaterialWarehouseCode = '*' OR MLI.MaterialWarehouseCode = @MaterialWarehouseCode) AND
			(@MaterialLocationCode = '*' OR MLI.MaterialLocationCode = @MaterialLocationCode) AND
			(@MaterialCode = '*' OR MLI.MaterialCode = @MaterialCode) AND
			(@MaterialStockAttribute = '*' OR MLI.MaterialStockAttribute = @MaterialStockAttribute) AND
			(@StockAttrib1 = '*' OR MLI.StockAttrib1 = @StockAttrib1) AND
			(@StockAttrib2 = '*' OR MLI.StockAttrib2 = @StockAttrib2) AND
			(@StockAttrib3 = '*' OR MLI.StockAttrib3 = @StockAttrib3) AND
			(@MaterialTypeCode = '*' OR MT.MaterialTypeCode = @MaterialTypeCode) AND
			(@BasicMaterialType = '*' OR MT.BasicMaterialType = @BasicMaterialType)  
			AND (@ProductGroupCode = '*' OR MM.ProductGroupCode = @ProductGroupCode) 
			AND MLI.CurrentQty - MLI.PickingQty > 0 
			AND (@LotID = '*' OR MLI.LotID = @LotID)
			AND (@LotNo = '*' OR MLI.LotNo = @LotNo)              -- 2021.01.08 추가
END
