

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 자재수불관리
-- Description:	생산에 사용한(BOM 기준) 자재의 출고MaterialDocLot을 생성합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialDocLotInfoNotUsedBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20),
	@pMaterialCode VARCHAR(50),
	@pMaterialStockAttribute VARCHAR(20),
	@pMaterialWarehouseCode VARCHAR(20),
	@pMaterialLocationCode VARCHAR(20),
	@pUsedQty NUMERIC(20,5),
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	DECLARE @MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @MaterialStockAttribute VARCHAR(20) = @pMaterialStockAttribute
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,'')
	DECLARE @StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,'')
	DECLARE @UsedQty NUMERIC(20,5) = @pUsedQty
	DECLARE @MaterialWarehouseCode VARCHAR(20) = @pMaterialWarehouseCode
	DECLARE @MaterialLocationCode VARCHAR(20) = @pMaterialLocationCode

	DECLARE @MaterialLotNo VARCHAR(20)
	DECLARE @LotNo VARCHAR(100)
	DECLARE @VendorLotNo VARCHAR(100)
	DECLARE @PackingID VARCHAR(50)
	DECLARE @StockQty NUMERIC(20,5)
	DECLARE @RemainQty NUMERIC(20,5)	
	DECLARE @NeedQty NUMERIC(20,5)
	DECLARE @IsUseBarcode BIT
	DECLARE @IsFIFO BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @UsedMaterialLotNo TABLE
	(
		MaterialLotNo VARCHAR(20)
	)

	SELECT
			@IsUseBarcode = MSAI.IsUseBarcode,
			@IsFIFO = MSAI.IsFIFO
	FROM
			STB_MaterialStockAttributeInfo MSAI
	WHERE
			MSAI.MaterialCode = @MaterialCode

	--IF @IsUseBarcode = 1 BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
	--							'^바코드 사용자재는 자동생산출고 불가합니다^',
	--							@ErrorMessage OUTPUT
	--		SET @ErrorMessage = @ErrorMessage + ' [%s]'
	--		RAISERROR(@ErrorMessage,16,1,@MaterialCode)
	--		RETURN
	--END

	SET @RemainQty = @UsedQty
	SET @NeedQty = @UsedQty

	WHILE @RemainQty > 0 BEGIN
			IF @IsFIFO = 1 BEGIN
					SELECT
							TOP 1
							@MaterialLotNo = MLI.MaterialLotNo,
							@LotNo = MLI.LotNo,
							@VendorLotNo = MLI.VendorLotNo,
							@PackingID = MLI.PackingID,
							@StockQty = MLI.CurrentQty
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							MLI.MaterialWarehouseCode = @MaterialWarehouseCode AND
							MLI.MaterialLocationCode = @MaterialLocationCode AND
							MLI.MaterialCode = @MaterialCode AND
							MLI.MaterialStockAttribute = @MaterialStockAttribute AND
							MLI.StockAttrib1 = @StockAttrib1 AND
							MLI.StockAttrib2 = @StockAttrib2 AND
							MLI.StockAttrib3 = @StockAttrib3 AND
							MLI.MaterialLotNo NOT IN (SELECT MaterialLotNo FROM @UsedMaterialLotNo) AND
							MLI.CurrentQty > 0
					ORDER BY
							--MLI.GRDate,
							--MLI.CurrentQty
							MLI.LotID

			END ELSE BEGIN
					SELECT
							TOP 1
							@MaterialLotNo = MLI.MaterialLotNo,
							@LotNo = MLI.LotNo,
							@VendorLotNo = MLI.VendorLotNo,
							@PackingID = MLI.PackingID,
							@StockQty = MLI.CurrentQty
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							MLI.MaterialWarehouseCode = @MaterialWarehouseCode AND
							MLI.MaterialLocationCode = @MaterialLocationCode AND
							MLI.MaterialCode = @MaterialCode AND
							MLI.MaterialStockAttribute = @MaterialStockAttribute AND
							MLI.StockAttrib1 = @StockAttrib1 AND
							MLI.StockAttrib2 = @StockAttrib2 AND
							MLI.StockAttrib3 = @StockAttrib3 AND
							MLI.MaterialLotNo NOT IN (SELECT MaterialLotNo FROM @UsedMaterialLotNo) AND
							MLI.CurrentQty > 0
					ORDER BY
							--MLI.CurrentQty
							MLI.LotID
			END

			IF ISNULL(@MaterialLotNo,'') = '' BEGIN		-- 재고 없음
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
								'^재고가 없습니다^',
								@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]/[%s]/[%s]/[%s]'
					DECLARE @TotalQty VARCHAR(20) = CONVERT(VARCHAR,@NeedQty)
					DECLARE @NotEnoughQty VARCHAR(20) = CONVERT(VARCHAR,@RemainQty)
					RAISERROR(@ErrorMessage,16,1,@MaterialCode,@MaterialLocationCode,@TotalQty,@NotEnoughQty)
					RETURN
			END

			IF @StockQty > @RemainQty BEGIN
					SET @UsedQty = @RemainQty
					SET @RemainQty = 0
			END ELSE BEGIN
					SET @RemainQty = @RemainQty - @StockQty
					SET @UsedQty = @StockQty
			END

			--DECLARE @StrRemainQty VARCHAR(20) = CONVERT(VARCHAR,@UsedQty)
			--RAISERROR(@StrRemainQty,16,1)
			--RETURN

			-- 공용으로 사용하는 프로시저 내이므로 
			-- 모품목 Lot번호 테이블이 존재하면 처리한다. 2022.09.06 By Jackaroe


			INSERT INTO @UsedMaterialLotNo (MaterialLotNo) VALUES (@MaterialLotNo)
			--MaterialDocLotInfo 생성
			INSERT INTO STB_MaterialDocLotInfo
			(
				MaterialDocDetailNo,
				MDLISeqNo,
				MaterialLotNo,
				LotID,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				StockQty,
				IsChecked,
				MaterialLocationCode,
				MaterialDocNo,
				PackingID,
				LotNo,
				VendorLotNo,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				ISNULL((SELECT COUNT(*) FROM STB_MaterialDocLotInfo WHERE MaterialDocDetailNo = @MaterialDocDetailNo),0) + 1,
				@MaterialLotNo,
				'',
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@UsedQty,
				1,
				@MaterialLocationCode,
				@MaterialDocNo,
				@PackingID,
				@LotNo,
				@VendorLotNo,
				GETDATE(),
				@ProcessUserID
			)

			SET @MaterialLotNo = ''
	END
END

