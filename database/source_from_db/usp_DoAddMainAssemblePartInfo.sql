-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-14
-- Group : 생산관리
-- Description:	생산시 사용원자재 Lot 이력을 저장합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddMainAssemblePartInfo]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pControlNo VARCHAR(20),
	@pAsmLotNo VARCHAR(50),
	@pPartCode VARCHAR(50) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ControlNo VARCHAR(20) = @pControlNo
	DECLARE @LotID VARCHAR(50) = @pAsmLotNo
	DECLARE @PartCode VARCHAR(50) = ISNULL(@pPartCode,'')
	DECLARE @MaterialWarehouseCode VARCHAR(20) = ISNULL(@pMaterialWarehouseCode,'ROUTE_WH')

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @ProductGroup VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @LotQty NUMERIC(20,5)
	DECLARE @JobDate DATE
	DECLARE @ShiftCode VARCHAR(1)
	
	IF @PartCode = '' BEGIN		-- 재고관리하는 LOT
			SELECT
					@PartCode = MLI.MaterialCode,
					@LotQty = MLI.CurrentQty,
					@ProductGroup = MM.ProductGroupCode
			FROM
					STB_MaterialLotInfo MLI
					LEFT OUTER JOIN STB_MaterialMaster MM
						ON MM.MaterialCode = MLI.MaterialCode
			WHERE
					MLI.LotID = @LotID AND
					MLI.MaterialWarehouseCode = @MaterialWarehouseCode

			IF ISNULL(@PartCode,'') = '' BEGIN
					EXEC usp_RaiseLocalizedError @ProcessLanguage,'재고에 없는 Lot입니다'
					RETURN
			END
	END ELSE BEGIN				-- 재고관리하지 않는 LOT
			SELECT
					@ProductGroup = MM.ProductGroupCode,
					@LotQty = 0
			FROM
					STB_MaterialMaster MM
			WHERE
					MM.MaterialCode = @PartCode
	END

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@MaterialCode = SI.MaterialCode,
			@PONo = SI.PONo
	FROM
			STB_SetInfo SI
			LEFT OUTER JOIN STB_ProductionOrderInfo POI
				ON POI.PONo = SI.PONo
	WHERE
			SI.ControlNo = @ControlNo

	IF NOT EXISTS (
					SELECT	1
					FROM
							STB_ProductionOrderBom POB
					WHERE
							POB.PONo = @PONo AND
							POB.MaterialCode = @MaterialCode AND
							POB.ChildMaterialCode = @PartCode
				) BEGIN
			EXEC usp_RaiseLocalizedError @ProcessLanguage,'BOM에 해당하지 않는 자재입니다'
			RETURN
	END

	IF EXISTS (
				SELECT	1
				FROM
						STB_MainAssemblePartInfo MAPI
				WHERE
						MAPI.ControlNo = @ControlNo AND
						MAPI.AsmLotNo = @LotID
			) BEGIN
			EXEC usp_RaiseLocalizedError @ProcessLanguage,'이미 등록된 Lot입니다'
			RETURN
	END

	INSERT INTO STB_MainAssemblePartInfo
	(
		ControlNo,
		AsmSeqNo,
		AsmPartType,
		AsmPartCode,
		AsmPartBarcode,
		AsmPartSerialNo,
		AsmQty,
		AsmJobDate,
		AsmShiftCode,
		AsmDateTime,
		AsmWorkerCode,
		AsmMachineCode,
		AsmLotNo,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@ControlNo,
		ISNULL((SELECT MAX(AsmSeqNo) FROM STB_MainAssemblePartInfo WHERE ControlNo = @ControlNo),0) + 1,
		@ProductGroup,
		@PartCode,
		'',
		'',
		@LotQty,
		@JobDate,
		@ShiftCode,
		GETDATE(),
		@ProcessUserID,
		'',
		@LotID,
		GETDATE(),
		@ProcessUserID
	)	
END
