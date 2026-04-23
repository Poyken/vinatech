-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-08-07
-- Description:	Split Lot Aging for Ha Nam Factory
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSplitLotAgingHN]
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pBarcode VARCHAR(50) = NULL,
				@pSplitAgingQty INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Kiểm tra đã tách aging trước đó rồi thì không tách được nữa
	DECLARE @checkSplitLot VARCHAR(50)
	DECLARE @RouteCode VARCHAR(10) = NULL,
			@ProdQty INT,
			@NewProdQty INT 
	DECLARE @WarehouseCheck BIT

	DECLARE @OldControlNo VARCHAR(20),
			@OldPONo VARCHAR(20),
			@OldDayPlanNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@IsSplitedAging BIT
	DECLARE @NewBarcode VARCHAR(50)
	DECLARE @ControlNo VARCHAR(20)


	SELECT	@OldControlNo = ControlNo,
			@OldPONo = PONo,
			@OldDayPlanNo = DayPlanNo,
			@MaterialCode = MaterialCode,
			@checkSplitLot = InitialLot,
			@IsSplitedAging = IsSplitedAging
		FROM STB_SetInfo WHERE Barcode = @pBarcode

	SELECT	@RouteCode = RouteCode,
			@ProdQty = ProdQty
	FROM STB_ProdRouteHist WHERE ControlNo = @OldControlNo AND CompleteRoute IS NULL


	
	-- Check số lượng tách
	IF @pSplitAgingQty <= 0 AND @pSplitAgingQty > @ProdQty
		BEGIN
			RAISERROR(N'Số lượng tách phải lớn hơn 0 và nhỏ hơn số lượng đầu vào công đoạn!', 16, 1)
			RETURN;
		END



	-- Check Lot đã được tách trước đó chưa
	IF @checkSplitLot IS NOT NULL OR @IsSplitedAging = 1
		BEGIN
			RAISERROR(N'Lot này đã được tách trước đó!', 16, 1)
			RETURN;
		END




	-- Nếu công đoạn khác Aging thì không cho tách
	IF @RouteCode <> 'VE07' 
		BEGIN
			RAISERROR(N'Chỉ được tách ở công đoạn Aging!', 16, 1)
			RETURN;
		END

	



	--EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
	--						@pProcessLanguage = @pProcessLanguage,
	--						@pPONo = @PONo,
	--						@pDayPlanNo = @DayPlanNo,
	--						@pProdQty = @LotCount,
	--						@pBarcode = @Barcode

			SET @NewBarcode = @pBarcode + 'S'
			SET @NewProdQty = @ProdQty - @pSplitAgingQty
			--EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SetInfo',@ControlNo OUTPUT


			-- Không tạo ở bảng SetInfo ngay mà Insert dữ liệu vào bảng kho BTP, sau khi xuất kho BTP mới cho tạo SetInfo và ProdRouteHist

			-- Tạo lot đã chia ở bảng SetInfo
			--INSERT INTO STB_SetInfo
			--(
			--	ControlNo,
			--	PONo,
			--	DayPlanNo,
			--	MaterialCode,
			--	SetSeq,
			--	IsLineInput,
			--	IsLoss,
			--	IsDefect,
			--	Barcode,
			--	DefectQty,
			--	IsProdFinish,
			--	IsOutboundFinalInspection,
			--	IsFinalInspection,
			--	GradeCode,
			--	ProdQty,
			--	CreateDateTime,
			--	CreateUserID,
			--	InitialLot,
			--	WarehouseStatus
			--)
			--VALUES
			--(
			--	@ControlNo,
			--	@OldPONo,
			--	@OldDayPlanNo,
			--	@MaterialCode,
			--	1,
			--	0,
			--	0,
			--	0,
			--	@NewBarcode,
			--	0,
			--	0,
			--	0,
			--	0,
			--	'A',
			--	@pSplitAgingQty,
			--	GETDATE(),
			--	@pProcessUserID,
			--	@pBarcode,
			--	'Semi_WH'
			--)

		-- Thêm vào kho BTP
		INSERT INTO STB_SFGWarehouse_VVTF3 (OldControlNo, NewBarcode, ProdQty, WHStatus, CreateUserID, CreateDateTime)
		VALUES (@OldControlNo, @NewBarcode, @pSplitAgingQty, 'IN', @pProcessUserID, GETDATE())

		-- Cập nhật lại số lượng công đoạn 
		UPDATE STB_ProdRouteHist
		SET ProdQty = @NewProdQty
		WHERE ControlNo = @OldControlNo AND
				RouteCode = @RouteCode

		--  Cập nhật lại Lot cũ để không tách đc Lot nữa
		UPDATE STB_SetInfo
		SET IsSplitedAging = 1
		WHERE ControlNo = @OldControlNo


END
