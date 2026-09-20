-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Group : 재고관리
-- Browsable : true
-- Create date: 2025-03-08
-- Description: 재고를 Split 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSplitLotWithAllNewPackingID]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialLotNo VARCHAR(20),
	@pSplitQty NUMERIC(20,5)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			@SplitQty NUMERIC(20,5) = @pSplitQty,
			@LotID VARCHAR(50),
			@MaterialCode VARCHAR(50),
			@CurrentQty NUMERIC(20,5),
			@PickingQty NUMERIC(20,5),
			@ErrorMessage NVARCHAR(MAX),
			@OriginalPackingID VARCHAR(20)
	
	SELECT
			@LotID = MLI.LotID,
			@MaterialCode =  MLI.MaterialCode,
			@CurrentQty = MLI.CurrentQty,
			@PickingQty = ISNULL(MLI.PickingQty,0),
			@OriginalPackingID = MLI.PackingID
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	IF ISNULL(@MaterialCode,'') = '' BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^재고정보를 찾을 수 없습니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF ISNULL(@LotID,'') = '' BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^바코드가 없습니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @PickingQty > 0 BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^피킹중인 재고는 분리할 수 없습니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @SplitQty < 0 BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^Disallow minus q''ty^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @CurrentQty <= @SplitQty BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^분리할 수량은 재고보다 적어야 합니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM STB_PackingLabelPrintHist WHERE PackingID = @OriginalPackingID) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '원본 패킹ID의 출력 이력이 존재하지 않습니다. 박스를 정보를 분리할 수 없습니다.'

		RETURN
	END

	IF @SplitQty <= 0 BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '소분 수량은 0일 수 없습니다.'

		RETURN
	END

	DECLARE @NewMaterialLotNo VARCHAR(20)
	EXEC SmartFramework.dbo.usp_DoCreateSerial @pTableName = 'STB_MaterialLotInfo',
							@pSerialNo = @NewMaterialLotNo OUTPUT
	DECLARE @NewLotID VARCHAR(20)
	EXEC SmartFramework.dbo.usp_DoCreateSerial @pTableName = 'STB_MaterialDocLotInfo',
							@pSerialNo = @NewLotID OUTPUT

	DECLARE @CurrentDate DATE,
			@CurrentDayString VARCHAR(8),
			@FourYearString VARCHAR(4),
			@TwoYearString VARCHAR(4),
			@MonthString VARCHAR(2),
			@DayString VARCHAR(2),
			@LastPrefixData VARCHAR(20),
			@LastSerialNo bigINT
			
	SET @CurrentDate = GETDATE()
	
	SET @CurrentDayString = CONVERT(VARCHAR, @CurrentDate, 112)
	
	SET @FourYearString = SUBSTRING(@CurrentDayString, 1, 4)
	SET @TwoYearString = SUBSTRING(@CurrentDayString, 3, 2)
	SET @MonthString = SUBSTRING(@CurrentDayString, 5, 2)
	SET @DayString = SUBSTRING(@CurrentDayString, 7, 2)

	select  @LastSerialNo=isnull(max( cast(substring(LotID ,3,14)as bigint)+1),0) from STB_MaterialLotInfo -->M.sh
	where left(LotID,2)='SP'-->M.sh
	
	declare @LotIDNew varchar(20)-->M.sh
	
	set @LotIDNew ='SP'+@FourYearString+@MonthString+@DayString +right(@LastSerialNo,6) -->M.sh


	INSERT INTO [dbo].[STB_MaterialLotInfo]
	(
		MaterialLotNo,
		LotID,
		CompanyCode,
		WorkCenterCode,
		MaterialWarehouseCode,
		MaterialLocationCode,
		MaterialCode,
		MaterialStockAttribute,
		StockAttrib1,
		StockAttrib2,
		StockAttrib3,
		PackingID,
		GRDate,
		MaterialDeliveryNo,
		MaterialDeliveryDetailNo,
		InitialQty,
		CurrentQty,
		PickingQty,
		VendorLotNo,
		LifeBasicDate,
		ProductionDate,
		EndOfLifeDate,
		LotNo,
		IsSplitLot,
		BefMaterialLotNo,
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
			@NewMaterialLotNo,
			@LotIDNew,--@NewLotID,
			CompanyCode,
			WorkCenterCode,
			MaterialWarehouseCode,
			MaterialLocationCode,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			'PKSPK'+RIGHT(@LotIDNew, 6),--PackingID,
			GRDate,
			MaterialDeliveryNo,
			MaterialDeliveryDetailNo,
			@SplitQty AS InitialQty,
			@SplitQty AS CurrentQty,
			0 AS PickingQty,
			VendorLotNo,
			LifeBasicDate,
			ProductionDate,
			EndOfLifeDate,
			LotNo,
			1 AS IsSplitLot,
			CASE 
				WHEN ISNULL(BefMaterialLotNo,'') = '' THEN MaterialLotNo
				ELSE BefMaterialLotNo
			END,
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
			GETDATE(),
			@ProcessUserID
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	-- 오리지널 Packing ID를 사용하지 않고, 신규 패킹ID로 업데이트한다. 2025.03.08
	select  @LastSerialNo=isnull(max( cast(substring(LotID ,3,14)as bigint)+1),0) from STB_MaterialLotInfo -->M.sh
	where left(LotID,2)='SP'

	declare @LotIDNew2 varchar(20)-->M.sh

	set @LotIDNew2 ='SP'+@FourYearString+@MonthString+@DayString +right(@LastSerialNo,6) -->M.sh

	UPDATE
			STB_MaterialLotInfo
	SET
			LotID = @LotIDNew2,
			CurrentQty = CurrentQty - @SplitQty,
			PackingID = 'PKSPK'+RIGHT(@LotIDNew2, 6),
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			MaterialLotNo = @MaterialLotNo

	-- 오리지널 Packing ID의 소분이력을 저장한다.
	INSERT INTO STB_PackingBoxChangeHist (OriginalPackingID, NewPackingID, CreateUserID)
		SELECT @OriginalPackingID, 'PKSPK'+RIGHT(@LotIDNew, 6), @pProcessUserID

	INSERT INTO STB_PackingBoxChangeHist (OriginalPackingID, NewPackingID, CreateUserID)
		SELECT @OriginalPackingID, 'PKSPK'+RIGHT(@LotIDNew2, 6), @pProcessUserID
END


