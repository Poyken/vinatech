

-- =============================================
-- Author:	    Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-11-08
-- Browsable : true
-- Group : MaterialStock
-- Description:	미발행 RouteMaterialLotInfo 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRoouteMaterialLotInfoIsNotPrint]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL,
	@pMaterialLocationZone NVARCHAR(50) = NULL, 
	@pMaterialLocationCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(50) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END 
	DECLARE @WorkCenterCode VARCHAR(50) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = @pMaterialWarehouseCode
	DECLARE @MaterialLocationZone NVARCHAR(50) = @pMaterialLocationZone
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '*' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID

    
	DECLARE @RouteMaterialLotInfo TABLE
	(
		IDX INT IDENTITY, 
		MaterialLotNo VARCHAR(20)
	)



	SELECT
			RMLI.MaterialLotNo,
			RMLI.LotID,
			RMLI.CompanyCode,
			RMLI.WorkCenterCode,
			RMLI.MaterialWarehouseCode,
			RMLI.MaterialLocationCode,
			RMLI.MaterialCode,
			RMLI.MaterialStockAttribute,
			RMLI.StockAttrib1,
			RMLI.StockAttrib2,
			RMLI.StockAttrib3,
			RMLI.PackingID,
			CONVERT(VARCHAR(10),CONVERT(DATE,RMLI.GRDate)) AS GRDate,
			RMLI.MaterialDeliveryNo,
			RMLI.MaterialDeliveryDetailNo,
			RMLI.InitialQty,
			RMLI.CurrentQty,
			RMLI.PickingQty,
			RMLI.VendorLotNo,
			RMLI.LifeBasicDate,
			RMLI.ProductionDate,
			RMLI.EndOfLifeDate,
			--RMLI.LotNo,
			RMLI.IsSplitLot,
			RMLI.BefMaterialLotNo,
			RMLI.LotAttr01,				--MODEL
			RMLI.LotAttr02,				--PONumber
			RMLI.LotAttr03,
			RMLI.LotAttr04,
			RMLI.LotAttr05,
			RMLI.LotAttr06,
			RMLI.LotAttr07,
			RMLI.LotAttr08,
			RMLI.LotAttr09,
			RMLI.LotAttr10,
			RMLI.IsPrint,
			RMLI.CreateDateTime,
			RMLI.CreateUserID,
			'MATERIAL' AS LabelType,
			--Label.FormatName AS LabelFormatName
			'MaterialLabel' AS LabelFormatName,
			'Report' AS CommandType,
			MM.MMExtText02,
			MM.MMExtText03,
			MM.MMExtText04,
			MM.MMExtInt01,
			RMLI.CurrentQty AS StockQty,
			MM.MaterialUnit,
			MM.MaterialName,
			CASE	
					WHEN ISNULL(RMLI.LotAttr02,'') <> '' THEN RMLI.LotAttr02
					ELSE RMLI.LotNo
			END AS LotNo,
			RMLI.LotAttr03 AS CustomerName,
			MM.MaterialSpec,
			MM.AltMaterialCode Packing_Code
	FROM
			STB_RouteMaterialLotInfo RMLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON MW.MaterialWarehouseCode = RMLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON ML.MaterialWarehouseCode = RMLI.MaterialWarehouseCode
				AND ML.MaterialLocationCode = RMLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = RMLI.MaterialCode
			--LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK)
			--	ON (Label.LabelType = 'BOX_Label' AND Label.ModelCode = RMLI.MaterialCode)
			
	WHERE
			((@CompanyCode = '*') OR (RMLI.CompanyCode = @CompanyCode))  AND
			((@WorkCenterCode = '*') OR (RMLI.WorkCenterCode = @WorkCenterCode))  AND
			((RMLI.MaterialWarehouseCode = @MaterialWarehouseCode)) AND
			((ML.MLExtText01 = @MaterialLocationZone)) AND
			((@MaterialLocationCode = '*') OR (RMLI.MaterialLocationCode = @MaterialLocationCode)) AND
			((@MaterialCode = '*') OR (RMLI.MaterialCode = @MaterialCode)) AND
			((RMLI.CreateUserID = @ProcessUserID)) AND
			((RMLI.IsPrint = 0)) AND
			((ML.IsUseLotID = 0))



	INSERT @RouteMaterialLotInfo
	SELECT
			RMLI.MaterialLotNo
	FROM
			STB_RouteMaterialLotInfo RMLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON ML.MaterialWarehouseCode = RMLI.MaterialWarehouseCode
				AND ML.MaterialLocationCode = RMLI.MaterialLocationCode
	WHERE
			((@CompanyCode = '*') OR (RMLI.CompanyCode = @CompanyCode))  AND
			((@WorkCenterCode = '*') OR (RMLI.WorkCenterCode = @WorkCenterCode))  AND
			((RMLI.MaterialWarehouseCode = @MaterialWarehouseCode)) AND
			((ML.MLExtText01 = @MaterialLocationZone)) AND
			((@MaterialLocationCode = '*') OR (RMLI.MaterialLocationCode = @MaterialLocationCode)) AND
			((@MaterialCode = '*') OR (RMLI.MaterialCode = @MaterialCode)) AND
			((RMLI.CreateUserID = @ProcessUserID)) AND
			((RMLI.IsPrint = 0)) AND
			((ML.IsUseLotID = 0))

	

	DECLARE @RowCnt INT
	DECLARE @InitCnt INT
	DECLARE @MaterialLotNo VARCHAR(20)

	SET @RowCnt = (SELECT COUNT(*) FROM @RouteMaterialLotInfo)
	SET @InitCnt = 1

	WHILE (@InitCnt <= @RowCnt) BEGIN
		SELECT
				@MaterialLotNo = MaterialLotNo
		FROM
				@RouteMaterialLotInfo
		WHERE
				IDX = @InitCnt

		UPDATE STB_RouteMaterialLotInfo
		SET
				IsPrint = 1
		WHERE
				MaterialLotNo = @MaterialLotNo

		SET @InitCnt = @InitCnt + 1

	END

END



