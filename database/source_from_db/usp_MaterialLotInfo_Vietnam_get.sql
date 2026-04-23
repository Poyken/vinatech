

CREATE PROCEDURE [dbo].[usp_MaterialLotInfo_Vietnam_get]
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
						@pCanPickingOnly BIT = NULL,	                                          -- 피킹이 가능한 재고만 조회
						@pLotID varchar(50) = Null,                                                  -- M.SH
						@pTargetMaterialLocationCode VARCHAR(20) = NULL
					--	@pLabelType NVARCHAR(60) = NULL                                     -- 2020.06.16 추가 (구보겸)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '*' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	--DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' 
	--                                                               WHEN @pMaterialCode = '%'  THEN '*' 	ELSE @pMaterialCode END

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
	----DECLARE @LabelType               NVARCHAR(60) = @pLabelType                                           -- 2020.06.16 추가 (구보겸)
    

	--;WITH LABELINFO AS
	--(
	--	SELECT
	--			RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
	--			LI.LabelType,
	--			LI.FormatName,
	--			LI.CommandType,
	--			LI.Dpi,
	--			LI.PrinterName
	--	FROM
	--			SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
	--	WHERE
	--			LI.IsApproval = 1 AND
	--			LI.ApplyDate <= GETDATE()
	--)


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
			MM.MaterialUnit,
			MLI.MaterialStockAttribute,
			--MLI.StockAttrib1,
			--MLI.StockAttrib2,
			--MLI.StockAttrib3,
			MLI.PackingID,
			MLI.GRDate,
			MLI.MaterialDeliveryNo,
			MLI.MaterialDeliveryDetailNo,
			MLI.InitialQty,
			isnull((select top 1 PackQty from STB_SavePackingTime_VVT where LotNo=MLI.LotNo and PackingID=MLI.PackingID and PackQty>1
				 and  (isPrinted is null or isPrinted=0) ),MLI.CurrentQty) as CurrentQty,
			isnull((select top 1 PackQty from STB_SavePackingTime_VVT where LotNo=MLI.LotNo and PackingID=MLI.PackingID and PackQty>1
				 and  (isPrinted is null or isPrinted=0)  ),MLI.CurrentQty) AS StockQty,
			MLI.PickingQty,
			isnull((select top 1 PackQty from STB_SavePackingTime_VVT where LotNo=MLI.LotNo and PackingID=MLI.PackingID and PackQty>1
				 and  (isPrinted is null or isPrinted=0)  ),MLI.CurrentQty) - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼
			MLI.BefMaterialLotNo,
			--MLI.CreateDateTime,
			--MLI.CreateUserID,
			--MLI.ChangeDateTime,
			--MLI.ChangeUserID,
			--'MATERIAL_LABEL' AS LabelType,
			--Label.FormatName AS LabelFormatName,

			'PartLabel' AS LabelType,			       -- 자재라벨로 Fix (2020.06.16)  'PartLabel' 
			 '자재라벨'  AS LabelFormatName,       -- 자재라벨로 Fix (2020.06.16)
			'Report' AS CommandType,               -- 자재라벨로 Fix (2020.06.16) 
				
			MLI.LotAttr01,
			MLI.LotAttr02,
			MLI.LotAttr03,
			MLI.LotAttr04,
			MLI.LotAttr05,
			MLI.LotAttr06,
			MLI.LotAttr07,
			MLI.LotAttr08,
			MLI.LotAttr09,			
			-- 추가부분 (kilee)
			--CONVERT(DATE, MLI.LotAttr10)                                                                                                                                 AS LotAttr10,		 -- 제조일자	(원본)
			MLI.LotAttr10                                                                                                                                                         AS LotAttr10 ,
			CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.LotAttr10), 121)), 121) AS PackDate,
			MM.MMExtText02,
			MM.MMExtText03,
			ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,
			MMExtInt01 AS Effectivemonths,
			1              AS LabelQty                                                                                                                                                      -- 바코드출력라벨 고정인듯 (2020.06.16 추가)
	--INTO #MLITemp
	FROM  STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			       ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				       ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				       ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		       ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)			       ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
		--  LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK)	       --	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)	ON MM.MaterialCode = MSAI.MaterialCode                                             -- 추가부분			
		--	LEFT OUTER JOIN STB_ModelLabelInfo SML WITH(NOLOCK)	 ON SML.ModelCode = MLI.MaterialCode           --    AND	 SML.LabelType = @LabelType                                                          -- 2020.06.16			
		--  LEFT OUTER JOIN LABELINFO LBI		 WITH(NOLOCK)			                         ON LBI.LabelType = @LabelType                          AND	 LBI.FormatName = SML.FormatName    AND	LBI.RankIndex = 1                -- 2020.06.16
		--	 LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK)					     ON MDLI.LotID = MLI.LotID           AND  MDLI.PackingID = MLI.PackingID   

	WHERE
			(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
			(@WorkCenterCode = '*' OR MLI.WorkCenterCode = @WorkCenterCode) AND
			--(@MaterialWarehouseCode = '*' OR MLI.MaterialWarehouseCode = @MaterialWarehouseCode) AND
			MLI.MaterialWarehouseCode =  'PROD_STBY_VN_WH' and
			(@MaterialLocationCode = '*' OR MLI.MaterialLocationCode = @MaterialLocationCode) AND
			(@MaterialCode = '*' OR MLI.MaterialCode = @MaterialCode) AND
			(@MaterialStockAttribute = '*' OR MLI.MaterialStockAttribute = @MaterialStockAttribute) AND
			(@StockAttrib1 = '*' OR MLI.StockAttrib1 = @StockAttrib1) AND
			(@StockAttrib2 = '*' OR MLI.StockAttrib2 = @StockAttrib2) AND
			(@StockAttrib3 = '*' OR MLI.StockAttrib3 = @StockAttrib3) AND
			(@MaterialTypeCode = '*' OR MT.MaterialTypeCode = @MaterialTypeCode) AND
			(@BasicMaterialType = '*' OR MT.BasicMaterialType = @BasicMaterialType) 
			/*
			AND
			MT.BasicMaterialType NOT IN (
													SELECT
															Item
													FROM
															dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)
										             )
			*/
			AND (@ProductGroupCode = '*' OR MM.ProductGroupCode = @ProductGroupCode) 
			AND MLI.CurrentQty - MLI.PickingQty > 0 
			AND (@LotID = '*' OR MLI.LotID = @LotID)
			and MLI.CreateDateTime>'2020-08-19'

	--#200611
	--전체리스트 화면에 해당 내용을 적용할 경우 검색 속도에 문제가 생겨
	--품목코드가 넘어오고, 원자재창고인 경우에만 추가되도록 조치함.
	--IF (@MaterialCode <> '*' AND @MaterialCode <> '') AND @MaterialWarehouseCode = 'ROH_WH'
	--	BEGIN
	--		SELECT *
	--				,dbo.fnGetERPUnitPrice(MaterialCode) AS UnitPrice
	--				,dbo.fnGetERPCurrencyType(MaterialCode) AS CurrencyType
	--				,dbo.fnGetERPUnitPrice(MaterialCode) * CurrentQty AS Price
	--				,dbo.fnGetERPConvertPrice(MaterialCode) * CurrentQty AS ConvertPrice
	--			FROM #MLITemp
	--	END
	--ELSE 
	--	BEGIN
	--			SELECT *
	--			  FROM #MLITemp
	--	END 
		

END
