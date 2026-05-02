-- =============================================
-- Author:		DinhManh
-- Create date: 2025-08-14
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SemiFinishGoodWarehouse_VVTF3_Exported]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pNewBarcode VARCHAR(50) = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
	DECLARE @OldBarcode VARCHAR(50)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @ProdRouteHistNo VARCHAR(20)

	SELECT @OldControlNo = OldControlNo ,
			@ProdQty = ProdQty
		FROM STB_SFGWarehouse_VVTF3 where NewBarcode = @pNewBarcode

	SELECT	@OldBarcode = Barcode,
			@OldPONo = PONo,
			@OldDayPlanNo = DayPlanNo,
			@MaterialCode = MaterialCode,
			@checkSplitLot = InitialLot,
			@IsSplitedAging = IsSplitedAging
		FROM STB_SetInfo WHERE ControlNo = @OldControlNo

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SetInfo',@ControlNo OUTPUT

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist',@ProdRouteHistNo OUTPUT

	 --Tạo lot đã chia ở bảng SetInfo
			INSERT INTO STB_SetInfo
			(
				ControlNo,
				PONo,
				DayPlanNo,
				MaterialCode,
				SetSeq,
				IsLineInput,
				IsLoss,
				IsDefect,
				Barcode,
				DefectQty,
				IsProdFinish,
				IsOutboundFinalInspection,
				IsFinalInspection,
				GradeCode,
				ProdQty,
				CreateDateTime,
				CreateUserID,
				InitialLot
			)
			VALUES
			(
				@ControlNo,
				@OldPONo,
				@OldDayPlanNo,
				@MaterialCode,
				1,
				0,
				0,
				0,
				@pNewBarcode,
				0,
				0,
				0,
				0,
				'A',
				@ProdQty,
				GETDATE(),
				@pProcessUserID,
				@OldBarcode
			)

		-- Tạo dữ liệu bảng STB_ProdRouteHist
		INSERT INTO STB_ProdRouteHist (
			ProdRouteHistNo,
			CompanyCode,
			WorkCenterCode,
			PONo,
			DayPlanNo,
			ControlNo,
			MaterialCode,
			JobDate,
			ShiftCode,
			TimeCode,
			LineCode,
			RouteCode,
			ProdQty,
			ProdDateTime,
			CreateDateTime,
			CreateUserID
		)
		VALUES (
			@ProdRouteHistNo,
			'VVT',
			'VVT_F3',
			@OldPONo,
			@OldDayPlanNo,
			@ControlNo,
			@MaterialCode,
			CONVERT(VARCHAR, GETDATE(), 23),
			'1',
			'*',
			'VELINE-07',
			'VE07',
			@ProdQty,
			GETDATE(),
			GETDATE(),
			@pProcessUserID
		)

END
