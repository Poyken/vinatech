
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 자재관리 > [F750]자재재고실사 >  실사반영처리 버튼처리시 호출받는 프로시저
-- Create date: 2018-09-17
-- Description:	재고실사 기준데이터로 DocDetail,DocLotInfo 를 생성합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialDocDetailLotForStocktaking_20200611]
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pMaterialDocNo VARCHAR(20),
						@pMaterialLotNo VARCHAR(20),
						@pMaterialCode VARCHAR(50),
						@pMaterialStockAttribute VARCHAR(20),
						@pLotID VARCHAR(50) = NULL,
						@pStockAttrib1 VARCHAR(20) = NULL,
						@pStockAttrib2 VARCHAR(20) = NULL,
						@pStockAttrib3 VARCHAR(20) = NULL,
						@pMaterialLocationCode VARCHAR(20) = NULL,
						@pRequestQty NUMERIC(20,5)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			@MaterialCode VARCHAR(50) = @pMaterialCode,
			@MaterialStockAttribute VARCHAR(20) = @pMaterialStockAttribute,
			@LotID VARCHAR(50) = ISNULL(@pLotID,''),
			@StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,''),
			@StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,''),
			@StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,''),
			@MaterialLocationCode VARCHAR(20) = @pMaterialLocationCode,
			@RequestQty NUMERIC(20,5) = @pRequestQty

	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MDLISeqNo INT
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@MaterialDocDetailNo = MDD.MaterialDocDetailNo
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo AND
			MDD.MaterialCode = @MaterialCode AND
			MDD.MaterialStockAttribute = @MaterialStockAttribute AND
			MDD.StockAttrib1 = @StockAttrib1 AND
			MDD.StockAttrib2 = @StockAttrib2 AND
			MDD.StockAttrib3 = @StockAttrib3

	IF ISNULL(@MaterialDocDetailNo,'') = '' 
	
	BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @MaterialDocDetailNo OUTPUT

			INSERT INTO STB_MaterialDocDetail
			(
				MaterialDocDetailNo,
				MaterialDocNo,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				RequestQty,
				AllowQty,
				PickingAssignQty,
				PickingQty,
				ProcessFixQty,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				@MaterialDocNo,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@RequestQty,
				@RequestQty,
				@RequestQty,
				@RequestQty,
				0,
				GETDATE(),
				@ProcessUserID
			)
	END ELSE 
	
	BEGIN
			UPDATE	STB_MaterialDocDetail
			SET
					RequestQty = RequestQty + @RequestQty,
					AllowQty = AllowQty + @RequestQty,
					PickingAssignQty = PickingAssignQty + @RequestQty,
					PickingQty = PickingQty + @RequestQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo
	END

	SET @MDLISeqNo = ISNULL((SELECT MAX(MDLISeqNo) FROM STB_MaterialDocLotInfo WHERE MaterialDocDetailNo = @MaterialDocDetailNo),0) + 1

	IF ISNULL(@MaterialLotNo,'') <> ''
	 BEGIN
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
				LotAttr01,
				LotAttr02,
				LotAttr03,
				LotAttr04,
				LotAttr05,
				LotAttr06,
				LotAttr07,
				LotAttr08,
				LotAttr09,
				LotAttr10,
				CreateDateTime,
				CreateUserID
			)
			SELECT
					@MaterialDocDetailNo,
					@MDLISeqNo,
					MLI.MaterialLotNo,
					MLI.LotID,
					MLI.MaterialCode,
					MLI.MaterialStockAttribute,
					MLI.StockAttrib1,
					MLI.StockAttrib2,
					MLI.StockAttrib3,
					@RequestQty,
					1,
					MLI.MaterialLocationCode,
					@MaterialDocNo,
					MLI.PackingID,
					MLI.LotNo,
					MLI.VendorLotNo,
					MLI.LotAttr01,
					MLI.LotAttr02,
					MLI.LotAttr03,
					MLI.LotAttr04,
					MLI.LotAttr05,
					MLI.LotAttr06,
					MLI.LotAttr07,
					MLI.LotAttr08,
					MLI.LotAttr09,
					MLI.LotAttr10,
					GETDATE(),
					@ProcessUserID
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.MaterialLotNo = @MaterialLotNo
	END ELSE BEGIN		-- MaterialLot에 없는 품목 입고할때
			DECLARE @IsUseBarcode BIT

			SELECT
					@IsUseBarcode = MSA.IsUseBarcode
			FROM
					STB_MaterialStockAttributeInfo MSA
			WHERE
					MSA.MaterialCode = @MaterialCode

			IF @IsUseBarcode = 1 AND @LotID = ''           -- 바코드 없는지 체크		
					BEGIN
				 			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																				'^바코드 사용품목은 바코드가 필수입니다^',
																				@ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s]'
							RAISERROR(@ErrorMessage,16,1,@MaterialCode)
							RETURN
					END

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
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				@MDLISeqNo,
				'',
				@LotID,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@RequestQty,
				1,
				@MaterialLocationCode,
				@MaterialDocNo,
				@LotID,
				GETDATE(),
				@ProcessUserID
			)
	END

END