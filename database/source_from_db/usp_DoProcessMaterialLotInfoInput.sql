

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 시스템
-- Create date: <2016-06-17>
-- Description:	자재 재고를 증가처리 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessMaterialLotInfoInput]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pLotID VARCHAR(50),
	@pMaterialWarehouseCode VARCHAR(20),
	@pMaterialLocationCode VARCHAR(20),
	@pMaterialStockAttribute VARCHAR(20),
	@pStockAttrib1 VARCHAR(20),
	@pStockAttrib2 VARCHAR(20),
	@pStockAttrib3 VARCHAR(20),
	@pMaterialCode VARCHAR(50),
	@pLotNo VARCHAR(100) = NULL,
	@pVendorLotNo VARCHAR(100) = NULL,		-- 2018-08-28 JGH VendorLotNo 추가
	@pUsedQty NUMERIC(20,5),
	@pPackingID VARCHAR(50) = NULL,
	@pProcessUserID VARCHAR(20),
	@pGRDate DATE = NULL,
	@pLotAttr01 NVARCHAR(100) = NULL,
	@pLotAttr02 NVARCHAR(100) = NULL,
	@pLotAttr03 NVARCHAR(100) = NULL,
	@pLotAttr04 NVARCHAR(100) = NULL,
	@pLotAttr05 NVARCHAR(100) = NULL,
	@pLotAttr06 NVARCHAR(100) = NULL,
	@pLotAttr07 NVARCHAR(100) = NULL,
	@pLotAttr08 NVARCHAR(100) = NULL,
	@pLotAttr09 NVARCHAR(100) = NULL,
	@pLotAttr10 NVARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode,
			@UsedQty NUMERIC(20,5) = @pUsedQty,
			@MaterialStockAttribute VARCHAR(20) = ISNULL(@pMaterialStockAttribute,''),
														  
			@StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,''),
			@StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,''),
			@StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,''),
			@MaterialLotNo VARCHAR(20),
			@IsFIFO BIT = NULL,
			@LotNo VARCHAR(100) = ISNULL(@pLotNo,''),
			@VendorLotNo VARCHAR(100) = ISNULL(@pVendorLotNo,''),		-- 2018-08-28 JGH VendorLotNo 추가		
			@PackingID VARCHAR(50) = ISNULL(@pPackingID,''),
			@LotAttr01 NVARCHAR(100) = ISNULL(@pLotAttr01,''),
			@LotAttr02 NVARCHAR(100) = ISNULL(@pLotAttr02,''),
			@LotAttr03 NVARCHAR(100) = ISNULL(@pLotAttr03,''),
			@LotAttr04 NVARCHAR(100) = ISNULL(@pLotAttr04,''),
			@LotAttr05 NVARCHAR(100) = ISNULL(@pLotAttr05,''),
			@LotAttr06 NVARCHAR(100) = ISNULL(@pLotAttr06,''),
			@LotAttr07 NVARCHAR(100) = ISNULL(@pLotAttr07,''),
			@LotAttr08 NVARCHAR(100) = ISNULL(@pLotAttr08,''),
			@LotAttr09 NVARCHAR(100) = ISNULL(@pLotAttr09,''),
			@LotAttr10 NVARCHAR(100) = ISNULL(@pLotAttr10,'')

	DECLARE @IsToRouteMaterial BIT

	SELECT
			@IsToRouteMaterial = CASE 
									WHEN ISNULL(ML.IsUseLotID, 0) = 1 THEN 0
									ELSE 1
								END
	FROM
			STB_MaterialLocation ML
	WHERE
			ML.MaterialLocationCode = @pMaterialLocationCode	


	SELECT
			@IsFIFO = MSAI.IsFIFO
	FROM
			STB_MaterialStockAttributeInfo MSAI WITH (NOLOCK)
	WHERE
			MSAI.MaterialCode = @MaterialCode
					
	IF ISNULL(@IsFIFO,0) = 0
	BEGIN
			SELECT
					TOP 1
					@MaterialLotNo = MLI.MaterialLotNo
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.CompanyCode = @pCompanyCode AND
					MLI.WorkCenterCode = @pWorkCenterCode AND
					MLI.LotID = @pLotID AND
					MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
					MLI.MaterialLocationCode = @pMaterialLocationCode AND
					MLI.MaterialStockAttribute = @MaterialStockAttribute AND
					MLI.StockAttrib1 = @pStockAttrib1 AND
					MLI.StockAttrib2 = @pStockAttrib2 AND
					MLI.StockAttrib3 = @pStockAttrib3 AND
					MLI.MaterialCode = @MaterialCode AND
					MLI.LotNo = @LotNo AND
					MLI.PackingID = @PackingID AND
					MLI.VendorLotNo = @VendorLotNo		-- 2018-08-28 JGH VendorLotNo 추가

	END ELSE BEGIN
			IF @pGRDate IS NULL
			BEGIN
				SET @pGRDate = GETDATE()
			END

			SELECT
					TOP 1
					@MaterialLotNo = MLI.MaterialLotNo
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.CompanyCode = @pCompanyCode AND
					MLI.WorkCenterCode = @pWorkCenterCode AND
					MLI.LotID = @pLotID AND
					MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
					MLI.MaterialLocationCode = @pMaterialLocationCode AND
					MLI.MaterialStockAttribute = @MaterialStockAttribute AND
					MLI.StockAttrib1 = @pStockAttrib1 AND
					MLI.StockAttrib2 = @pStockAttrib2 AND
					MLI.StockAttrib3 = @pStockAttrib3 AND
					MLI.MaterialCode = @MaterialCode AND
					MLI.LotNo = @LotNo AND
					MLI.PackingID = @PackingID AND
					MLI.GRDate = CONVERT(VARCHAR(10), @pGRDate, 120) AND
					MLI.VendorLotNo = @VendorLotNo		-- 2018-08-28 JGH VendorLotNo 추가

			IF @MaterialLotNo IS NULL
			BEGIN
					SELECT
							TOP 1
							@MaterialLotNo = MLI.MaterialLotNo
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							MLI.CompanyCode = @pCompanyCode AND
							MLI.WorkCenterCode = @pWorkCenterCode AND
							MLI.LotID = @pLotID AND
							MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
							MLI.MaterialLocationCode = @pMaterialLocationCode AND
							MLI.MaterialStockAttribute = @MaterialStockAttribute AND
							MLI.StockAttrib1 = @pStockAttrib1 AND
							MLI.StockAttrib2 = @pStockAttrib2 AND
							MLI.StockAttrib3 = @pStockAttrib3 AND
							MLI.MaterialCode = @MaterialCode AND
							MLI.CurrentQty < 0
					ORDER BY
							MLI.GRDate
			END
	END

	

	IF ISNULL(@MaterialLotNo,'') = ''
	BEGIN
		-- MaterialLotNo 생성 후 입고처리
		EXEC usp_DoProcessNewMaterialLotNo	@pCompanyCode = @pCompanyCode,
											@pWorkCenterCode = @pWorkCenterCode,
											@pLotID = @pLotID,
											@pMaterialWarehouseCode = @pMaterialWarehouseCode,
											@pMaterialLocationCode = @pMaterialLocationCode,
											@pMaterialStockAttribute = @MaterialStockAttribute,
											@pStockAttrib1 = @StockAttrib1,
											@pStockAttrib2 = @StockAttrib2,
											@pStockAttrib3 = @StockAttrib3,
											@pMaterialCode = @MaterialCode,
											@pLotNo = @LotNo,
											@pVendorLotNo = @VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
											@pUsedQty = @UsedQty,
											@pProcessUserID = @pProcessUserID,
											@pGRDate = @pGRDate,
											@pPackingID = @pPackingID,
											@pLotAttr01 = @LotAttr01,
											@pLotAttr02 = @LotAttr02,
											@pLotAttr03 = @LotAttr03,
											@pLotAttr04 = @LotAttr04,
											@pLotAttr05 = @LotAttr05,
											@pLotAttr06 = @LotAttr06,
											@pLotAttr07 = @LotAttr07,
											@pLotAttr08 = @LotAttr08,
											@pLotAttr09 = @LotAttr09,
											@pLotAttr10 = @LotAttr10,
											@pMaterialLotNo = @MaterialLotNo OUTPUT
			
	END
	ELSE BEGIN
		UPDATE STB_MaterialLotInfo
		SET
				CurrentQty = CurrentQty + @UsedQty
		WHERE
				MaterialLotNo = @MaterialLotNo
	END 
	

	IF @IsToRouteMaterial = 1
	BEGIN
			EXEC usp_MaterialLotInfoToRouteMaterialLotInfo @pMaterialLotNo = @MaterialLotNo
	END


END

